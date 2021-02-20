# Overview:

**THIS DOCUMENTATION IS WORK IN PROGRESS**

This is where we store the Terraform scripts that need to be run in the AWS `terraformer` account to create the initial resources that we need for the service.

This the first of 2 steps.

This script can be run by ANY IAM user in the `terraformer` account.

For the purpose of this documentation, we will assume that the user running the script is `john.doe`, an IAM user in the AWS `terraformer` account.

- The Terraform script will first read the state of the resource it is asked to create from the bucket declared in the file `backend.tf`.
- If the resource does NOT exist, then the resource is created.
- If the resource DOES exist alerady, the the script aborts and does NOT try to re-create that same resource again.
- If the resource DOES exist and needs to be modified, the script will modify the resource as specified.

# What we want to acheive in this step:

## If you are creating the DEV environment:

- Create the OU that we need in the organization.
We ONLY do this when we create the first environment (the DEV environment)
- Create the `terraformed` account for the DEV environment.
- Record the Terraform state of each resource in the terraform state bucket associated the DEV environment.

## If you are creating an environment that is NOT the DEV:

- Create the `terraformed` account for the environment (QA, DEMO, PROD).
- Record the Terraform state of each resource in the terraform state bucket associated with each environment.
**MAKE SURE THAT YOU HAVE UPDATED THE DETAILS OF THE S3 Bucket in the `backend.tf` script**

# How this will work

- An IAM user `john.doe` in the `terraformer` account will run the Terraform scripts that will create the resources we need in the `terraformed` accounts.
- The Terraform script will be using an IAM role `master.terraformer.role` in the `terraformer` accounts to do this.

## To create the resources:

We need to make sure that 
- The user `john.doe` can assume the role `master.terraformer.role`
- The role `master.terraformer.role` in the `terraformer` accounts can:
    - Create an OU in the organization.
    - Create a new account in the organization.

## To record the Terraform state:

- We need a:
    - DynamoDb table `terraform_locks` in the `terraformer` account.
    - An S3 bucket `terraform_state_bucket` in the  `terraformer` account.
- We need to make sure that the role `master.terraformer.role` in the `terraformer` account can:
    - Read and write to the DynamoDb table `terraform_locks` in the `terraformer` account.
    - Read and write to the S3 bucket `terraform_state_bucket` in the  `terraformer` account.

# How to run this:

## Pre-requisite:

- Make sure that the parameters for the terraform backend are correct in the file `backend.tf`.
- Verify the variables in the file `vars.fs`.
- Make sure that the values are corrects in the `main.tf` file.
    - name for the AWS account for the DEV, QA, and PROD environment
    - email address associated to the AWS account for the DEV, QA, and PROD environment
 
## To create the OU and accounts:

In the `DEV-step-1` folder run:
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

# Move to Step 2:

See the README.md file in the folder `DEV-step-2` in this repository.

# Future Developments and TO DOs:

- Modify the script to only create one account at a time:
  - First the OU and the DEV account.
  - Then the QA account (using the same OU as for the DEV).
  - Then the PROD account (using the same OU as for the DEV).