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

# Output after the `raw_data_bucket` is created:
output "raw_data_bucket_arn" {
  value       = aws_s3_bucket.raw_data_bucket.arn
  description = "The name of the bucket to store the Raw data after upload"
}

output "raw_data_bucket_id" {
  value       = aws_s3_bucket.raw_data_bucket.id
  description = "The name of the bucket to store the Raw data after upload"
}

# Output after the transfer server is created:
output "edentred-sftp_server_endpoint" {
  value       = aws_transfer_server.edentred-sftp_server.endpoint
  description = "The endpoint where the SFTP server is accessible"
}

# Output after the `processed_data_bucket` is created:
output "processed_data_bucket_arn" {
  value       = aws_s3_bucket.processed_data_bucket.arn
  description = "The name of the bucket to store the Processed data after upload"
}

output "processed_data_bucket_id" {
  value       = aws_s3_bucket.processed_data_bucket.id
  description = "The name of the bucket to store the Processed data after upload"
}
