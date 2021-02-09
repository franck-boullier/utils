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
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "s3.amazonaws.com",
          "kms.amazonaws.com"
          ]
      },
      "Resources": "*",
      "Action": "sts:AssumeRole",
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

# We get the role id to add it to the policy
data "aws_iam_role" "terraformer_role" {
  name = aws_iam_role.terraformer_role.name
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

# We get the `logs_bucket` ID so we can use it in the policy
data "aws_s3_bucket" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id
}

# We allow the `terraformer_role` to store data in the `logs_bucket` under the `logs` folder
resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${data.aws_iam_role.terraformer_role.arn}"
        ]
      },
      "Resource": "arn:aws:s3:::${data.aws_s3_bucket.logs_bucket.bucket}/logs/*", 
      "Action": [
        "s3:PutObject"
      ]
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

# We allow the `terraformer_role` to store data in the `terraform_state_bucket`
# We also allow the TOP Account 553662416064 to access this bucket too.
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
      "Resource": [
        "arn:aws:s3:::${data.aws_s3_bucket.terraform_state_bucket.bucket}", 
        "arn:aws:s3:::${data.aws_s3_bucket.terraform_state_bucket.bucket}/*"
      ],
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:GetBucketLocation"
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