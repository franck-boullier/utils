# Variables that you need to change for the new service:

variable "ou_name" {
	type = string
	description = "The name of the OU that we create to group the different environments"
	default = "new_service"
}

variable "tag_service" {
	type = string
	description = "the service tag to link the resource to the service"
	default = "new_service"
}

# NOTE: need to revisit that!
variable "tag_environment" {
	type = string
	description = "the environment tag (DEV, PROD, QA)"
	default = "DEV"
}
## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}

variable "ou_parent_id" {
	type = string
	description = "The id of the OU where we create the new service"
	default = "ENTER THE ID OF YOUR ORGANIZATION or the PARENT OU ex:r-227c"
}