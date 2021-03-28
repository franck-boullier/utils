# BEFORE YOU RUN THIS SCRIPT
# Make sure to export the local variables that will be used to populate
# Password information:
# - `export TF_VAR_xxxx="<sensitive_information>"` for `xxxx`
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

  # - Compute Engine API: 
  resource "google_project_service" "compute" {
    project = var.gcp_project
    service = "compute.googleapis.com"
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

# Create Firewall rule to allow http traffic in the default network
resource "google_compute_firewall" "default_allow_http" {
  project = var.gcp_project
  name = "default-allow-http"
  description = "Allow http traffic in the default network"
  network = "default"  
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http", "web"]
}

# Create Firewall rule to allow https traffic in the default network
resource "google_compute_firewall" "default_allow_https" {
  project = var.gcp_project
  name = "default-allow-https"
  description = "Allow https traffic in the default network"
  network = "default"
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["https", "web"]
}

# Prepare the file that we will use to configure the machine
# See https://dzone.com/articles/deploy-web-server-on-google-compute-engine-gce-wit
data "template_file" "configure_web-server_machine" {
  template = file("${path.module}/${var.ci_startup_script}")

  vars = {
    name_of_a_variable_in_the_script = "value"
  }
}

# Create a compute instance that will host the web-server
resource "google_compute_instance" "web_server" {
  project = var.gcp_project
  depends_on = [
    google_compute_firewall.default_allow_http,
    google_compute_firewall.default_allow_https
  ]
  name = "web-server-${random_id.random_suffix.hex}"
  description = "A web server that can interact with Bitbucket"
  machine_type = var.ci_machine_type
  zone         = var.ci_zone_a
  allow_stopping_for_update = "true"
  labels = {
      "terraform" = "true"
      "environment" = var.label_environment
      "service" = var.label_service
      }
  tags = ["http", "https", "web"]

  boot_disk {
    initialize_params {
      size = 30
      image = "${var.ci_machine_image_project}/${var.ci_machine_image}"
    }
  }
  # We call the script to configure the machine
  metadata_startup_script = data.template_file.configure_web-server_machine.rendered

  network_interface {
    network = "default"

    access_config {
      # This will create a public IP address for the instance
      network_tier = "STANDARD"
    }
  }
}