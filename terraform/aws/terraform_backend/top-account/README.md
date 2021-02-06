# Overview:

This is where we store the Terraform scripts that need to be run in the AWS top account or as a user who can assume the role `terraformer` in the Top Account.

We have configured a dedicated bucket `ORGANIZATION_backend_state_terraform` to store the Terraform states for this specific service.
- The Terraform script will first read the state of the resource it is asked to create from that bucket.
- If the resource does NOT exist, then the resource is created.
- If the resource DOES exist alerady, the the script aborts and does NOT try to re-create that same resource again.

# How to run this:

 You should run this script as a user who is a member of the group `terraformer` in the TOP Account.
