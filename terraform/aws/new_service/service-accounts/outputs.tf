# Output after the KMS Key for the `log_bucket` bucket is created:
output "log_bucket_key_arn" {
  value = aws_kms_key.log_bucket_key.arn
  description = "The ARN of the Log Bucket Key"
}

# Output after the `log_bucket` bucket is created:
output "log_bucket_arn" {
  value       = aws_s3_bucket.log_bucket.arn
  description = "The ARN of the log bucket"
}