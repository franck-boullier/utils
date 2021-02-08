# Variable that you need to change for each environment:

variable "tag_service" {
	type = string
	description = "the service tag to link the resource to the service"
	default = "new_service"
}
variable "tag_environment" {
	type = string
	description = "the environment tag (DEV, PROD, QA)"
	default = "DEV"
}

variable "log_bucket_arn" {
	type = string
	description = "the arn for the log bucket for this environment"
	default = "ENTER A VALID ARN HERE MUST BE IN THE CORRECT AWS ACCOUNT"
}

## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}

variable "org_parent_id" {
	type = string
	description = "The id of the organization"
	default = "ENTER THE ID OF YOUR ORGANIZATION ex:r-227c"
}