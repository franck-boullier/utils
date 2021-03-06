# Output after the OU is created:
output "terraform_backend_ou_arn" {
  value = aws_organizations_organizational_unit.ou_new_service.arn
  description = "The ARN of the OU for this new service"
}

output "terraform_backend_ou_id" {
  value = aws_organizations_organizational_unit.ou_new_service.id
  description = "The ARN of the OU for this new service"
}

# Output after the Accounts are created:
output "terraform_backend_dev_account_arn" {
  value = aws_organizations_account.dev_account.arn
  description = "The ARN of the 1st account that has been created"
}

output "terraform_backend_qa_account_arn" {
  value = aws_organizations_account.qa_account.arn
  description = "The ARN of the 2nd account that has been created"
}

output "terraform_backend_prod_account_arn" {
  value = aws_organizations_account.prod_account.arn
  description = "The ARN of the 3rd account that has been created"
}