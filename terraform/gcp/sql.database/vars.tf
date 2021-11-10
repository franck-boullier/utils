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

# The name of the DB instance
variable "db_instance_name" {
  type        = string
  description = " The name of the DB instance"
}

# The size (tier) of the DB instance
variable "db_instance_tier" {
  type        = string
  description = "The Size (tier) of the DB instance"
  default = "db-f1-micro"
}

# The Database engine type
variable "db_instance_engine" {
  type        = string
  description = "The Database engine that we use"
  default = "MYSQL_5_7"
}

# The Database Instance Availablitiy type:
variable "db_instance_availability_type" {
  type        = string
  description = "The Database instance availability type"
  default = "ZONAL"
}

# Make sure that the Database instance has a public IPV4 address:
variable "db_instance_ip_v4_enabled" {
  type        = string
  description = "The Database instance has a public IPV4 address"
  default = "true"
}

# The Database Instance Autorized Connections :
variable "db_instance_autorized_connections" {
  type        = string
  description = "Connection are authorized from that CIDR block"
}

# The Database Instance default Timezone:
variable "db_instance_default_timezone" {
  type        = string
  description = "Specify values as time zone offsets, from -12:59 to +13:00. Leading zeros required."
  default = "+08:00"
}

# The Database Instance requires SSL encryption to connect:
variable "db_instance_require_ssl" {
  type        = string
  description = "Whether SSL connections over IP are enforced or not."
  default = "true"
}

# The Database Instance delete protection :
variable "db_instance_deletion_protection" {
  type        = string
  description = "Do we protect the database instance from deletion"
  default = "true"
}

# The Database Charset:
variable "db_charset" {
  type        = string
  description = "The Database Charset that we use"
  default = "utf8mb4"
}

# The Database Collation:
variable "db_collation" {
  type        = string
  description = "The Database collation that we use"
  default = "utf8mb4_unicode_520_ci"
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

variable "root_password" {
  type        = string
  description = "the root password for the database instance"
}

variable "database_user_1_password" {
  type        = string
  description = "the password for the database user `database.user.1`"
}