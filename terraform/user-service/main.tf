module "us_central_user_service_instance_group" {
  source = "./instance_group/"
  name        = "user-service-us-central1"
  region      = "us-central1"
  network     = "eatn-network"
  subnetwork  = "us-central1-subnet"

  instance_group_zones = [
    "us-central1-a"
  ]
  instance_group_replicas = 2
}