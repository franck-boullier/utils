# Overview:

This is where we store the terraform script to create the resources we need for a centralized bucket to store the terraform states for all the resources that we will create for a given environment.

This is a Special service that works for the whole organization.

We create an AWS account for each environment (DEV, QA, PROD).

These are the Terraform scripts that we need to create the resources we need for the service.

These scripts must first be built and tested in the AWS DEV environement before we can deploy the resources into production.

# Step by Step Instructions:

- Define the infrastructure you need.
- Create the infrastructure in the AWS account for the DEV environment for this service. We do this with Terraform scripts.
- Store all the Terraform scripts that we need to create the resources we need for the new service under the `service-accounts` folder.
- Create a PR to have these Terraform scripts reviewed and validated.
- Test that the service is working as expected in the DEV environment.
- Create the infrastructure (using the Terraform scripts) in the QA environment.
- Deploy the code for the service in the QA environment.
- Test that the service is working as expected in the QA environment.
- Create the infrastructure (using the Terraform scripts) in the PROD environment.
- Deploy the code for the service in the PROD environment.
- Create the CI/CD resources and scripts that we need to automate future deployments and upgrade to this service.

The terraform state for the resources associated to these terraform scripts will be stored in the file `tfstate.tf` located in the TOP account for the organization.

# Pre-requisite:

In order for this to work you need to have:
- A machine with the following software:
  - git
  - AWS CLI
  - Terraform
- On the machine, you must have configured the AWS credentials that allow us to create the resources in the AWS Account `terraform-account`.
- Run the scripts in the `top-account` folder. See the README.md in that folder for more information.
This should have created:
  - The OU
  - The AWS Account.

# Important Information:

## Conventions:

- Variables that we need in terraform scripts are using lower cases and `_` (ex: `xxx_yyy_zzz`). 
We are NOT using `-` to avoid compatibility issues. 
We are NOT using the **camelCase** standard `xxxYyyZzz` (we don NOT use capital case in our variables).
This is to be consistent with terraform conventions too.

## Definitions:

- **organization:** An AWS organization where all the resources will be created.
- **terraform-account:** An AWS Account in the organization where we create the bucket to store tfstate for all the resources that we will create for that organization.
- **terraform_state_bucket:** The bucket that we need to store tfstate for all the resources that we will create. This bucket is created in the terraform-account.

# What we will create in the AWS Service Accounts:

In the AWS account for each environment, we will:

## To facilitate Terraformer scripts:

- Create a role `terraformer_role` that can be assumed by the anyone using the role `terraformer` in the TOP Account.

## To store logs:

- Create a role `log_service_role` and allow the following services to assume that role:
    - S3 ("s3.amazonaws.com").
    - KMS ("kms.amazonaws.com").
- Create a bucket `logs_bucket` to store all the logs associated to this AWS account.
This bucket
    - Is encrypted with the default AWS S3 KMS key.
    - Store all the version of each objects.
    - Cannot be destroyed.
    - Has lifecyle rules for all objects with the `logs\` prefix:
        - after 30 days, move to the IA storage class.
        - after 60 days, move objects to the Glacier storage class.
- Make sure that the bucket `logs_bucket` cannot be public.
- Create a policy `logs_bucket_policy` to allow the role `logs_service_role` to write into the `logs_bucket` under the `logs` folder.

## To store the Raw data:

- Create an IAM Group `raw_data_uploader_group` <-- Do we really need this group???
- Create a role `raw_data_uploader_role` that allows other principals to interact with the follwing services
    - s3.amazonaws.com
    - transfer.amazonaws.com
- Create a bucket `raw_data_bucket` to store the raw data that will be sent by the 3rd party.
This bucket
    - Is encrypted with the default AWS S3 KMS key.
    - Store all the version of each objects.
    - Cannot be destroyed.
    - Uses the `logs\raw_data_bucket` folder in the `logs_bucket` for logging.
    - Has lifecyle rules for all objects:
        - after 30 days, move to the IA storage class.
        - after 60 days, move objects to the Glacier storage class.
- Make sure that the bucket `raw_data_bucket` cannot be public.    
- Create a policy `raw_data_bucket_policy` that allows the users assuming the role `raw_data_uploader_role` to read and write in the `raw_data_bucket`.

## The Transfer Server (SFTP Server):

- Create a role `cloudwatch_role` to allow interaction with Cloudwatch for all the service. This will allow us to see everything that's happening in Cloudwatch.
- Create a policy `cloudwatch_policy` to enable the role `cloudwatch_role` to write logs in cloudwatch
- Create the Transfer Server `edentred-sftp_server` that will:
    - Be service Managed (new users are created in the AWS console).
    - Be Public
    - Log events on Cloudwatch using the role `cloudwatch-transfer_role`.

## To store the Processed Data:

- Create an IAM Group `processed_data_access_group`
- Create a role `processed_data_access_role` that can be assumed by users in the group `processed_data_access_group`.
- Create a policy `processed_data_access_policy` to limit the IAM interactions only to the group `processed_data_access_role`.
- Attach the policy `processed_data_access_policy` to the role `processed_data_access_role`.
- Create a bucket `processed_data_bucket` to store the processed data after ETL has been done.
This bucket
    - Is encrypted with the default AWS S3 KMS key.
    - Store all the version of each objects.
    - Cannot be destroyed.
    - Uses the `logs\processed_data_bucket` folder in the `logs_bucket` for logging.
    - Has lifecyle rules for all objects:
        - after 30 days, move to the IA storage class.
        - after 60 days, move objects to the Glacier storage class.
- Make sure that the bucket `processed_data_bucket` cannot be public.    
- Create a policy `processed_data_bucket_access_policy` that allows the users assuming the role `processed_data_access_role` to read and write in the `processed_data_bucket`.

## Route 53:


# How to Create a SFTP User:

- Log in to the AWS console as a member of the group `transfer-server-user-mangement_group`
- Go to the Transfer server `edentred-sftp_server`.
- Create a new user. **You need the public SSH key for that user**
- Make sure that the user will
    - Use the bucket `raw_data_bucket`.
    - Use the role `raw_data_uploader_role`.
    - Use the prefix `ticketxpress-events`.
    - Is restricted.

# The Tests to check that all is working as intended:

## Test the SFTP Server:

You first need to create a 


## Test the Cloudwatch Logs:






# How it works:

Update the variables in the file `vars.tf`

A resource must be unique in terraform. We need to replace the string `new_service` with a unique name for your new service in the foloowing files:
    - `main.tf`
    - `vars.tf`
    - `output.tf`

Run the terraform scripts.

# Future Developments and TO DOs:

## DONE - Need Testing
- Block ALL public access in all scenarios.
The code is:
resource "aws_s3_account_public_access_block" "example" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
- No need for the group `raw_data_uploader_group`. Remove this.
- Update the role `raw_data_uploader_role` to make sure that it includes the correct services (S3 and transfer).
- We do NOT need the policy `raw_data_uploader_policy`. Tests show that SFTP works without this policy. Remove this in the Terraform script.
- Create the `cloudwatch-transfer_role` to allow writing cloudwatch logs for the transfer service.
- Create a `cloudwatch_policy` to allow writing log streams.
- Attach the `cloudwatch_policy` to the `cloudwatch-transfer_role`.
- Create the Transfer service `edentred-sftp_server`.
    - Test that it is possible to upload.
    - Test that it is possible to download.
    - Test that you only see a root folder in the SFTP.
    - Test that you see all uploads in the `ticketxpress-events` folder.
    - Test that you cannot delete an uploaded object in the SFTP.

## NOT done - Need to write the code:

- Create a CNAME for the Service.
- Create a SNS topic for each time a new file is uploaded
- Create an email notification for each time a new file is uploaded.
- Create a ETL job each time a new file is uploaded.
- Create a SNS topic for each time the ETL job fails.
- Create a set of automated tests to check that the file is acceptable.
- Create a SNS topic for each time the file does NOT pass the automated tests.
- Create a group `transfer-server-user-mangement_group` for user allowed to managed new user in the transfer service ``
- Create a policy to restrict

- Do we need the policy `processed_data_access_policy`? This seems unecessary...
- Use the terraform backend to store terraform state. This is not working now because the accounts are not allowed to access the terraform bucket and DynamoDb table.
- Enable Object Lock in the `raw_data_bucket` to Store objects using a write-once-read-many (WORM) model to help you prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely.
- Read the article [Cross Account Resource creation using Terraform](https://medium.com/@manoj.bhagwat60/cross-account-resource-creation-using-terraform-8d846dbcbda) and create a `provider.tf` file to list the different provider that need to be used for each resource creation.


- Alter the script and set permissions so this can be run as a user assuming the `terraformer` role in the Top account.
- Use differente custom KMS keys to encrypt each of the S3 buckets instead of the default KMS S3 key.