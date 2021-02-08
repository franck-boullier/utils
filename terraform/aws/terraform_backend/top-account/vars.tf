# Variable that you need to change for each service:

variable "ou_name" {
	description = "The name of the OU that you want to create for this service"
	type  = string
	default = "terraform_backend"
}

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

## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}