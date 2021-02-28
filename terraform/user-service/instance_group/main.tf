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
    app-location = "gs://gcp-ha-demo-user-service-artefact/app.tar.gz"
    startup-script-url = "gs://gcp-ha-demo-user-service-artefact/startup-script.sh"
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

resource "google_compute_instance_group_manager" "instance_group_manager" {
  for_each           = toset(var.instance_group_zones)
  name               = "${var.name}-${each.value}-igm"
  base_instance_name = var.name
  zone               = each.value
  target_size        = var.instance_group_replicas

  version {
    instance_template  = google_compute_instance_template.user_service_instance_template.id
  }

  named_port {
    name = "http"
    port = 8888
  }
}
