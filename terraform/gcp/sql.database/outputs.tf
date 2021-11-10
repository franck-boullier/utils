output "google-sql-instance_connection_name" {
  value       = google_sql_database_instance.database_instance.connection_name
  description = "The connection name of the instance to be used in connection strings."
}

output "google-sql-instance_name" {
  value       = google_sql_database_instance.database_instance.name
  description = "The database instance name."
}

output "google-sql-instance_public_ip_address" {
  value       = google_sql_database_instance.database_instance.public_ip_address 
  description = "The database instance public IP address."
}

output "google-sql-instance_private_ip_address" {
  value       = google_sql_database_instance.database_instance.private_ip_address 
  description = "The database instance private IP address."
}

output "google-sql-database_name" {
  value       = google_sql_database.data_store_database.name
  description = "The database name."
}

output "google-sql-database_uri" {
  value       = google_sql_database.data_store_database.self_link
  description = "The URI of the database."
}