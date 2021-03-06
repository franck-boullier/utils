# Output after the OU is created:
output "new_service_ou_arn" {
  value = aws_organizations_organizational_unit.ou_new_service.arn
  description = "The ARN of the OU for this new service"
}

output "new_service_ou_id" {
  value = aws_organizations_organizational_unit.ou_new_service.id
  description = "The ARN of the OU for this new service"
}

# Output after the Accounts are created:
output "new_service_dev_account_arn" {
  value = aws_organizations_account.account[0].arn
  description = "The ARN of the 1st account that has been created"
}

output "new_service_qa_account_arn" {
  value = aws_organizations_account.account[1].arn
  description = "The ARN of the 2nd account that has been created"
}

output "new_service_prod_account_arn" {
  value = aws_organizations_account.account[2].arn
  description = "The ARN of the 3rd account that has been created"
}