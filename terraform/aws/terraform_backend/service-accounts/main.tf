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

##########################
#
# Terraformer utilities
#
##########################

# We get the account ID to add to the policies that we will create:
data "aws_caller_identity" "current" {}

#  Create a role `terraformer_role` that can be assumed by 
#  - anyone using the role `terraformer` in the TOP Account.
#  - The role `terraformer` in the DEV account for edenred data ingestion (166082882045).
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
        "AWS": [
          "arn:aws:iam::553662416064:role/terraformer",
          "arn:aws:iam::166082882045:role/terraformer"
        ]
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

/*
WE ARE NOT USING THIS YET - THIS IS WIP

# We create the AWS KMS Key to Encrypt/Decrypt the Log Bucket
resource "aws_kms_key" "logs_bucket_key" {
  depends_on = [aws_iam_role.terraformer_role]
  description = "This key is used to encrypt the objects in the Log bucket"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  is_enabled = true
  enable_key_rotation = false
  # We make sure that the role `terraformer_role` can use this key
  policy = <<EOF
{  
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "terraformer_user_can_use_logs_bucket_key",
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Principal": {
        "${data.aws_iam_role.terraformer_role.arn}",
        "arn:aws:iam::553662416064:root"
      },
      "Resource": "*"
    }
  ]
}
EOF

  # We add some Tags:
  tags = {
    "Name"        = "Logs Bucket Key"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}
*/

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
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${data.aws_s3_bucket.logs_bucket.bucket}/logs/*",
      "Principal": {
        "AWS": [
          "${data.aws_iam_role.log_service_role.arn}"
        ]
      }
    }
  ]
}
POLICY
}

###############################
#
# Terraform State service
#
###############################

# We create the Terraform State Bucket for ALL the other resources in the organization 
resource "aws_s3_bucket" "terraform_state_bucket" {
  depends_on = [aws_iam_role.terraformer_role]
  bucket_prefix = "terraform-state-bucket-"
  acl = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket"
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
    target_prefix = var.logs_target_prefix
  }
}

# We make sure that the Objects in the `terraform_state_bucket` cannot be public
resource "aws_s3_bucket_public_access_block" "block_public_access_terraform_state" {
  depends_on = [aws_s3_bucket.terraform_state_bucket]
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# We get the `terraform_state_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
}

# We allow:
# - the `terraformer_role` 
# - The TOP Account 553662416064
# - The other accounts where will will run terraform.
# to store data in the `terraform_state_bucket`
resource "aws_s3_bucket_policy" "terraform_state_bucket_policy" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${data.aws_iam_role.terraformer_role.arn}",
          "arn:aws:iam::553662416064:root"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${data.aws_s3_bucket.terraform_state_bucket.bucket}", 
        "arn:aws:s3:::${data.aws_s3_bucket.terraform_state_bucket.bucket}/*"
      ]
    }
  ]
}
POLICY
}

# We Create the Dynamo DB table to manage locks for terraform state files
resource "aws_dynamodb_table" "terraform_locks" {
  # We use specific name convention for the Dunamo Db table: pseudo_database.table
  name         = "terraform.locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Locks"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

# We make sure that:
# - the role `terraformer_role`
# - The TOP Account 553662416064
# - The other accounts where will will run terraform.
# can interact with the Dynamo DB table `terraform_locks` too

# We get the role id to add it to the policy
data "aws_iam_role" "terraformer_role" {
  name = aws_iam_role.terraformer_role.name
}

# Get the ARN for the DynamoDb table so we can use it in the policy
data "aws_dynamodb_table" "terraform_locks" {
  name = "terraform.locks"
}

# We create the policy `terraformer_role_terraform_locks_policy` 
# to allow principals to interact with the table `terraform_locks`
resource "aws_iam_policy" "terraformer_role_terraform_locks_policy" {
  name        = "terraformer-terraform-locks"
  description = "The policy to allow the terraformer_role to use the terraform_locks table"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${data.aws_dynamodb_table.terraform_locks.arn}"
    }
  ]
}
EOF
}

# We attach the policy `terraformer_role_terraform_locks_policy` to
# the role `terraformer_role`.
resource "aws_iam_role_policy_attachment" "terraformer_role_terraform_locks_policy_attachment" {
    role = aws_iam_role.terraformer_role.name
    policy_arn = aws_iam_policy.terraformer_role_terraform_locks_policy.arn
}