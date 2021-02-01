
# We store the state into a dedicate bucket.
	
terraform {
	backend "s3" {
	bucket = "uniqgift-backend-state-terraform"
	key    = "terraform-state/accounts/terraform.tfstate"
	region = "ap-southeast-1"
	}
}