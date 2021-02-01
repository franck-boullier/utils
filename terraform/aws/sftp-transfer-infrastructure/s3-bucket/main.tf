provider "aws" {
  region = var.region
}

# We store the state into a dedicate bucket.
	
terraform {
	backend "s3" {
	bucket = "uniqgift-backend-state-terraform"
	key    = "terraform-state/sftp-edenred-data-ingestion/terraform.tfstate"
	region = "ap-southeast-1"
	}
}

###############
#
# Log Bucket
#
###############

# Log Bucket Encryption

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
    "Environment" = "DEV"
    "Terraform"   = "true"
  }
}


# We create the IAM Policy document to Encrypt the Log Bucket
data "aws_iam_policy_document" "kms_encrypt_log_bucket" {
  statement {
    sid = "Allow KMS Use to encrypt Log bucket"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = aws_kms_key.log_bucket_key.arn
  }
}

# We create the policy to allow encryption of the log bucket
resource "aws_iam_policy" "kms_encrypt_log_bucket_policy" {
  name        = "kms-encrypt-log-bucket-policy"
  description = "The policy to allow IAM user or role to encrypt data with a specific KMS Keys"
  # We use the policy we have created earlier
  policy = data.aws_iam_policy_document.kms_encrypt_log_bucket.json
}

# We create the role that we need - Encrypt for the Log Bucket

resource "aws_iam_role" "kms_encrypt_log_bucket_role" {
  name = "kms-encrypt-log-bucket-role"
  assume_role_policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "kms.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "Assume KMS Role"
    }
  ]
}
EOF
}

/*
# Log Bucket Decryption

# We create the IAM Policy document to Decrypt the Log Bucket
data "aws_iam_policy_document" "kms_decrypt_log_bucket" {
  statement {
    sid = "Allow KMS Use to decrypt Log bucket"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = aws_kms_key.log_bucket_key.arn
  }
}

# We create the policy to allow decryption of the log bucket
resource "aws_iam_policy" "kms_decrypt_log_bucket_policy" {
  name        = "kms-decrypt-log-bucket-policy"
  description = "The policy to allow IAM user or role to decrypt data with a specific KMS Keys"
  # We use the policy we have created earlier
  policy = data.aws_iam_policy_document.kms_decrypt_log_bucket.json
}

# We create the role that we need - Decrypt for the Log Bucket

resource "aws_iam_role" "kms_decrypt_log_bucket_role" {
  name               = "kms-decrypt-log-bucket-role"
  assume_role_policy = data.aws_iam_policy_document.kms_decrypt_log_bucket
}
*/

# We create the Log Bucket
resource "aws_s3_bucket" "log_bucket" {
  bucket_prefix = "log-bucket"
  acl    = "log-delivery-write"

  # We add some Tags:
  tags = {
    "Name"        = "Log Bucket"
    "Environment" = "DEV"
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

###############
#
# Raw Bucket
#
###############

# We create the AWS KMS Key to encrypt the Raw Bucket
resource "aws_kms_key" "raw_bucket_key" {
  description = "This key is used to encrypt the objects in the Raw bucket"
  key_usage = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days = 30
  is_enabled = true
  enable_key_rotation = false  # We add some Tags:
  tags = {
    "Name"        = "Raw Bucket Key"
    "Environment" = "DEV"
    "Terraform"   = "true"
  }
}

# We Create the Bucket for the raw data
resource "aws_s3_bucket" "raw_data" {
  bucket_prefix = "raw-data"
  acl    = "private"

  # We make sure that we track versions 
  versioning {
    enabled = true
  }

  # The logs for this bucket will be on a separate S3 bucket
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/raw-data/"
  }

  # We force encryption in the bucket with the `raw_bucket_key`
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.raw_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  # We createe some lifecycle rules for the Log Bucket
  lifecycle_rule {
    id      = "raw"
    enabled = true

    # The number of days after initiating a multipart upload when the multipart upload must be completed
    abort_incomplete_multipart_upload_days = 1

    # We add some tags
    tags = {
      "rule"      = "raw"
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