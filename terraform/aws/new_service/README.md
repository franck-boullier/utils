# Overview:

This is where we store the terraform scripts to create the infrastructure needed for a new service `new_service` for your organization `organization`.
This script shall be run as an AWS user who has the permissions to create resources in the AWS account `terraform-account`.

## Conventions:

- Variables that we need in terraform scripts are using lower cases and `_` (ex: `xxx_yyy_zzz`). 
We are NOT using `-` to avoid compatibility issues. 
We are NOT using the **camelCase** standard `xxxYyyZzz` (we don NOT use capital case in our variables).
This is to be consistent with terraform conventions too.

## Important definitions:

- **organization:** An AWS organization where all the resources will be created.
- **service:** A technological solution that we need.
- **service-account:** An AWS Account where we create the resources that we need for the service.
- **terraform-account:** An AWS Account where we create the bucket to store tfstate.
- **tfstate:** the state of the creation of the resources in the service account.
- **terraform_state_bucket:** The bucket that we need to store tfstate. This bucket is created in the terraform-account.
- **terraformer:** An IAM role in the service-account  

## What we need:

- The id of the OU where the new service will be created. This ID is stored in the variable `org_parent_id` in the `vars.tf` file.
- AWS credentials that allow us to create the resources 
  - OU and AWS account in the organization.
  - Policy in the AWS Account `terraform-account`.
- A bucket `terraform_state_bucket` to store the terraform state file `tfstate.tf` in a sub folder `terraform_state/new_service/tfstate.tf`.
- A dynamoDB table `terraform_locks` to store the locks when we modify the file `tfstate.tf`.

## What we will create:

### In the Organization:

- A new OU `new_service`
- 3 new AWS service-account (one for each environment)
    - `new_service_dev`
    - `new_service_qa`
    - `new_service_prod`

### In Each of the AWS Accounts:

In each of the AWS Accounts associated to the new service, we will create:

- A Bucket `new_service_logs` to store the logs of all that is happening for this new service.
- A role `terraformer`.
- All the resources we need to perform the service that we need.

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

## In the `terraform-account`:

- A KMS key `xxxx` in the `terraform-account` so we can encrypt the `terraform_state_bucket` bucket.
- A dedicated `terraform_state_bucket` S3 bucket in the `terraform-account`.
- A Dynamo DB table `xxx` in the `terraform-account` to record the locks when we run terraform. 
- A `terraform_state_bucket_policy` S3 policy for the bucket `terraform_state_bucket` in the `terraform-account`.

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