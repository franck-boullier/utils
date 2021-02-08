# Output after the `terraformer_role` is created
output "terraformer_role_arn" {
  value       = aws_iam_role.terraformer_role.arn
  description = "The ARN of the terrraformer role"
}

# Output after the `logs_bucket` is created:
output "logs_bucket_arn" {
  value       = aws_s3_bucket.logs_bucket.arn
  description = "The ARN of the logs bucket"
}

output "logs_bucket_id" {
  value       = aws_s3_bucket.logs_bucket.id
  description = "The name of the logs bucket"
}

# Output after the `terraform_state_bucket` is created:
output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "The name of the logs bucket"
}

# Output after the `terraform_state_bucket` is created:
output "terraform_state_bucket_id" {
  value       = aws_s3_bucket.terraform_state_bucket.id
  description = "The name of the logs bucket"
}

# Output after the DynamoDb table is created
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table that stores the locks"
}