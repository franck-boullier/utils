# Overview:

**THIS DOCUMENTATION IS WORK IN PROGRESS**

This is where we store the Terraform scripts that need to be run in the AWS top account or as a user who can assume the role `terraformer` in the Top Account.

We have configured a dedicated bucket `organisation_backend_state_terraform` to store the Terraform states for this specific service.
- The Terraform script will first read the state of the resource it is asked to create from that bucket.
- If the resource does NOT exist, then the resource is created.
- If the resource DOES exist alerady, the the script aborts and does NOT try to re-create that same resource again.

# How to run this:

You should run this script as a user who is a member of the group `terraformer` in the TOP Account for your organisation.

## Pre-requisite:

- Make sure that the parameters for the terraform backend are correct in the file `backend.tf`.
- Verify the variables in the file `vars.fs`.
- Make sure that the values are corrects in the `main.tf` file.
    - name for the AWS account for the DEV, QA, and PROD environment
    - email address associated to the AWS account for the DEV, QA, and PROD environment
 
## To create the OU and accounts:

In the `top-account` folder run:
```
terraform init
```
There should be no error message.
If there is no error message, you can run
```
terraform validate
```
There should be no error message.
If there is no error message, you can run
```
terraform plan
```
There should be no error message and you terraform should tell you that it's about to create 4 resources

If all is in order, you can run
```
terraform apply
```
Review the plan one last time and when prompted, enter `Yes`.
The resources are created.

## Verify that the resources have been created

Go to the TOP account and check that the new OU and the 3 new accounts have been created as expected: [AWS organisation](https://console.aws.amazon.com/organisations/home). You must be logged in as a user who can see the organisation structure.

# Prepare the DEV Account:

We grant access using the [SSO access for our organisation](https://ap-southeast-1.console.aws.amazon.com/singlesignon/home?region=ap-southeast-1#/dashboard).

## `terraformer` Access:

We need to create the permissions for the `terraformer` role in the DEV Account.

In the TOP Account, under SSO management add a new set of permission `terraformer_terraform_backend`. The basic policy for the `terraformer-terraform_backend` role is available in the file `og-default-terraformer-policy.json` in the `service-accounts` folder for the service `terraform_backend`.

Add the user in charge of creating the infrastructure for the service to the AWS DEV account and grant him/her the default set of `terraformer-terraform_backend` permission from the file `og-default-terraformer-policy.json`.

## Administrator Access:

In the TOP Account, under SSO management add the user in charge of creating the infrastructure for the service and grant him the  `AdministratorAccess` permissions.

This will allow the developer maximum access to the account to:
- Create the resources associated to the service.
- Create set of permission `og-terraform_backend-terraformer-policy.json` that will be used to create the resources in the QA and PROD account.
We are NOT using the `AdministratorAccess` permissions in the QA and DEV environments.

# Prepare the QA AWS Account:

In the TOP Account, under SSO management add a new set of permission `terraformer_terraform_backend`. The policy for the `terraformer-terraform_backend` role is available in the file `og-terraform_backend-terraformer-policy.json` in the `service-accounts` folder for the service `terraform_backend`.

Add the user in charge of creating the infrastructure for the service to the AWS QA account and grant him/her the default set of `terraformer-terraform_backend` permission from the file `og-terraform_backend-terraformer-policy.json`

# Prepare the PROD AWS Account:

In the TOP Account, under SSO management add a new set of permission `terraformer_terraform_backend`. The policy for the `terraformer-terraform_backend` role is available in the file `og-terraform_backend-terraformer-policy.json` in the `service-accounts` folder for the service `terraform_backend`.

Add the user in charge of creating the infrastructure for the service to the AWS PROD account and grant him/her the default set of `terraformer-terraform_backend` permission from the file `og-terraform_backend-terraformer-policy.json`

# Future Developments and TO DOs:

- Modify the script to only create one account at a time:
  - First the OU and the DEV account.
  - Then the QA account (using the same OU as for the DEV).
  - Then the PROD account (using the same OU as for the DEV).