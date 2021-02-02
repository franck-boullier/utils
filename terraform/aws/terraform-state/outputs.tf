output "terraform_state_key_arn" {
  value = aws_kms_key.terraform_state_key.arn
  description = "The ARN of the Terraform State Key"
}

output "log_bucket_key_arn" {
  value = aws_kms_key.log_bucket_key.arn
  description = "The ARN of the Terraform State Key"
}

output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "The ARN of the Terraform State bucket"
}

output "log_bucket_arn" {
  value       = aws_s3_bucket.log_bucket.arn
  description = "The ARN of the log bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table that stores the locks"
}