# GCP Settings
gcp_project         = "my-gcp-project"
gcp_region          = "asia-southeast1"
gcp_auth_file       = "terraformer-my-credentials.json"

# The labels/tags:
label_environment = "dev"
label_service = "web-server-test"

# The Terraformer service account email
terraformer_service_account = "terraformer-service-account@terraformer-service-account.iam.gserviceaccount.com"

# The Compute Instance
ci_machine_type = "n1-standard-1"
ci_machine_image_project = "ubuntu-os-cloud"
ci_machine_image = "ubuntu-minimal-2004-focal-v20210325"
ci_startup_script = "startup_script/lamp_server.sh"
ci_zone_a = "asia-southeast1-a"
ci_zone_b = "asia-southeast1-b"
ci_zone_c = "asia-southeast1-c"