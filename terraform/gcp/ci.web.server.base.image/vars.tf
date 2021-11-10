# Variable that we need.
# We can update the value for these variables in the `variables.tfvars` file

# GCP authentication file
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}

# The GCP project name
variable "gcp_project" {
  type        = string
  description = "GCP project name"
}

# The terraformer account that we use
variable "terraformer_service_account" {
  type        = string
  description = "the email address associated to the terraformer service account"
}

# The Compute Instance Name prefix
variable "ci_machine_name_prefix" {
  type        = string
  description = "The Compute Instance name prefix"
  default = "web-server"
}

# The Compute Instance Description
variable "ci_machine_description" {
  type        = string
  description = "A description for the Compute Instance"
  default = "A web server that can interact with Bitbucket"
}
# The Compute Instance Machine Type
variable "ci_machine_type" {
  type        = string
  description = "The Compute Instance Machine Type"
  default = "n1-standard-1"
}

# The Compute Instance Machine Image Project
variable "ci_machine_image_project" {
  type        = string
  description = "The Compute Instance Machine Image Project"
  default = "ubuntu-os-cloud"
}

# The Compute Instance Machine Image
variable "ci_machine_image" {
  type        = string
  description = "The Compute Instance Machine Image"
  default = "ubuntu-minimal-2004-focal-v20210325"
}

# The Compute Instance Startup Script
variable "ci_startup_script" {
  type        = string
  description = "The Compute Instance Startup Script"
}

# The Compute Instance Zone A
variable "ci_zone_a" {
  type        = string
  description = "The Compute Instance Zone A"
  default = "asia-southeast1-a"
}

# The Compute Instance Zone B
variable "ci_zone_b" {
  type        = string
  description = "The Compute Instance Zone B"
  default = "asia-southeast1-b"
}

# The Compute Instance Zone C
variable "ci_zone_c" {
  type        = string
  description = "The Compute Instance Zone C"
  default = "asia-southeast1-c"
}

# The labels/tags
variable "label_environment" {
	type = string
	description = "The environment label (DEV, PROD, QA)"
}

variable "label_service" {
	type = string
	description = "The service label to link the resource to the service"
}

## The below variable should not be changed unless you understand what you're doing.
# define GCP region

variable "gcp_region" {
  type        = string
  description = "GCP region"
}
