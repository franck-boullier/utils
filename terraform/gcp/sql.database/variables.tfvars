# GCP Settings
gcp_project         = "my-gcp-project"
gcp_region          = "asia-southeast1"
gcp_auth_file       = "terraformer-my-credentials.json"

# The labels/tags:
label_environment = "dev"
label_service = "test-sql-database"

# The Terraformer service account email
terraformer_service_account = "terraformer-service-account@terraformer-service-account.iam.gserviceaccount.com"

# The DB Instance:
db_instance_name = "mysql-5-7-dev"
db_instance_engine = "MYSQL_5_7"
db_instance_tier = "db-f1-micro"
db_instance_availability_type = "REGIONAL"
db_instance_ip_v4_enabled = "true"
db_instance_autorized_connections = "0.0.0.0/0"
db_instance_deletion_protection = "true"
db_instance_default_timezone = "+08:00"
db_instance_require_ssl = "true"

# The database parameters
db_charset = "utf8mb4"
db_collation = "utf8mb4_unicode_520_ci"
