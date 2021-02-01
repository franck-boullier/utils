provider "aws" {
  region = var.region
}

# We create a dedicate bucket to store the Terraform states.
	
# We create the AWS KMS Key to Encrypt/Decrypt the Log Bucket
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

# We create the Terraform State Bucket
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket_prefix = "terraform-state-bucket"
  acl    = "private"

  # We add some Tags:
  tags = {
    "Name"        = "Terraform State Bucket"
    "Environment" = "DEV"
    "Terraform"   = "true"
  }

  # We force encryption in the bucket with the `log_bucket_key`
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state_bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

## We create the permissions to allow access to the Terraform state bucket