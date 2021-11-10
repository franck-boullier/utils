# Overview:

This is where we store the terraform script to create the resources we need for a centralized bucket to store the terraform states for all the resources that we will create for a given environment.

This is a Special service that works for the whole organization.

We create an AWS account for each environment (DEV, QA, PROD).

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
- The Terraform scripts that we need to create the resources we need for the service.
These scripts must first be built and tested in the AWS DEV environement before we can deploy the resources into production.

# Step by Step Instructions:

- Clone the repository on your machine and cd to the folder `terraform_backend`
- Run the script that are in the folder `top-account` as an AWS user who can create resources in your TOP Account.
This should create:
    - A new OU for the new service.
    - at least 3 new AWS accounts (one for each environment: DEV, QA, PROD and optionally DEMO).
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

The terraform state for the resources associated to these terraform scripts will be stored in the file `tfstate.tf` located in the TOP account for the organization.

# Pre-requisite:

In order for this to work you need to have:
- A machine with the following software:
  - git
  - AWS CLI
  - Terraform
- On the machine, you must have configured the AWS credentials that allow us to create the resources in the AWS Account `terraform-account`.

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

## What we will create in the AWS account:

- A group `terraformer` that grant the permission to assume the role `terraformer` in the account where you need the resources created.
This group is used to manage the individual users who need to perform terraform related tasks.
- A KMS key `log_bucket_key` so we can encrypt the bucket `log_bucket_xxx`.
- A Bucket `log_bucket_xxx` to store the logs of all that is happening in the account.
- A KMS key `terraform_state_bucket_key` so we can encrypt the bucket `terraform_state_bucket`.
- A dedicated `terraform_state_bucket_xxx` S3 bucket.
- A Dynamo DB table `xxx` in the `terraform-account`. 







# How it works:

Update the variables in the file `vars.tf`

A resource must be unique in terraform. We need to replace the string `new_service` with a unique name for your new service in the foloowing files:
    - `main.tf`
    - `vars.tf`
    - `output.tf`

Run the terraform scripts.

# What we want to do:



# The things we need:

## In the `service`-account`:

- A KMS key `xxxx` in the `service-account` so we can encrypt the `log-XXX` bucket.
- A dedicated `log-XXX` S3 bucket in the `service-account`.
- A `terraformer-policy`: the IAM policy in the `service-account`.
- A `terraformer` IAM role in the `service-account`.

# Permissions and credentials:

We need to create IAM policies for the `service-account` and `terraform-account`.

## In the service-account:

We have created set of IAM policies `terraformer-policy` these perissions can be attached to:
- An IAM user.
- An IAM role.
- An SSO user.

## In the terraform-account:

These permissions are available in the file `terraformer-role-policy.json` in this repository.

These are the policies that will allow a user, or a user assuming a role to perform the terraform activities.
The policy will all the `terraformer` to
- manage IAM roles.
- manage S3 buckets.
- manage Dynamo DB objects.
- manage KMS objects.

# Bucket Policies:

We need to make sure that the bucket we have created can be accessed by other accounts if needed.

# The Variables:

We are using the following varialbes (in the `vars.tf` file):
- `region`: the Region where the resources will be created
- `tag-environment`: either DEV, QA or PROD
- `tag-service`: the service that will use this resource.

# The Outputs:

We will get the following outputs that can be used elsewhere:
- 

# How to use this script:

- Run the script as an AWS user in the account where you need the S3 bucket to be created.

# QA: 

## Why do we have two AWS accounts?

We have two AWS accounts because we are creating the resources in one AWS account (`service-account`) and storing tfstate in another AWS account (`terraform-account`).

More information:

- [Terraform - Can you keep a secret](https://cloudonaut.io/terraform-can-you-keep-a-secret/)
- [One Terraform state S3 bucket for all my AWS accounts](https://www.padok.fr/en/blog/terraform-s3-bucket-aws)

## Where do we find the information about the `terraform-account`?

You should have created a `terraform-account` where you will manage all the terraform states.

## What happens if the IAM role "terraformer" is not created in the service-account?

There will be an error while running the terraform script.