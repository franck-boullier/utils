# Overview:

This is the script to create the infrastructure needed to store the Terraform state.
This script also create a central log bucket for this account.

This will create:
- An S3 bucket with the prefix `log-bucket`
- An S3 bucket with the prefix `terraform-state-bucket`
- 2 KMS keys to encrtypt the Files in the 2 buckets
- A Dynamo DB table

We also block all public accesses to the Buckets.

# Permissions and credentials:

We have created set of IAM policies `terraformer` these perissions can be attached to:
- An IAM user.
- An IAM role.
- An SSO user.

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