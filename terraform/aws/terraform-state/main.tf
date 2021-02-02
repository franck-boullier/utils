# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE AN S3 BUCKET AND DYNAMODB TABLE TO USE AS A TERRAFORM BACKEND
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.13.0
  required_version = ">= 0.13.0"
}

provider "aws" {
  region = var.region
}

# We create the AWS KMS Key to Encrypt/Decrypt the Log Bucket
resource "aws_kms_key" "log_bucket_key" {
  description = "This key is used to encrypt the objects in the Log bucket"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  is_enabled = true
  enable_key_rotation = false
  # We add some Tags:
  tags = {
    "Name"        = "Log Bucket Key"
    "Environment" = var.tag-environment
    "Service"     = var.tag-service
    "Terraform"   = "true"
  }
}

# We create the AWS KMS Key to Encrypt/Decrypt the Terraform State Bucket
resource "aws_kms_key" "terraform_state_key" {
  description = "This key is used to encrypt the objects in the Terraform State bucket"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  is_enabled = true
  enable_key_rotation = false
  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket Key"
    "Environment" = var.tag-environment
    "Service"     = var.tag-service
    "Terraform"   = "true"
  }
}

# We create the Log Bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "log-bucket"
  acl    = "log-delivery-write"

  # We add some Tags:
  tags = {
    "Name"        = "Log Bucket"
    "Environment" = var.tag-environment
    "Service"     = var.tag-service
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

  # We createe some lifecycle rules for the Log Bucket
  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "false"
      "Environment" = "DEV"
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

# We create the Terraform State Bucket
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket_prefix = "terraform-state-bucket"
  acl    = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket"
    "Environment" = var.tag-environment
    "Service"     = var.tag-service
    "Terraform"   = "true"
  }
  
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }

  # The logs for this bucket will be on a separate S3 bucket
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/terraform-states/"
  }

  # We force encryption in the bucket with the `log_bucket_key`
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# We make sure that the Objects in the bucket cannot be public

resource "aws_s3_bucket_public_access_block" "block_public_access_terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_public_access_block" "block_public_access_log" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# ------------------------------------------------------------------------------
# CREATE THE DYNAMODB TABLE
# ------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Locks"
    "Environment" = var.tag-environment
    "Service"     = var.tag-service
    "Terraform"   = "true"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

## We create the permissions to allow access to the Terraform state bucket