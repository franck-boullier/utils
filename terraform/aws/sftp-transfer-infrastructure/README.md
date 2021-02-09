# Overview:

This allows us to create a secure FTP server on AWS using S3 and the AWS Transfer platform.

We are going to create:
- IAM Roles
- KMS Keys
- S3 Buckets:
    - Raw: to store the data that are uploaded via SFTP.
    - Logs: to store all the logs for easy debugging and audit.
    - Terraform State: to store the status of all the resources we have created.
- SNS topics to disseminate the activites taking place on the bucket.

# Key principles:

We will follow a few guiding principles:

    - We will be setting variables for every argument so that we can create some defaults.
    - For S3 Busket, we are choosing to use the `bucket_prefix` argument rather than the bucket argument. That way we don’t accidentally try to create a bucket with the same name as one that already exists in the global namespace.
