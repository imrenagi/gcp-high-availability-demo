resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "sql_master_instance" {
  provider = google-beta  
  name   = "${var.name}-${random_id.db_name_suffix.hex}"
  region = var.region
  deletion_protection = false
  database_version = "POSTGRES_11"
  settings {
    tier = "db-custom-1-3840"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }
    availability_type = "REGIONAL"
    backup_configuration {
      enabled = false
    }
    location_preference {
      zone = var.master_zone
    }
  }
}

resource "google_sql_user" "users" {
  name     = var.db_user_name
  instance = google_sql_database_instance.sql_master_instance.name
  password = var.db_user_password
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.sql_master_instance.name
}

locals {
  replicas_ip_addresses = google_sql_database_instance.sql_replica_instance[*].private_ip_address
}

resource "google_sql_database_instance" "sql_replica_instance" {

  count = length(var.replicas)
  provider = google-beta
  
  master_instance_name = google_sql_database_instance.sql_master_instance.name
  name   = "${var.name}-${random_id.db_name_suffix.hex}-${count.index}"
  region = var.replicas[count.index].region

  deletion_protection = false
  database_version = "POSTGRES_11"

  settings {
    tier = "db-custom-1-3840"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }
    availability_type = "ZONAL"
    backup_configuration {
      enabled = false
    }
    location_preference {
      zone = var.replicas[count.index].zone
    }
  } 
}
