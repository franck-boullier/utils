# Overview:

This is where we store the Terraform scripts that need to be run to create the resources we need for a GCP SQL instance and database.

**Make sure that you have update the variables you need to update BEFORE you run the script**

## What we want to acheive:

- Create a database instance and a database that we can access from the Internet.
- The state resources created for a given service will be maintained in a GCP Bucket.

## Pre-requisite:

- You have an active GCP project `my-gcp-project` <--- Replace this with your GCP project ID.
- You have created a bucket `my-bucket-to-store-terraform-state` <--- Replace this with the bucket you have created.
- You have created a `terraformer` service account that has the permissions to 
    - Activate APIs in the project.
    - create resources in the project.
- Verify all the variables 
    - in the file `variables.tfvars`.
    - in the file `backend.tf`.
- You have created a file `terraformer-my-credentials.json` in the repository where the terraform scripts are located. This file will store the credentials for the `terraformer` service account. The credentials file MUST start with `terraformer-` <--- this is to make sure that it will always be excluded from your git repo (so you do not leak very confidential information that could allow a malicious user to access your account...)

# The Things that Terraform will do:

- Activate several Services:
    - Cloud Resource Manager API
    - Cloud Billing API
    - Identity and Access Management (IAM) API
    - Cloud SQL API (sql-component)
    - Cloud SQL Admin
    - Secret Manager API
- Create a SQL instance to host the database
- Create a SSL certificate for the instance
- Store the value of the SSL certificate parameters in 3 secrets:
    - `generic-sql-ssl-client-cert_pem`
    - `generic-sql-ssl-client-key_pem`
    - `generic-sql-ssl-server-ca_pem`
- Create a SQL database to store the data we need.
- Create Secrets to store the passwords for the following database users:
    - `root`
    - `database.user.1`
- Create the first version of the passwords for the following database users:
    - `root`
    - `database.user.1`
- Make sure that the `terraformer` service account can read the secrets for the passwords for
    - `database.user.1`
- Create the following database users at the instance level:
    - `root`

# How to run this:

You should run this script as an IAM user who can create resources in the GCP Project for the environment.

Make sure to update the values in the file `variables.tfvars`.

**NEVER STORE SENSITIVE DATA IN THE `variables.tfvars` file**

## The commands you need to run:

- Clone this repository <ADD THE COMMAND TO DO THAT>
- Go to this folder. <ADD THE COMMAND TO DO THAT>
- Create the json file that store the credential for the `terraformer` user that you will use to run the Terraform script. The name of the file should be the same as the value of the variable `gcp_auth_file` in the file `variables.tfvars`. 
- Run the following commands:

### Commands to handle the passwords securely:

Make sure to export the local variables that will be used to populate the password information:

- For the `root_password` for the database:
```
export TF_VAR_root_password="<strong-password>"
```
- For the `database_user_1` for the database:
```
export TF_VAR_database_user_1_password="<strong-password>"
```
For more details on why we are doing this, see [Managing Secrets in Terraform](https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1).

### Terraform Commands:

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
terraform plan -var-file="variables.tfvars"
```

There should be no error message and you terraform should tell you that it's about to create 4 resources

If all is in order, you can run

```
terraform apply -var-file="variables.tfvars"
```

Review the plan one last time and when prompted, enter `Yes`.
The resources are created.

# After the command have been successfully run:

## Verify that the resources have been created

This part of the documentation is WIP.

## To connect to the SQL Instance:

- You need to put the contents of the following secrets in 3 files:
    - `client-cert.pem` <-- Secret `generic-sql-ssl-client-cert_pem`
    - `client-key.pem`  <-- Secret `generic-sql-ssl-client-key_pem`
    - `server-ca.pem`  <-- Secret `generic-sql-ssl-server-ca_pem`
Store these files in a secure place as these will be needed to access the database.
- Record the public IP address of the SQL Instance

# How to delete the resources:

We have implemented deletion protection to avoid accidental delete of the instance.

To destroy the resources you need to do we need to remove the deletion protection.
- Update the variable `db_instance_deletion_protection` from `true` to `false` in the file `variables.tfvars`
- Apply the modification
```
terraform apply -var-file="variables.tfvars"
```
- You can now destroy all the resources:
```
terraform destroy -var-file="variables.tfvars"
```

# Future developments and TO DOs:

- N/A

# Tips and Tricks:

