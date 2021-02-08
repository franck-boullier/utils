/*
# Output after the terraform Key for the `terraform-state` bucket is created:
output "terraform_state_key_arn" {
  value = aws_kms_key.terraform_state_key.arn
  description = "The ARN of the Terraform State Key"
}

# Output after the `terraform_state_bucke` bucket is created
output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "The ARN of the Terraform State bucket"
}

# Output after the DynamoDb table is created
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table that stores the locks"
}
*/