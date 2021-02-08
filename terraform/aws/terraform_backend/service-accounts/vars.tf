# Variable that you need to change for each environment:

variable "tag_service" {
	type = string
	description = "the service tag to link the resource to the service"
	default = "terraform-state"
}

variable "tag_environment" {
	type = string
	description = "the environment tag (DEV, PROD, QA)"
	default = "DEV"
}

variable "log_target_prefix" {
	type = string
	description = "the folder where we store the logs for this environment"
	default = "log/terraform_state_bucket_dev/"
}


## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}