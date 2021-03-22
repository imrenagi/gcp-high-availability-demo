output "master_private_ip_address" {
  value = google_sql_database_instance.sql_master_instance.private_ip_address
}

output "db_name" {
  value = google_sql_database.database.name
}

output "db_user_name" {
  value = google_sql_user.users.name
}

output "db_user_password" {
  value = google_sql_user.users.password
}

output "replica_private_ip_addresses" {
  value = google_sql_database_instance.sql_replica_instance.*.private_ip_address
}
