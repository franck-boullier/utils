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

# We create a role `terraformer_role` to allow a user in another account to
# - Interact with S3.
# - Interact with KMS.
# in the AWS account associated to the `terraform_backend` service.
resource "aws_iam_role" "terraformer_role" {
  name = "terraformer_role"
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
    "Name"        = "Terraformer Role"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the AWS KMS Key to Encrypt/Decrypt the Log Bucket
resource "aws_kms_key" "log_bucket_key" {
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
      "Sid": "terraformer_user_can_use_log_bucket_key",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": aws_iam_role.terraformer_role.arn
      },
      "Resource": "*"
    }
  ]
}
EOF

  # We add some Tags:
  tags = {
    "Name"        = "Log Bucket Key"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the Log Bucket
resource "aws_s3_bucket" "log_bucket" {
  depends_on = [aws_kms_key.log_bucket_key]
  bucket_prefix = "log_bucket"
  acl    = "log-delivery-write"

  # We add some Tags:
  tags = {
    "Name"        = "Log Bucket"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }

  # We force encryption in the bucket with the `log_bucket_key`
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.log_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  # We make sure that we can't destroy anything by mistake
  lifecycle {
	prevent_destroy = true
  }

  # We create some lifecycle rules for the Log Bucket
  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "false"
      "Environment" = var.tag_environment
      "Service"     = var.tag_service
      "Terraform"   = "true"
    }

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

# We make sure that the Objects in the `log_bucket` cannot be public
resource "aws_s3_bucket_public_access_block" "block_public_access_log_bucket" {
  depends_on = [aws_s3_bucket.log_bucket]
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# We create the policy to allow the terraformer role to access the log_bucket
data "aws_iam_policy_document" "log_bucket_policy_prep" {
  statement {
    actions   = ["s3:*"]
    resources = ["aws_iam_role.terraformer_role.arn"]
  }
}

# We make sure that the terraformer_role can access the log_bucket
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = data.aws_iam_policy_document.log_bucket_policy_prep.json
}

###############################
#
# Terraform State service
#
###############################

# We create the AWS KMS Key to Encrypt/Decrypt the Terraform State Bucket
resource "aws_kms_key" "terraform_state_bucket_key" {
  description = "This key is used to encrypt the objects in the Terraform State bucket"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  is_enabled = true
  enable_key_rotation = false

  # We make sure that the role `terraformer` can use this key
  policy = <<EOF
{  
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "terraformer_user_can_access_log_bucket",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": aws_iam_role.terraformer_role.arn
      },
      "Resource": "*"
    }
  ]
}
EOF

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket Key"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the Terraform State Bucket for ALL the other resources in the organization 
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket_prefix = "terraform-state-bucket"
  acl = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
  
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # The logs for this bucket will be on le `log_bucket`
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = var.log_target_prefix
  }

  # We force encryption in the bucket with the `terraform_state_key`
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
  # We make sure that we can't destroy anything by mistake
  lifecycle {
	prevent_destroy = true
  }
}

# We make sure that the Objects in the `terraform_state_bucket` cannot be public

resource "aws_s3_bucket_public_access_block" "block_public_access_terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# We create the policy to allow the terraformer role to access the terraform_state_bucket
data "aws_iam_policy_document" "terraform_state_bucket_policy_prep" {
  statement {
    actions   = ["s3:*"]
    resources = ["aws_iam_role.terraformer_role.arn"]
  }
}

# We make sure that the terraformer_role can access the terraform_state_bucket
resource "aws_s3_bucket_policy" "terraform_state_bucket_policy" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  policy = data.aws_iam_policy_document.terraform_state_bucket_prep.json
}

# We Create the Dynamo DB table to manage locks for terraform state files
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
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

# We create a policy `terraformer_policy` to allow interaction with 
#  - the S3 bucket `log_bucket`
#  - the S3 bucket `terraformer_backend_bucket`.

resource "aws_iam_policy" "terraformer_policy" {
  name        = "terraformer_policy"
  description = "Allow a user assuming the role terraformer_role to interact with the log_bucket and the terraform_backend_bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": aws_iam_role.terraformer_role.arn,
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ]
      "Resource": [
        aws_s3_bucket.terraform_state_bucket.arn/*,
        aws_s3_bucket.terraform_state_bucket.arn,
        aws_s3_bucket.log_bucket.arn/*,
        aws_s3_bucket.log_bucket.arn
      ]  
    }
  ]
}
EOF
}

# We attach the policy `terraformer_policy` to the role `terraformer_role` :
resource "aws_iam_role_policy_attachment" "attach_terraformer_role_policy" {
  role       = aws_iam_role.terraformer_role.name
  policy_arn = aws_iam_policy.terraformer_policy.arn
}
