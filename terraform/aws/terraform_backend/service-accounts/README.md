# Overview:

This is where we store the terraform script to create the resources we need for a centralized bucket to store the terraform states for all the resources that we will create for a given environment (the Terraform Backend service).

This is a Special service that works for the whole organization.

We create an AWS account for each environment (DEV, QA, PROD).

These are the Terraform scripts that we need to create the resources we need for the service.

These scripts must first be built and tested in the AWS DEV environment before we can deploy the resources into production.

## High level overview of the methodology:

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

The terraform state for the resources associated to these terraform scripts will be stored:
- First locally
- Then once the `terraform_backend_bucket` is created in the account for the relevant environment, we will move the `terraform.tfstate` file to this bucket `terraform_backend_bucket`.

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

# Pre-requisite:

In order for this to work you need to have:
- A machine with the following software:
  - git
  - AWS CLI
  - Terraform
- An AWS account dedicated to this service.
- On the machine, you must have configured the AWS credentials that allow us to create the resources in the AWS Account `terraform-account` for the environment.
- The scripts in the `top-account` folder have been run with no errors. See the README.md in that folder for more information.
- Make sure that the file `backend.tf` is empty (or does not exist) in the folder `service-accounts`.
- Verify the variables in the file `vars.fs`.
    - `"tag_environment"` variable.

# What we will create in the AWS account:

In the AWS account for each environment, we will do the following:

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
- Create a S3 Bucket policy `logs_bucket_policy` to allow the role `logs_service_role` to write into the `logs_bucket` under the `logs` folder.

## To store the Terraform States:

### The `terraform_backend` bucket:

- Create a bucket `terraform_state_bucket` to store the terraform state of all the resources that we will create for the environment.
This bucket
    - Is encrypted with the default AWS S3 KMS key.
    - Store all the version of each objects.
    - Cannot be destroyed.
    - Uses the `logs/terraform_state_bucket/` folder in the `logs_bucket` for logging.
- Make sure that the bucket `terraform_state_bucket` cannot be public.
- Create a S3 bucket policy `terraform_state_bucket_policy` to allow Read and write into the `terraform_state_bucket` by 
  - the `terraformer_role`
  - The TOP Account 553662416064
  - The other accounts where will will run terraform.
- Create a Dynamo DB table `terraform_locks` to store the terraform locks.
- Create an IAM policy `terraformer_role_terraform_locks_policy` to allow interactions with the table `terraform_locks` by:
  - the `terraformer_role`
  - The TOP Account 553662416064
  - The other accounts where will will run terraform.
- Attach the policy `terraformer_role_terraform_locks_policy` to the `terraformer_role`.

# How it works:

To create the resources needed for the service, we will:
- Run the commands `terraform init` and `terraform apply` in the `service-account` folder. This will create the bucket we need to store the terraform states.
- Find the name of the `terraform_backend_bucket` that was created in the relevant environment.
- Update the "bucket" parameter in the file `backend.tf.final` with the ID of the newly created bucket:
  - in the `top-account` folder.
  - in the `service-account` folder.
- Rename the file `backend.tf.final` to `backend.tf`:
  - in the `top-account` folder.
  - in the `service-account` folder.
- Run the command `terraform init` and `terraform apply` one more time. This will move the terraform state for these accounts to the `terraform_backend_bucket`. Next time terraform is run, it will:
  - First read the state of the resource it is asked to create from that bucket.
  - If the resource does NOT exist, then the resource is created.
  - If the resource DOES exist already, the the script will apply the modification to the resources or do nothing.

You should run the terraform script:
- From the folder `service-accounts`
- As an AWS CLI user who:
  - Is a member of the group `terraformer` in the AWS Account dedicated to that service and environment.

  OR 
  - Can assume the role `terraformer_role` in the AWS account dedicated to this service and environment.

  OR
  - Is an administrator for the AWS account where the resources are created.

 [This part needs more explanation]

The permission for the group `terraformer` and the role `terraformer_role` in the service-account are documented in the file `terraformer-policy.json`.

[End - This part needs more explanation]

# Tips and Tricks:

Use the [IAM Policy Simulator](https://policysim.aws.amazon.com/home/index.jsp?) to debug permission issues.

# Future Developments and TO DOs:

- Remove to kms service from the `terraformer_role`

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