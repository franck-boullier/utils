terraform {
  # This module is now only being tested with Terraform 0.14.x. However, to make upgrading easier, we are setting
  # 0.13.0
  required_version = ">= 0.13.0"
}

provider "aws" {
  region = var.region
}

# We create the OU for the new service:
resource "aws_organizations_organizational_unit" "ou_new_service" {
  name = var.org_name
  parent_id = var.aws_account_parent_id
}

# We create the 3 Accounts for each environment:

resource "aws_organizations_account" "account" {
  depends_on = [aws_organizations_organizational_unit.ou_new_service]
  name  = var.account_name[count.index]
  email = var.account_email_id[count.index]
  parent_id = "${var.aws_account_parent_id}"

}