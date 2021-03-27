# Terraform state file location: We store the state into a dedicate bucket.
# - The bucket `my-bucket-to-store-terraform-state` should already exist.
# - The credentials file MUST start with `terraformer-` <--- this is to make
#   sure that it will always be excluded from your git repo (so you do not leak
#   very confidential information that could allow a malicious user to access 
#   your account...)
terraform {
  backend "gcs" {
    bucket          = "my-bucket-to-store-terraform-state"
    prefix          = "terraform_state/ci_web_server"
    credentials     = "terraformer-my-credentials.json"
  }
}