# Overview:

This is where we store the terraform script to create the resources we need for a service to:
- expose a SFTP server.
- Safely store Files.
- Make sure that all is secure.
- Prepare data for data injection.

We create an AWS account for each environment (DEV, QA, PROD).

**WARNING**
The OU and accounts have already been created. We need to import these resources into terraform to avoid future issues.
**END WARNING**

You will have to interact with 4 different AWS accounts:
- AWS Top Account: the AWS account where you are managing your organization
- AWS Service Accounts:
At least 3 different account for each environment:
    - DEV.
    - QA.
    - PROD.
    - DEMO (Optional).

We have 2 set of Terraform scripts that we need to run:

- The Terraform scripts in to create the OU and AWS accounts we need for these services.
These are always the same, we just have to change a few variables.
**WARNING**
The OU and accounts have already been created. We need to import these resources into terraform to avoid future issues.
**END WARNING**
- The Terraform scripts that we need to create the resources we need for the service.
These scripts must first be built and tested in the AWS DEV environement before we can deploy the resources into production.

# Step by Step Instructions:

- Clone the repository on your machine and cd to the folder `data_ingestion`
**WARNING**
The OU and accounts have already been created. We need to import these resources into terraform to avoid future issues.

- Run the script that are in the folder `top-account` as an AWS user who can create resources in your TOP Account.
This should create:
    - A new OU for the new service.
    - at least 3 new AWS accounts (one for each environment: DEV, QA, PROD and optionally DEMO).
**END WARNING**

- Prepare the infrastructure in the AWS account for the DEV environment for this service.
- Store all the Terraform scripts that we need to create the resources we need for the new service under the `service-accounts` folder.
- Create a PR to have these Terraform scripts reviewed and validated.
- Test that the service is working as expected in the DEV environment.
- Create the infrastructure (using the Terraform scripts) in the QA environment.
- Deploy the code for the service in the QA environment.
- Test that the service is working as expected in the QA environment.
- Create the infrastructure (using the Terraform scripts) in the PROD environment.
- Deploy the code for the service in the PROD environment.
- Create the CI/CD resources and scripts that we need to automate future deployments and upgrade to this service.

The terraform state for the resources associated to these terraform scripts will be stored in the file `terraform.tfstate` located in the Account that manages the terraform backend for each environment (DEC, QA and PROD).

# Pre-requisite:

In order for this to work you need to have:
- A machine with the following software:
  - git
  - AWS CLI
  - Terraform
- On the machine, you must have configured the AWS credentials that allow us to create the resources in the AWS Account `data-ingestion` for the correct environment.

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

## What we will create in the Service AWS account:

See the `README.md` file in the `service-accounts` folder.

# QA: 

## Why do we have several AWS accounts?

We have several AWS accounts because we are creating the resources in one AWS account (`service-account`) for each environment and storing tfstate in another AWS account (`terraform-account`).

More information:

- [Terraform - Can you keep a secret](https://cloudonaut.io/terraform-can-you-keep-a-secret/)
- [One Terraform state S3 bucket for all my AWS accounts](https://www.padok.fr/en/blog/terraform-s3-bucket-aws)

## Where do we find the information about the `terraform-account`?

You should have created a service `terraform_backend` where you will manage all the terraform states.

## What happens if the IAM role "terraformer_role" is not created in the service-account?

There will be an error while running the terraform script.