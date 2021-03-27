output "web-server-fixed-ip-address" {
  value       = google_compute_address.web-server_public_ip_address.address
  description = "The reserved IP address associated to the Compute instance for the web-server."
}

output "web-server-name" {
  value       = google_compute_instance.data_store_interface_server.name
  description = "The name of the Compute instance for the web-server."
}

output "web-server-uri" {
  value       = google_compute_instance.data_store_interface_server.self_link
  description = "The URI of the Compute instance for the web-server."
}