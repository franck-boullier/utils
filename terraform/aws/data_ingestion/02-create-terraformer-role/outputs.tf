# Output after the `terraformer_role` is created
output "terraformer_role_arn" {
  value       = aws_iam_role.terraformer_role.arn
  description = "The ARN of the terrraformer role"
}