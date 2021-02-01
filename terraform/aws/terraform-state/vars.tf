variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}

variable "tag-environment" {
	type = string
	description = "the environment tag (DEV, PROD, QA)"
	default = "DEV"
}

variable "tag-service" {
	type = string
	description = "the service tag to link the resource to the service"
	default = "terraform-state"
}