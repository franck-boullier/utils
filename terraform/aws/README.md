# Overview:

These are the files to build AWS resources for a given service `new-service`

# What we want to achieve:

We want to create everything from a single AWS Account `terraformer`.
The `terraformer` account will be used to:
- Create AWS resources in other AWS accounts (the `terraformed` accounts that we control).
- Centrally store the Terraform State of all the resources created in all the `terraformed` accounts.

# How this will work

- An IAM user `john.doe` in the `terraformer` account will run the Terraform scripts that will create the resources we need in the `terraformed` accounts.
- The Terraform script will be using an IAM role `terraformer.role` in the `terraformed` accounts to do this.

## To create the resources:

- We need to make sure that the user `john.doe` in the `terraformer` accounts can assume the role `terraformer.role` in the `terraformed` account. 
Q; How can we do that? 
A: By allowing **ANY** user in the `terraformer` account to assume the role `terraformer.role` in the `terraformed` account.
- We need to make sure that the role `terraformer.role` in the `terraformed` account is allowed to create all the types of AWS resources that we need (S3, EC2, API Gateway, etc...).

## To record the Terraform state:

- We need a:
    - DynamoDb table `terraform_locks` in the `terraformer` account.
    - An S3 bucket `terraform_state_bucket` in the  `terraformer` account.
- We need to make sure that the role `terraformer.role` in the `terraformed` account can:
    - Read and write to the DynamoDb table `terraform_locks` in the `terraformer` account.
    - Read and write to the S3 bucket `terraform_state_bucket` in the  `terraformer` account.

# Step by Step:

- Create the `terraformed` account

We do this by running the Terraform scripts in the folder `step-1` in the folder for the service `new-service`

This will:
- 

## In the Terraformed Account (765328940034):

- Create the role `terraformer.role` in the `terraformed` account.
Trust relationship with the `terraformer` account (ALL IAM users in the `terraformer` account).
- Create a policy `terraformer.policy` to allow the creation of resources in the `terraformed` account.
Make sure that this allow the creation of ALL the resources that you will need.
- Attach the policy `terraformer.policy` to the role `terraformer.role`

## In the Terraformer Account (166082882045):

- A policy `remote.terraformer.s3` allow read and write to the S3 bucket `terraform_state_bucket` in the  `terraformer` account.
- A policy `remote.terraformer.dynamodb` allow read and write to the DynamoDb table `terraform_locks` in the `terraformer` account.
- An IAM role `remote.terraformer` that will allow the role `terraformer.role` in the `terraformed` account to:
    - Read and write to the DynamoDb table `terraform_locks` in the `terraformer` account.
    - Read and write to the S3 bucket `terraform_state_bucket` in the  `terraformer` account.
- Add a trust relationship to the role `remote.terraformer`: allow the role `terrafomer` in the `terraformed` account to use this role.
WARNING: the role `terrafomer` in the `terraformed` account MUST exist before this can be done!!!

# Run the Terraform script in the `service-accounts` folder:

This script:
- Will be started by any IAM user in the `terraformer` account.
- Will be configured to use the role `terraformer.role` in the `terraformed` account.





# Future developments and TO DOs:

- Put limits to the users who can create resource in the `terraformed` account from the `terraformer` account <--- This may be overkill!!!
IDEA: reduce the trust relationship to the group `master.terraformer` in the `terraformer` account
WARNING: the group `master.terrafomer` in the `terraformer` account MUST exist before this can be done!!!