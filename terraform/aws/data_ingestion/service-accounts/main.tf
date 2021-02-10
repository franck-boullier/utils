terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.13.0
  required_version = ">= 0.13.0"
}

provider "aws" {
  region = var.region
}

# The terraform backend information are stored in the file
# `backend.tf` in this folder

# We get the account ID to add to the policies that we will create:
data "aws_caller_identity" "current" {}

#  Create a role `terraformer_role` that can be assumed by the anyone using the role `terraformer` in the TOP Account.
resource "aws_iam_role" "terraformer_role" {
  name = "terraformer"
  description = "the role in this account that can be assumed by user assuming the terraformer role in the TOP account"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {      
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::553662416064:role/terraformer"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    "Name"        = "Terraformer Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

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

  block_public_acls   = true
  block_public_policy = true
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
        "AWS": "${data.aws_iam_role.log_service_role.arn}",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${data.aws_s3_bucket.logs_bucket.bucket}/logs/*"
      }
    }
  ]
}
POLICY
}

# Create an IAM Group `raw_data_uploader`
resource "aws_iam_group" "raw_data_uploader_group" {
  name = "raw-data-uploader"
  path = "/users/"
}

# Create a role `raw_data_uploader_role` that can assume some IAM roles.
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
        "Service": "iam.amazonaws.com"
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

# Create a policy `raw_data_uploader_policy` to limit the resource that the the role `raw_data_uploader_role` can access:
resource "aws_iam_policy" "raw_data_uploader_policy" {
  name        = "data-uploader-policy"
  description = "The policy to allow principals upload data to the raw_data_bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:group/users/raw-data-uploader"
    }
  ]
}
EOF
}

# Attach the policy `raw_data_uploader_policy` to the role `raw_data_uploader_role`
resource "aws_iam_role_policy_attachment" "raw_data_uploader_policy_role_attachment" {
    role = aws_iam_role.raw_data_uploader_role.name
    policy_arn = aws_iam_policy.raw_data_uploader_policy.arn
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

  block_public_acls   = true
  block_public_policy = true
}

# Create a policy `raw_data_bucket_policy` that allows principals 
# assuming the role `raw_data_uploader_role` to read and write in the `raw_data_bucket`.

# First we get the role id of the role `raw_data_uploader_role` to add it to the `raw_data_bucket_policy` policy
data "aws_iam_role" "raw_data_uploader_role" {
  name = aws_iam_role.raw_data_uploader_role.name
}

# Than we get the `raw_data_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "raw_data_bucket" {
  bucket = aws_s3_bucket.raw_data_bucket.id
}

# Then we create the policy
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

# Attach the policy `processed_data_uploader_policy` to the role `processed_data_uploader_role`
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

  block_public_acls   = true
  block_public_policy = true
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