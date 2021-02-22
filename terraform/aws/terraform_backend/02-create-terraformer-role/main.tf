terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.13.0
  required_version = ">= 0.13.0"
}

provider "aws" {
  region = var.region
}

# The terraform backend information are initially stored in the file
# `backend.tf` in this folder

#  Create a role `terraformer_role` that can be assumed by 
#  the terraform script that we will use to create the resources we need.
#  - The role `terraformer` in the DEV account for edenred data ingestion (166082882045).
resource "aws_iam_role" "terraformer_role" {
  name = "terraformer.role"
  description = "the role in this account that can create resources with Terraform"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {      
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::553662416064:root"
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

# We get the role id of the role `terraformer_role` to add it to the policy
data "aws_iam_role" "terraformer_role" {
  name = aws_iam_role.terraformer_role.name
}


# Get the ARN for the DynamoDb table so we can use it in the policy
data "aws_dynamodb_table" "terraform_locks" {
  name = "terraform.locks"
}

# We create the policy `terraformer_policy` 
# to allow principals to create resources with Terraform
resource "aws_iam_policy" "terraformer_policy" {
  name        = "terraformer"
  description = "The policy to allow the terraformer.role to create resources"
  # We add tags to the policy
  tags = {
    "Name"        = "Terraformer Policy"
    "Environment" = var.tag_environment
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
  # The policy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# We attach the policy `terraformer_policy` to
# the role `terraformer_role`.
resource "aws_iam_role_policy_attachment" "terraformer_role_terraform_policy_attachment" {
    role = aws_iam_role.terraformer_role.name
    policy_arn = aws_iam_policy.terraformer_policy.arn
}