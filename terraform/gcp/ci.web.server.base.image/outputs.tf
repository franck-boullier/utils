output "web-server-public-ip-address" {
  value       = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
  description = "The public IP address associated to the Compute instance for the web-server."
}

output "web-server-name" {
  value       = google_compute_instance.web_server.name
  description = "The name of the Compute instance for the web-server."
}

output "web-server-uri" {
  value       = google_compute_instance.web_server.self_link
  description = "The URI of the Compute instance for the web-server."
}