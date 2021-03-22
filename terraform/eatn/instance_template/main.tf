resource "google_compute_instance_template" "user_service_instance_template" {  
  name_prefix  = "${var.name}-"
  description = "This template is used to create user service instances"
  region       = var.region

  tags = [
    "allow-health-check", 
    "allow-ssh",
    "http-server"
  ]

  instance_description = "user service server instance"
  machine_type         = "g1-small"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  
  disk {
    source_image      = "debian-cloud/debian-10"
    auto_delete       = true
    boot              = true
    disk_size_gb      = 10
  }

  network_interface {
    network     = var.network
    subnetwork  = var.subnetwork
  }

  metadata = {
    app-location = "gs://eatn-user-service/app.tar.gz"
    startup-script-url = "gs://eatn-user-service/startup-script.sh"
    postgres-host = var.postgres_host
    postgres-replica-hosts = var.postgres_replica_hosts
  }

  service_account {
    scopes = [
      "userinfo-email",
      "cloud-platform"
    ]    
  }

  lifecycle {
    create_before_destroy = true
  }
}

