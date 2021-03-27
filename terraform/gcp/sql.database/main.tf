# BEFORE YOU RUN THIS SCRIPT
# Make sure to export the local variables that will be used to populate
# Password information:
# - `export TF_VAR_root_password="<strong-password>"` for the `root_password`
# - `export TF_VAR_database_user_1_password="<strong-password>"` for the `database_user_1_password`
# For more details on why we are doing this, see:
# https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1

# Make sure that you are using the correct version of Terraform
terraform {
  required_version = ">= 0.14"
}

# We are building resources in GCP.
provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}

# We use the Terraform plugin to create random IDs to create unique names for the resources.
resource "random_id" "random_suffix" {
 byte_length = 4
}

# We need to enable several APIs:
  # - Cloud Resource Manager API: 
  resource "google_project_service" "cloudresourcemanager" {
    project = var.gcp_project
    service = "cloudresourcemanager.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

  # - Cloud Billing API
  resource "google_project_service" "cloudbilling" {
    project = var.gcp_project
    service = "cloudbilling.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

  # - Identity and Access Management (IAM) API: 
  resource "google_project_service" "iam" {
    project = var.gcp_project
    service = "iam.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

  # - Cloud SQL API (sql-component): 
  resource "google_project_service" "cloud_sql" {
    project = var.gcp_project
    service = "sql-component.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

  # - Cloud SQL Admin (sql-component): 
  resource "google_project_service" "cloud_sql_admin" {
    project = var.gcp_project
    service = "sqladmin.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

  # - Secret Manager API: 
  resource "google_project_service" "secretmanager" {
    project = var.gcp_project
    service = "secretmanager.googleapis.com"
    disable_dependent_services = true
    disable_on_destroy = true
  }

# We create a SQL instance to host the database
resource "google_sql_database_instance" "database_instance" {
  project = var.gcp_project
  region = var.gcp_region
  depends_on = [
    random_id.random_suffix,
    google_project_service.cloud_sql_admin
  ]
  name = "${var.db_instance_name}-${random_id.random_suffix.hex}"
  database_version = var.db_instance_engine
  settings {
    tier = var.db_instance_tier
    availability_type = var.db_instance_availability_type
    disk_autoresize = "true"
    backup_configuration {
      enabled = "true"
      binary_log_enabled = "true"
      }
    ip_configuration {
      ipv4_enabled = var.db_instance_ip_v4_enabled
      require_ssl = var.db_instance_require_ssl
      authorized_networks {
        name = "authorized connections CIDR block"
        value = var.db_instance_autorized_connections
      }
    }
    database_flags {
      name = "character_set_server"
      value = "utf8mb4"
    }
    database_flags {
      name = "default_time_zone"
      value = var.db_instance_default_timezone
    }
    user_labels = {
      "terraform" = "true"
      "environment" = var.label_environment
      "service" = var.label_service
      }
    }
  deletion_protection  = var.db_instance_deletion_protection
}

# We create a SSL certificate for the instance
resource "google_sql_ssl_cert" "database_instance_ssl_cert" {
  project = var.gcp_project
  depends_on = [
    google_sql_database_instance.database_instance
  ]
  common_name = "generic-ssl-certificate"
  instance    = google_sql_database_instance.database_instance.name
}

# We store the value for the generic `client-cert.pem` file in a Secret:
  # Create the secret
  resource "google_secret_manager_secret" "generic_client_cert" {
    project = var.gcp_project
    depends_on = [
      google_project_service.secretmanager
    ]
    secret_id = "generic-sql-ssl-client-cert_pem"
    replication {
      user_managed {
        replicas {
          location = var.gcp_region
        }
      }
    }
  }

  # Store the value of the secret:
  resource "google_secret_manager_secret_version" "generic_client_cert_v1" {
    secret = google_secret_manager_secret.generic_client_cert.id
    depends_on = [
      google_project_service.secretmanager,
      google_secret_manager_secret.generic_client_cert
    ]
    secret_data = google_sql_ssl_cert.database_instance_ssl_cert.cert
  }

# We store the value for the generic `client-key.pem` file in a Secret:
  # Create the secret
  resource "google_secret_manager_secret" "generic_client_key" {
    project = var.gcp_project
    depends_on = [
      google_project_service.secretmanager
    ]
    secret_id = "generic-sql-ssl-client-key_pem"
    replication {
      user_managed {
        replicas {
          location = var.gcp_region
        }
      }
    }
  }

  # Store the value of the secret:
  resource "google_secret_manager_secret_version" "generic_client_key_v1" {
    secret = google_secret_manager_secret.generic_client_key.id
    depends_on = [
      google_project_service.secretmanager,
      google_secret_manager_secret.generic_client_key
    ]
    secret_data = google_sql_ssl_cert.database_instance_ssl_cert.private_key
  }

# We store the value for the generic `server-ca.pem` file in a Secret:
  # Create the secret
  resource "google_secret_manager_secret" "generic_server_ca" {
    project = var.gcp_project
    depends_on = [
      google_project_service.secretmanager
    ]
    secret_id = "generic-sql-ssl-server-ca_pem"
    replication {
      user_managed {
        replicas {
          location = var.gcp_region
        }
      }
    }
  }

  # Store the value of the secret:
  resource "google_secret_manager_secret_version" "generic_server_ca_v1" {
    secret = google_secret_manager_secret.generic_server_ca.id
    depends_on = [
      google_project_service.secretmanager,
      google_secret_manager_secret.generic_server_ca
    ]
    secret_data = google_sql_ssl_cert.database_instance_ssl_cert.server_ca_cert
  }

# We create the SQL database to store the data
resource "google_sql_database" "data_store_database" {
  project = var.gcp_project
  name     = "data_store_${random_id.random_suffix.hex}"
  instance = google_sql_database_instance.database_instance.name
  charset = var.db_charset
  collation = var.db_collation
}

# We create the root user

  # We store the password for the root user in the Google Secret manager interface
  
  resource "google_secret_manager_secret" "root_password" {
    project = var.gcp_project
    depends_on = [
      google_project_service.secretmanager
    ]
    secret_id = "sql-instance-root_password"
    replication {
      user_managed {
        replicas {
          location = var.gcp_region
        }
      }
    }
  }

  # We create the first version of the secret `root_password`
  # The value was defined by exporting the variable
  # `TF_VAR_root_password` before running that script
  # The command is
  # `export TF_VAR_root_password="<strong-secret>"`
  #
  resource "google_secret_manager_secret_version" "root_password_v1" {
    secret = google_secret_manager_secret.root_password.id
    depends_on = [
      google_project_service.secretmanager, 
      google_secret_manager_secret.root_password
    ]
    secret_data = var.root_password
  }

  # We make sure that the service account can access the secret `root_password`
  resource "google_secret_manager_secret_iam_member" "terraformer_service_account_access_root_password" {
    project = var.gcp_project
    depends_on = [
      google_secret_manager_secret_version.root_password_v1
    ]
    secret_id = google_secret_manager_secret.root_password.secret_id
    role = "roles/secretmanager.secretAccessor"
    member = "serviceAccount:${var.terraformer_service_account}"
  }

  # We get the root password for the database instance
  data "google_secret_manager_secret_version" "root_password_v1" {
    secret = "sql-instance-root_password"
    depends_on = [
      google_secret_manager_secret_iam_member.terraformer_service_account_access_root_password
    ]
  }

  # We create the root user
  resource "google_sql_user" "root" {
    name     = "root"
    depends_on = [
      google_secret_manager_secret_version.root_password_v1,
      google_sql_database_instance.database_instance,
      google_secret_manager_secret_iam_member.terraformer_service_account_access_root_password
    ]
    instance = google_sql_database_instance.database_instance.name
    host     = "%"
    password = google_secret_manager_secret_version.root_password_v1.secret_data
  }

# database_user_1 user

  # We store the password for the database_user_1 user in the Google Secret manager interface
  
  resource "google_secret_manager_secret" "database_user_1_password" {
    project = var.gcp_project
    depends_on = [
      google_project_service.secretmanager
    ]
    secret_id = "sql-instance-database_user_1_password"
    replication {
      user_managed {
        replicas {
          location = var.gcp_region
        }
      }
    }
  }

  # We create the first version of the secret `database_user_1_password`
  # The value was defined by exporting the variable
  # `TF_VAR_database_user_1_password` before running that script
  # The command is
  # `export TF_VAR_database_user_1_password="<strong-secret>"`
  #
  resource "google_secret_manager_secret_version" "database_user_1_password_v1" {
    secret = google_secret_manager_secret.database_user_1_password.id
    depends_on = [
      google_project_service.secretmanager, 
      google_secret_manager_secret.database_user_1_password
    ]
    secret_data = var.database_user_1_password
  }

  # We make sure that the service account can access the secret `database_user_1_password`
  resource "google_secret_manager_secret_iam_member" "terraformer_service_account_access_database_user_1_password" {
    project = var.gcp_project
    depends_on = [
      google_secret_manager_secret_version.database_user_1_password_v1
    ]
    secret_id = google_secret_manager_secret.database_user_1_password.secret_id
    role = "roles/secretmanager.secretAccessor"
    member = "serviceAccount:${var.terraformer_service_account}"
  }