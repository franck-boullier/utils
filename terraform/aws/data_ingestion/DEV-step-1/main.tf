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

# We create the OU for the new service:
resource "aws_organizations_organizational_unit" "ou_new_service" {
  name = var.ou_name
  parent_id = var.aws_account_parent_id
}

# We create the account we need: DEV
resource "aws_organizations_account" "dev_account" {
  depends_on = [aws_organizations_organizational_unit.ou_new_service]
  name  = "Data Ingestion DEV"
  email = "data.ingestion.aws.dev@uniqgift.com"
  parent_id = aws_organizations_organizational_unit.ou_new_service.id
  tags = {
    "Environment" = "DEV"
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the account we need: QA
resource "aws_organizations_account" "qa_account" {
  depends_on = [aws_organizations_organizational_unit.ou_new_service]
  name  = "Data Ingestion QA"
  email = "data.ingestion.aws.qa@uniqgift.com"
  parent_id = aws_organizations_organizational_unit.ou_new_service.id
  tags = {
    "Environment" = "QA"
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}

# We create the account we need: PROD
resource "aws_organizations_account" "prod_account" {
  depends_on = [aws_organizations_organizational_unit.ou_new_service]
  name  = "Data Ingestion PROD"
  email = "data.ingestion.aws.prod@uniqgift.com"
  parent_id = aws_organizations_organizational_unit.ou_new_service.id
  tags = {
    "Environment" = "PROD"
    "Service"     = var.tag_service
    "Terraform"   = "true"
  }
}