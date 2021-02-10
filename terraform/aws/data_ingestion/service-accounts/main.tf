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

#  Create a role `terraformer_role` that can be assumed by the anyone using the role `terraformer` in the TOP Account.
resource "aws_iam_role" "terraformer_role" {
  name = "terraformer"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {      
      "Sid": "Accept the IAM role terraformer from the TOP Account",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::553662416064:/role/terraformer"]
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
  name = "log_service"
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

# Create an IAM Group `raw_data_uploader`
resource "aws_iam_group" "raw_data_uploader_group" {
  name = "raw-data-uploader"
  path = "/users/"
}

# We get the account ID to add to the policy:
data "aws_caller_identity" "current" {}

# Create a role `raw_data_uploader_role` that can be assumed by users in the group `raw_data_uploader_group`.
resource "aws_iam_role" "raw_data_uploader_role" {
  name = "raw-data-uploader"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:/group/users/raw-data-uploader"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
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


