# Variable that you need to change for each environment:

variable "tag_environment" {
	type = string
	description = "The environment tag (DEV, PROD, QA)"
	default = "DEV"
}

# variables you have to change for each service

variable "tag_service" {
	type = string
	description = "The service tag to link the resource to the service"
	default = "terraform_backend"
}

variable "logs_target_prefix" {
	type = string
	description = "The folder where we store the logs for this environment"
	default = "logs/terraform_state_bucket/"
}

## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}