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
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the Log Bucket
resource "aws_s3_bucket" "log_bucket" {
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

# We make sure that the Objects in the `log_bucket` cannot be public

resource "aws_s3_bucket_public_access_block" "block_public_access_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
}