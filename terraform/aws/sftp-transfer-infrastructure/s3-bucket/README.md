# Overview:

The scripts here allow us to create S3 buckets
    - `Raw` bucket with object lifecycle policy
    - `Log` bucket to store all the logs.

Buckets are encrypted with different KMS Key.

We have a lifecyslke policy for both bucket:
- after 30 days, move to Infrequent Access
- after 60 days, move to GLacier