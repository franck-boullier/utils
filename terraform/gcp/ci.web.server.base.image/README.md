# Overview:

This is where we store the Terraform scripts that need to create a base image that we can use to create a web server that will be able to interact with a specific bitbucket Repo.

**Make sure that you have update the variables you need to update BEFORE you run the script**

## What we want to acheive:

### With Terraform

- Create a Compute Instance.
- Configure that Instance so it can run a web server and install all the component we neeed (see the script in the `startup_script` for more details):
    - Update Ubuntu
    - vim
    - wget
    - git
    - Apache 2
    - php
    - Create a user `deployment-worker` that we can use to configure access to the git repo.
    - Create the ssh credentials for the user `deployment-worker`.
- The state resources created for a given service will be maintained in a GCP Bucket.

### Outside of Terraform

- Configure the Instance so it can pull from the code repository where the code for the web server is hosted
- Create a base image that we can use to create more of this web server.

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
    - Compute Engine API
    - Secret Manager API
- Create several firewall rules to allow access to the instance
    - `default-allow-http`
    - `default-allow-https`
- Create a Compute instance to host the code for the web server.

# How to run this:

You should run this script as an IAM user who can create resources in the GCP Project for the environment.

Make sure to update the values in the file `variables.tfvars`.

**NEVER STORE SENSITIVE DATA IN THE `variables.tfvars` file**

## The commands you need to run:

- Clone this repository <ADD THE COMMAND TO DO THAT>
- Go to this folder. <ADD THE COMMAND TO DO THAT>
- Create the json file that store the credential for the `terraformer` user that you will use to run the Terraform script. The name of the file should be the same as the value of the variable `gcp_auth_file` in the file `variables.tfvars`. The credentials file MUST start with `terraformer-` <--- this is to make sure that it will always be excluded from your git repo (so you do not leak very confidential information that could allow a malicious user to access your account...) 
- Run the following commands:

### Commands to handle the sensitive information securely:

Make sure to export the local variables that will be used to populate the following sensitive information:

- For the `xxxx` sensitive information:
```
export TF_VAR_xxxx="<sensitive_information>"
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

## Check that the Web Server is working as intended:

- Record the public IP address of the SQL Instance
- Use a web browser to connect to the machine.

Expected result: you should see the default Apache page.


## Configure The Bitbucket Repository:

- On the Instance, connect via SSH and get the public ssh key for the `deployment-worker`.
  The command to do that is
  ```
  cat /home/deployment-worker/.ssh/id_rsa.pub
  ```
- Add the public ssh key for the `deployment-worker` as an Access Key into the relevant git repository.

## Configure the Instance:

We need to make sure that the instance can interact with the repo where the code is.
On the Instance, connect via SSH and clone the repository on the machine under the apache directory.
The command to do that:
-  First remove everything from the /var/www/hmtl directory
```
sudo mv /var/www/html/index.html ~/vanilla.index.html
```
- Then clone the repository
```
sudo -u deployment-worker git clone git@bitbucket.org:option-gift/data.store.interface.git /var/www/html
```

## (Optional) Prepare an Image we can use:

Create a base image that we can use to create duplicates of this web server.

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

- Create a Service Account that we can use to do some actions:
    - Monitor with the cloud agent.
- Add the cloud monitoring agent for improved logs and monitoring. See the [Agent Installation documentation](https://cloud.google.com/monitoring/agent/installation?_ga=2.186993704.-128018049.1610943812#agent-install-debian-ubuntu)

# Tips and Tricks:

## To check the status of a bash script:

The startup script will run in the background.
To check if a bash script is still currently running in the background you can open a terminal window on the machine and run the command
```
sudo journalctl -f -o cat
```
This displays the output of the script that's running in the background.
Once done you can exit with `Crtl C`.

## To interact with git:

- Log in with the Google SSH web console
- Run the git command as the `deployment-worker` user. Example:
```
sudo -u deployment-worker git pull
```
