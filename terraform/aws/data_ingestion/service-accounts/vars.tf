# Variable that you need to change for each environment:

variable "tag_environment" {
	type = string
	description = "The environment tag (DEV, PROD, QA)"
	default = "DEV"
}

variable "sender_email_for_notifications" {
	type = string
	description = "The email that we are using as a sender for the notification messages"
	default = "notification.sftp.edenred.dev@uniqgift.com"
}

variable "sender_name_for_notifications" {
	type = string
	description = "The name that we are using as a sender for the notification messages"
	default = "No Reply - Notification from Uniqgift SFTP Server"
}

variable "recipient_email_for_notifications" {
	type = string
	description = "The email that we are using as a recipient to receive the notification messages"
	default = "franck.boullier@uniqgift.com"
}
variable "subject_for_notifications_new_file" {
	type = string
	description = "The subject line in the email we send for notification messages of new file uploaded"
	default = "A New File has been uploaded to the Data Ingestion Engine - TicketXpress"
}

# variables you have to change for each service

variable "tag_service" {
	type = string
	description = "The service tag to link the resource to the service"
	default = "data_ingestion"
}

variable "logs_target_prefix_raw_data_bucket" {
	type = string
	description = "The folder where we store the logs for the raw_data_bucket"
	default = "logs/raw_data_bucket/"
}

variable "logs_target_prefix_processed_data_bucket" {
	type = string
	description = "The folder where we store the logs for the processed_data_bucket"
	default = "logs/processed_data_bucket/"
}

variable "logs_target_prefix_all_data_bucket" {
	type = string
	description = "The folder where we store the logs for the all_data_bucket"
	default = "logs/all_data_bucket/"
}
## The below variable should not be changed unless you understand what you're doing.

variable "region" {
	type = string
	description = "Name of region where you want to create resources"
	default = "ap-southeast-1"
}