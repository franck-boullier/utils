terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.13.0
  required_version = ">= 0.13.0"
}

# We are running this terraform script assuming the `terraformer` role
# in the `terraformed` account.
provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::765328940034:role/terraformer.role"
  }
}

# The terraform backend information are stored in the file
# `backend.tf` in this folder

##########################
#
# Terraformer utilities
#
##########################

# We get the account ID to add to the policies that we will create:
data "aws_caller_identity" "current" {}

###################
#
# Logs
#
###################

# We create a role `log_service_role` and allow the following services to assume this role (this is so that these services can write logs):
# - S3.
# - KMS.
resource "aws_iam_role" "log_service_role" {
  name = "log-service"
  description = "The role to enable some services to write into the logs bucket"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "s3.amazonaws.com",
          "kms.amazonaws.com"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    "Name"        = "Log Service Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the logs Bucket
resource "aws_s3_bucket" "logs_bucket" {
  bucket_prefix = "logs-bucket-"
  acl    = "log-delivery-write"

  # We add some Tags:
  tags = {
    "Name"        = "logs Bucket"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }

  # We force encryption in the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # We make sure that we can't destroy anything by mistake
  lifecycle {
	prevent_destroy = true
  }

  # We store all versions of each object
  versioning {
    enabled = true
  }

  # We create some lifecycle rules for the logs Bucket
  lifecycle_rule {
    id      = "logs"
    enabled = true

    # Everything with the prefix `/logs` will have transition cycle
    prefix = "logs/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# We make sure that the Objects in the `logs_bucket` cannot be public
resource "aws_s3_bucket_public_access_block" "block_public_access_logs_bucket" {
  depends_on = [aws_s3_bucket.logs_bucket]
  bucket = aws_s3_bucket.logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# We get the role id of the role `log_service_role` to add it to the policy
data "aws_iam_role" "log_service_role" {
  name = aws_iam_role.log_service_role.name
}

# We get the `logs_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
}

# We allow the `log_service_role` to store data in the `logs_bucket` under the `logs` folder
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_role.log_service_role.arn}"
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${data.aws_s3_bucket.logs_bucket.bucket}/logs/*"
    }
  ]
}
POLICY
}

###################
#
# Cloudwatch
#
###################

# Create a `cloudwatch_policy` to allow writing log streams to cloudwatch.
resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch"
  path        = "/"
  description = "Allows full access to create log streams and groups and put log events to your account"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

###################
#
# Raw Data
#
###################

# Create a role `raw_data_uploader_role` that can assume access:
# - S3
# - AWS Transfer Service
resource "aws_iam_role" "raw_data_uploader_role" {
  name = "raw-data-uploader"
  description = "The role that allow a principal to upload data in the raw_data_bucket"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "s3.amazonaws.com",
          "transfer.amazonaws.com"
        ]
      }
    }
  ]
}
EOF

  tags = {
    "Name"        = "Raw Data Uploader Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# Create a bucket `raw_data_bucket` to store the raw data that will be sent by the 3rd party.
resource "aws_s3_bucket" "raw_data_bucket" {
  bucket_prefix = "raw-data-bucket-"
  acl = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Raw Data Bucket"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }

  # We force encryption in the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  } 
  
  # We make sure that we can't destroy anything by mistake
  lifecycle {
	prevent_destroy = true
  }

  # We store all versions of each object so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # The logs for this bucket will be on le `logs_bucket`
  logging {
    target_bucket = aws_s3_bucket.logs_bucket.id
    target_prefix = var.logs_target_prefix_raw_data_bucket
  }

  # We create some lifecycle rules for the Bucket
  lifecycle_rule {
    id      = "raw-data-transitions"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# We make sure that the Objects in the `raw_data_bucket` cannot be public
resource "aws_s3_bucket_public_access_block" "block_public_access_raw_data_bucket" {
  depends_on = [aws_s3_bucket.raw_data_bucket]
  bucket = aws_s3_bucket.raw_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a S3 bucket policy `raw_data_bucket_policy` that allows principals 
# assuming the role `raw_data_uploader_role` to read and write in the `raw_data_bucket`.

# First we get the role id of the role `raw_data_uploader_role` to add it to the `raw_data_bucket_policy` policy
data "aws_iam_role" "raw_data_uploader_role" {
  name = aws_iam_role.raw_data_uploader_role.name
}

# Than we get the `raw_data_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "raw_data_bucket" {
  bucket = aws_s3_bucket.raw_data_bucket.id
}

# Then we create the S3 Bucket policy
resource "aws_s3_bucket_policy" "raw_data_bucket_policy" {
  bucket = aws_s3_bucket.raw_data_bucket.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_role.raw_data_uploader_role.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${data.aws_s3_bucket.raw_data_bucket.bucket}", 
        "arn:aws:s3:::${data.aws_s3_bucket.raw_data_bucket.bucket}/*"
      ]
    }
  ]
}
POLICY
}

###################
#
# Transfer Server
#
###################

# Create the `cloudwatch-transfer_role` to allow writing cloudwatch logs for all services.
resource "aws_iam_role" "cloudwatch-transfer_role" {
  name = "cloudwatch-transfer"
  description = "Enable Cloudwatch to store data about what is happening on the Transfer Service - SFTP Server"
  path = "/service-role/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {      
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    "Name"        = "Cloudwatch Transfer Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We attach the policy `cloudwatch_policy` to the role `cloudwatch-transfer_role`.
resource "aws_iam_role_policy_attachment" "cloudwatch-transfer_role_cloudwatch_policy_attachment" {
  role       = aws_iam_role.cloudwatch-transfer_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# We create a transfer server that will:
# - Be service Managed (new users are created in the AWS console).
# - Be Public
# - Log events on Cloudwatch
resource "aws_transfer_server" "edentred-sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.cloudwatch-transfer_role.arn
  endpoint_type = "PUBLIC"

  tags = {
    "Name"        = "Edenred SFTP Server"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

##############################################################
#
# eMail Notification when new files in the `raw-data_bucket`
#
##############################################################

# Create IAM Role `lambda_s3_new_file_notification_role` for the Lambda Function
resource "aws_iam_role" "lambda_s3_new_file_notification_role" {
  name = "lambda_s3_new_file_notification"
  description = "The role to allow use of the Lambda service"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create a `lambda-notification_policy` to allow writing log streams.
resource "aws_iam_policy" "lambda-notification_policy" {
  name        = "lambda-notification"
  path        = "/"
  description = "Allows sending of emails via SES"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Attach the policy `lambda-notification_policy` to the role `lambda_s3_new_file_notification_role`
resource "aws_iam_role_policy_attachment" "cloudwatch-lambda-s3-new-file_role_lambda-notification_policy_attachment" {
  role       = aws_iam_role.lambda_s3_new_file_notification_role.name
  policy_arn = aws_iam_policy.lambda-notification_policy.arn
}

# Package the code for the lambda function `lambda_s3_new_file_notification_lambda` 
# in a zip file `lambda_s3_new_file_notification.zip`
data "archive_file" "lambda_s3_new_file_notification_zip" {
  type = "zip"
  output_path = "${path.module}/lambda_s3_new_file_notification.zip"
  source_dir = "${path.module}/email_template/"
}

# Deploy/Create the lambda function `lambda_s3_new_file_notification_lambda`
resource "aws_lambda_function" "lambda_s3_new_file_notification_lambda" {
  filename = "lambda_s3_new_file_notification.zip"
  source_code_hash = filebase64sha256("lambda_s3_new_file_notification.zip")
  function_name    = "s3_new_file_notifications_via_ses"
  timeout		       = 10  
  role             = aws_iam_role.lambda_s3_new_file_notification_role.arn
  handler          = "notification_new_raw_object.lambda_handler"
  runtime          = "python3.8"
  
  tags = {
    "Name"        = "Lambda - Email Notification - New file"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# Allow lambda to invoke function from the S3 bucket `raw_data_bucket`
resource "aws_lambda_permission" "allow_raw_data_bucket_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_s3_new_file_notification_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data_bucket.arn
}

# Configure the notification `raw_data_bucket_new_object_notification`:
# Call the lambda function `lambda_s3_new_file_notification_lambda`
# each time a new object is added to the bucket `raw_data_bucket`
resource "aws_s3_bucket_notification" "raw_data_bucket_new_object_notification" {
  bucket = aws_s3_bucket.raw_data_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_s3_new_file_notification_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

###################
#
# Processed Data
#
###################

# Create an IAM Group `processed_data_access_group`
resource "aws_iam_group" "processed_data_access_group" {
  name = "processed-data-access"
  path = "/users/"
}

# Create a role `processed_data_access_role` that can be assumed by
# users in the group `processed_data_access_group`.
resource "aws_iam_role" "processed_data_access_role" {
  name = "processed-data-access"
  description = "The role that allow a principal to access data in the processed_data_bucket"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "iam.amazonaws.com"
      }
    }
  ]
}
EOF

  tags = {
    "Name"        = "Processed Data Access Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# Create a policy `processed_data_access_policy` to limit the IAM resource that the 
# the role `processed_data_access_role` can access:
resource "aws_iam_policy" "processed_data_access_policy" {
  name        = "data-data-access-policy"
  description = "The policy to allow principals access data in the processed_data_bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/users/processed-data-access"
    }
  ]
}
EOF
}

# Attach the policy `processed_data_access_policy` to the role `processed_data_access_role`
resource "aws_iam_role_policy_attachment" "processed_data_access_role_policy_attachment" {
    role = aws_iam_role.processed_data_access_role.name
    policy_arn = aws_iam_policy.processed_data_access_policy.arn
}

# Create a bucket `processed_data_bucket` to store the processed data 
# after ETL has been done.
resource "aws_s3_bucket" "processed_data_bucket" {
  bucket_prefix = "processed-data-bucket-"
  acl = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Processed Data Bucket"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }

  # We force encryption in the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  } 
  
  # We make sure that we can't destroy anything by mistake
  lifecycle {
	prevent_destroy = true
  }

  # We store all versions of each object so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # The logs for this bucket will be on le `logs_bucket`
  logging {
    target_bucket = aws_s3_bucket.logs_bucket.id
    target_prefix = var.logs_target_prefix_processed_data_bucket
  }

  # We create some lifecycle rules for the Bucket
  lifecycle_rule {
    id      = "processed-data-transitions"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# We make sure that the bucket `processed_data_bucket` cannot be public. 
resource "aws_s3_bucket_public_access_block" "processed_data_bucket" {
  depends_on = [aws_s3_bucket.processed_data_bucket]
  bucket = aws_s3_bucket.processed_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create a policy `processed_data_bucket_access_policy` 
# that allows the users assuming the role `processed_data_access_role` 
# to read and write in the `processed_data_bucket`.

# First we get the role id of the role `processed_data_access_role` to add it to the `raw_data_bucket_policy` policy
data "aws_iam_role" "processed_data_access_role" {
  name = aws_iam_role.processed_data_access_role.name
}

# Than we get the `processed_data_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "processed_data_bucket" {
  bucket = aws_s3_bucket.processed_data_bucket.id
}

# Then we create the policy
resource "aws_s3_bucket_policy" "processed_data_bucket_access_policy" {
  bucket = aws_s3_bucket.processed_data_bucket.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_role.processed_data_access_role.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${data.aws_s3_bucket.processed_data_bucket.bucket}", 
        "arn:aws:s3:::${data.aws_s3_bucket.processed_data_bucket.bucket}/*"
      ]
    }
  ]
}
POLICY
}