# Overview:

This step is NOT entirely done with Terraform.

# Prepare the DEV Account:

## Create SSO Access to this account:

We need to grant Administrator right to a designated person in order to continue the configuration.

This is done in the TOP account for your organization (the account that has access to SSO configuration).

We grant access using the [SSO access for our organisation](https://ap-southeast-1.console.aws.amazon.com/singlesignon/home?region=ap-southeast-1#/dashboard).

Grant that user the `AdministratorAccess` permissions in the DEV account.

This will allow the designated person to have maximum access to the account to manually create the resources associated to the service in the AWS console if needed.

**We are NOT using the `AdministratorAccess` permissions in the QA and DEV environments.**

## Create the resources in the `terraformed` account:

You can do this using the Terraform scripts in this folder. This is to allow the central `terraformer` account to manage the resources in the `terraformed` account in a specific environment (DEV, QA or PROD).

These scripts shall be run by an IAM user `john.doe` who is allowed to create IAM roles and policies in the `terraformed` AWS account.

- Create the role `terraformer.role` in the `terraformed` account.
Trust relationship with the `terraformer` account (ALL IAM users in the `terraformer` account).
- Create a policy `terraformer.policy` to allow the creation of resources in the `terraformed` account.
Make sure that this allow the creation of ALL the resources that you will need.
- Attach the policy `terraformer.policy` to the role `terraformer.role`.

# Update the resources in the `terraformer` account:

- Update the role `remote.terraformer` in the `terraformer` account: add the ARN for the role `terraformer.role` that you have created in the `terraformed.account` to the list of trusted relationships for this role.

# Future developments and TO DOs:

- See if we can automate some of these tasks.
- Improve the documention of the `terraformer` account to include details about:
    - The `remote.terraformer` role
    - The `remote.terraformer.dynamodb` policy
    - The `remote.terraformer.s3` policy
