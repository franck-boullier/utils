# Terraform state file location: We store the state into a dedicate bucket.
# This is a special service that works for the whole organization.
# We are storing the state of this terraform script in the Top Account.
terraform {
  backend "s3" {
    bucket          = "terraform-state-bucket-20210208070500176300000002"
    key             = "data_ingestion/accounts/terraform.tfstate"
    region          = "ap-southeast-1"
    encrypt         = true
    # We have IAM access issues so we comment that out for now...
#    dynamodb_table  = "terraform.locks"
  }
}