# Terraform state file location: We store the state into a dedicate bucket.
# This is a special service that works for the whole organization.
# We are storing the state of this terraform script in the Top Account.
terraform {
  backend "s3" {
    bucket = "uniqgift-backend-state-terraform"
    key    = "terraform-state/terraform_service/terraform.tfstate"
    region = "ap-southeast-1"
  }
}