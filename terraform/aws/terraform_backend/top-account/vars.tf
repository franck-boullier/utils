# Variable that you need to change for each environment:

variable "aws_account_parent_id" {
	description = "The ID of the OU where the service is created"
	type  = string
	default = "ou-227c-13lbnrrq"
}

# We add a tag to identify the service we are creating
variable "tag_service" {
	type = string
	description = "the service tag to link the resource to the service"
	default = "terraform_state"
}

# We are creating as many account as we have account names here
variable "account_name" {
	description = "Create aws accounts. ex ['dev','prod']"
	type = list(string)
	default = [
		"Terraform Backend Dev",
		"Terraform Backend Staging",
		"Terraform Backend Prod"
	]
}

# We are using the following emails for each of these accounts
# Email must exist
# Use the same order as for the account names
variable "account_email_id" {
	description = "Aws accounts email id's . ex ['dev@test.com','prod@test.com']"
	type = list(string)
	default = [
		"terraform.backend.aws.dev@uniqgift.com",
		"terraform.backend.aws.qa@uniqgift.com",
		"terraform.backend.aws.prod@uniqgift.com"
	]
}

# We add an environment tag
# Use the same order as for the account names
variable "tag_environment" {
	type = list(string)
	description = "the environment tag (DEV, PROD, QA)"
	default = [
		"DEV",
		"QA", 
		"PROD"
	]
}

## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}