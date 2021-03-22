resource "google_compute_region_instance_group_manager" "instance_group_manager" {  
  name                        = "${var.name}-region-igm"
  base_instance_name          = var.name
  target_size                 = var.replicas
  region                      = var.region
  distribution_policy_zones   = var.zones

  version {
    instance_template = var.instance_template_id
  }

  named_port {
    name = "http"
    port = 80
  }
}
