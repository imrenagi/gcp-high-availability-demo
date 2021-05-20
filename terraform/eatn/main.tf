resource "google_compute_network" "vpc_network" {
  name                      = "eatn-network"
  auto_create_subnetworks   = false
  routing_mode              = "GLOBAL"
}

resource "google_compute_subnetwork" "eatn-us-central1-subnet" {
  name          = "us-central1-subnet"
  ip_cidr_range = "10.1.10.0/23" 
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "eatn-eu-west1-subnet" {
  name          = "europe-west1-subnet"
  ip_cidr_range = "10.1.12.0/23" 
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "eatn-asia-southeast2-subnet" {
  name          = "asia-southeast2-subnet"
  ip_cidr_range = "10.1.14.0/23" 
  region        = "asia-southeast2"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "eatn-asia-southeast1-subnet" {
  name          = "asia-southeast1-subnet"
  ip_cidr_range = "10.1.16.0/23" 
  region        = "asia-southeast1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "eatn-us-west1-subnet" {
  name          = "us-west1-subnet"
  ip_cidr_range = "10.1.18.0/23" 
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "fw_allow_ssh" {
  name    = "fw-allow-ssh"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["allow-ssh"]
}

resource "google_compute_firewall" "fw_allow_http_server" {
  name    = "fw-allow-http-server"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["http-server"]
}

resource "google_compute_firewall" "fw_allow_hc_proxy" {
  name    = "fw-allow-health-check-and-proxy"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["allow-health-check"]
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

resource "google_compute_firewall" "locust_firewall" {
  name    = "fw-locust"
  network = google_compute_network.vpc_network.name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["5557"]
  }

  target_tags = ["locust"]
  source_ranges = [
    "0.0.0.0/0",    
  ]
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_router" "eatn_asia_southeast2_router" {
  name    = "eatn-asia-southeast2-router"
  region  = google_compute_subnetwork.eatn-asia-southeast2-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "eatn_asia_southeast2_nat" {
  name                               = "eatn-asia-southeast2-nat"
  router                             = google_compute_router.eatn_asia_southeast2_router.name
  region                             = google_compute_router.eatn_asia_southeast2_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "eatn_asia_southeast1_router" {
  name    = "eatn-asia-southeast1-router"
  region  = google_compute_subnetwork.eatn-asia-southeast1-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "eatn_asia_southeast1_nat" {
  name                               = "eatn-asia-southeast1-nat"
  router                             = google_compute_router.eatn_asia_southeast1_router.name
  region                             = google_compute_router.eatn_asia_southeast1_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}


resource "google_compute_router" "eatn_us_central1_router" {
  name    = "eatn-us-central1-router"
  region  = google_compute_subnetwork.eatn-us-central1-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "eatn_us_central1_nat" {
  name                               = "eatn-us-central1-nat"
  router                             = google_compute_router.eatn_us_central1_router.name
  region                             = google_compute_router.eatn_us_central1_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}


resource "google_compute_router" "eatn_us_west1_router" {
  name    = "eatn-us-west1-router"
  region  = google_compute_subnetwork.eatn-us-west1-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "eatn_us_west1_nat" {
  name                               = "eatn-us-west1-nat"
  router                             = google_compute_router.eatn_us_west1_router.name
  region                             = google_compute_router.eatn_us_west1_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "eatn_eu_west1_router" {
  name    = "eatn-europe-west1-router"
  region  = google_compute_subnetwork.eatn-eu-west1-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "eatn_eu_west1_nat" {
  name                               = "eatn-europe-west1-nat"
  router                             = google_compute_router.eatn_eu_west1_router.name
  region                             = google_compute_router.eatn_eu_west1_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

resource "google_vpc_access_connector" "payment_service_id_connector" {
  name          = "vpc-con-id"
  region        = "asia-southeast2"
  ip_cidr_range = "10.100.0.0/28"
  network       = google_compute_network.vpc_network.name
}

resource "google_vpc_access_connector" "payment_service_us_us_central1_connector" {
  name          = "vpc-con-us-central1"
  region        = "us-central1"
  ip_cidr_range = "10.102.0.0/28"
  network       = google_compute_network.vpc_network.name
}

resource "google_vpc_access_connector" "payment_service_us_us_west1_connector" {
  name          = "vpc-con-us-west1"
  region        = "us-west1"
  ip_cidr_range = "10.103.0.0/28"
  network       = google_compute_network.vpc_network.name
}

resource "google_vpc_access_connector" "payment_service_us_us_east1_connector" {
  name          = "vpc-con-us-east1"
  region        = "us-east1"
  ip_cidr_range = "10.104.0.0/28"
  network       = google_compute_network.vpc_network.name
}

resource "google_vpc_access_connector" "payment_service_sg_connector" {
  name          = "vpc-con-sg"
  region        = "asia-southeast1"
  ip_cidr_range = "10.101.0.0/28"
  network       = google_compute_network.vpc_network.name
}


module "payment_service_id_db" {

  source = "./cloudsql/"
  project = "eatn-production"
  name = "payment-service-id"
  region = "asia-southeast2"
  master_zone = "asia-southeast2-a"
  network = google_compute_network.vpc_network.id
  db_user_name = "payment-service"
  db_user_password = "password01"
  db_name = "payment-service"
  replicas = [    
    {
      region  = "asia-southeast2"
      zone    = "asia-southeast2-c"
    }
  ]  
}

module "payment_service_us_db" {

  source = "./cloudsql/"
  project = "eatn-production"
  name = "payment-service-usa"
  region = "us-central1"
  master_zone = "us-central1-a"
  network = google_compute_network.vpc_network.id
  db_user_name = "payment-service"
  db_user_password = "password01"
  db_name = "payment-service"
  replicas = [    
    {
      region  = "us-central1"
      zone    = "us-central1-b"
    }
  ]  
}

module "user_service_db" {

  source = "./cloudsql/"
  project = "eatn-production"
  name = "user-service"
  region = "asia-southeast2"
  network = google_compute_network.vpc_network.id
  db_user_name = "user-service"
  db_user_password = "password01"
  db_name = "user-service"
  master_zone = "asia-southeast2-a"
  replicas = [
    {
      region  = "asia-southeast2"
      zone    = "asia-southeast2-c"
    },
    {
      region  = "us-central1"
      zone    = "us-central1-a"
    }
  ]  
}

# user service in us_central1

module "us_central1_user_service_instance_template" {
  source = "./instance_template/"
  name        = "user-service-us-central1"
  region      = "us-central1"
  network     = "eatn-network"
  subnetwork  = "us-central1-subnet"
  postgres_host = module.user_service_db.master_private_ip_address
  postgres_replica_hosts = join(",", module.user_service_db.replica_private_ip_addresses)
}

module "us_central1_user_service_instance_group" {
  source = "./instance_group/"
  name        = "user-service-us-central1"
  region      = "us-central1"
  zones        = [
    "us-central1-a",
    "us-central1-b"
    ]
  replicas    = 2
  instance_template_id = module.us_central1_user_service_instance_template.instance_template_name
}


# # # user service in asia-southeast2

module "asia_southeast2_user_service_instance_template" {
  source = "./instance_template/"
  name        = "user-service-asia-southeast2"
  region      = "asia-southeast2"
  network     = "eatn-network"
  subnetwork  = "asia-southeast2-subnet"
  postgres_host = module.user_service_db.master_private_ip_address
  postgres_replica_hosts = join(",", module.user_service_db.replica_private_ip_addresses)  
}

module "asia_southeast2_user_service_instance_group" {
  source = "./instance_group/"
  name        = "user-service-asia-southeast2"
  region      = "asia-southeast2"
  zones        = [
    "asia-southeast2-a",
    "asia-southeast2-b"
    ]
  replicas    = 2
  instance_template_id = module.asia_southeast2_user_service_instance_template.instance_template_name
}

locals {
  health_check = {
    check_interval_sec  = null
    timeout_sec         = null
    healthy_threshold   = null
    unhealthy_threshold = null
    request_path        = "/"
    port                = 80
    host                = null
    logging             = null
  }
}

resource "google_compute_global_address" "eatn_load_balancer_ip_address" {
  name = "eatn-load-balancer-ip"
}

data "aws_route53_zone" "imrenagi_com_zone" {
  name         = "imrenagi.com"
}

resource "aws_route53_record" "eatn_route53_record" {
  zone_id = data.aws_route53_zone.imrenagi_com_zone.zone_id
  name    = "eatn.imrenagi.com"
  type    = "A"
  ttl     = "300"
  records = [google_compute_global_address.eatn_load_balancer_ip_address.address]
}

module "gce-lb-https" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 4.4"

  name    = google_compute_network.vpc_network.name
  project = "eatn-production"
  
  target_tags = [
    "allow-health-check"
  ]

  firewall_networks = [google_compute_network.vpc_network.self_link]
  url_map           = google_compute_url_map.ml-bkd-ml-mig-bckt-s-lb.self_link
  create_url_map    = false
  
  ssl               = true
  managed_ssl_certificate_domains  = ["eatn.imrenagi.com"]
  use_ssl_certificates = false

  create_address = false
  address = google_compute_global_address.eatn_load_balancer_ip_address.self_link

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null

      health_check = local.health_check
      log_config = {
        enable      = true
        sample_rate = 1.0
      }
      groups = [
        {
          group                        = module.us_central1_user_service_instance_group.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        {
          group                        = module.asia_southeast2_user_service_instance_group.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }

}

resource "google_compute_url_map" "ml-bkd-ml-mig-bckt-s-lb" {
  // note that this is the name of the load balancer
  name            = google_compute_network.vpc_network.name
  default_service = module.gce-lb-https.backend_services["default"].self_link

  host_rule {
    hosts        = ["eatn.imrenagi.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = module.gce-lb-https.backend_services["default"].self_link

    path_rule {
      paths = [
        "/users/api/*"
      ]
      service = module.gce-lb-https.backend_services["default"].self_link
    }

    path_rule {
      paths = [
        "/payments/us/api/*"
      ]
      service = google_compute_backend_service.payment_service_us_backend_service.self_link
    }


    path_rule {
      paths = [        
        "/payments/id/api/*"        
      ]
      service = google_compute_backend_service.payment_service_id_backend_service.self_link
    }
  }
}

#  ========== Start of Cloud Run Payment Service ID ===================

resource "google_cloud_run_service" "payment_service_id_asia_southeast2" {
  name     = "payment-service-id-asia-southeast2"
  location = "asia-southeast2"
  project  = "eatn-production"

  depends_on = [
    google_vpc_access_connector.payment_service_id_connector
  ]

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1"     
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.payment_service_id_connector.self_link
      }
    }

    spec {
      containers {
        image = "gcr.io/eatn-production/payment-service:v1"
        env {
          name = "COUNTRY_CODE"
          value = "id"
        }
        env {
          name = "POSTGRES_HOST"
          value = module.payment_service_id_db.master_private_ip_address
        }
        env {
          name = "POSTGRES_USER"
          value = module.payment_service_id_db.db_user_name
        }
        env {
          name = "POSTGRES_DB"
          value = module.payment_service_id_db.db_name
        }
        env {
          name = "POSTGRES_PASSWORD"
          value = module.payment_service_id_db.db_user_password
        }      
        env {
          name = "POSTGRES_REPLICA_IPS"
          value = join(",", module.payment_service_id_db.replica_private_ip_addresses)
        }  
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "payment_service_id_asia_southeast2_public_access" {
  location = google_cloud_run_service.payment_service_id_asia_southeast2.location
  project  = google_cloud_run_service.payment_service_id_asia_southeast2.project
  service  = google_cloud_run_service.payment_service_id_asia_southeast2.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}



resource "google_cloud_run_service" "payment_service_id_asia_southeast1" {
  name     = "payment-service-id-asia-southeast1"
  location = "asia-southeast1"
  project  = "eatn-production"

  depends_on = [
    google_vpc_access_connector.payment_service_sg_connector
  ]

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "3"     
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.payment_service_sg_connector.self_link
      }
    }

    spec {
      containers {
        image = "gcr.io/eatn-production/payment-service:v1"
        env {
          name = "COUNTRY_CODE"
          value = "id"
        }
        env {
          name = "POSTGRES_HOST"
          value = module.payment_service_id_db.master_private_ip_address
        }
        env {
          name = "POSTGRES_USER"
          value = module.payment_service_id_db.db_user_name
        }
        env {
          name = "POSTGRES_DB"
          value = module.payment_service_id_db.db_name
        }
        env {
          name = "POSTGRES_PASSWORD"
          value = module.payment_service_id_db.db_user_password
        }      
        env {
          name = "POSTGRES_REPLICA_IPS"
          value = join(",", module.payment_service_id_db.replica_private_ip_addresses)
        }  
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "payment_service_id_asia_southeast1_public_access" {
  location = google_cloud_run_service.payment_service_id_asia_southeast1.location
  project  = google_cloud_run_service.payment_service_id_asia_southeast1.project
  service  = google_cloud_run_service.payment_service_id_asia_southeast1.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "payment_service_id_asia_southeast2_neg" {
  provider              = google-beta
  name                  = "payment-service-id-asia-southeast2-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-southeast2"
  cloud_run {
    service = google_cloud_run_service.payment_service_id_asia_southeast2.name
  }
}

resource "google_compute_region_network_endpoint_group" "payment_service_id_asia_southeast1_neg" {
  provider              = google-beta
  name                  = "payment-service-id-asia-southeast1-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-southeast1"
  cloud_run {
    service = google_cloud_run_service.payment_service_id_asia_southeast1.name
  }
}

resource "google_compute_backend_service" "payment_service_id_backend_service" {
  provider = google-beta
  project = "eatn-production"
  name = "payment-service-id-backend"

  description = null
  connection_draining_timeout_sec = null
  enable_cdn = false
  custom_request_headers = []

  backend {   
    group = google_compute_region_network_endpoint_group.payment_service_id_asia_southeast2_neg.id   
  }

  backend {   
    group = google_compute_region_network_endpoint_group.payment_service_id_asia_southeast1_neg.id   
  }
  
  security_policy                 = null    
  log_config {
    enable      = false
    sample_rate = null
  }
}

#  ========== End of Cloud Run Payment Service ID ===================


#  ========== Start of Cloud Run Payment Service US ===================


resource "google_cloud_run_service" "payment_service_us_us_central1" {
  name     = "payment-service-us-us-central1"
  location = "us-central1"
  project  = "eatn-production"

  depends_on = [
    google_vpc_access_connector.payment_service_us_us_central1_connector
  ]

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "5"     
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.payment_service_us_us_central1_connector.self_link
      }
    }

    spec {
      containers {
        image = "gcr.io/eatn-production/payment-service:v1"
        env {
          name = "COUNTRY_CODE"
          value = "us"
        }
        env {
          name = "POSTGRES_HOST"
          value = module.payment_service_us_db.master_private_ip_address
        }
        env {
          name = "POSTGRES_USER"
          value = module.payment_service_us_db.db_user_name
        }
        env {
          name = "POSTGRES_DB"
          value = module.payment_service_us_db.db_name
        }
        env {
          name = "POSTGRES_PASSWORD"
          value = module.payment_service_us_db.db_user_password
        }      
        env {
          name = "POSTGRES_REPLICA_IPS"
          value = join(",", module.payment_service_us_db.replica_private_ip_addresses)
        }  
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "payment_service_us_us_central1_public_access" {
  location = google_cloud_run_service.payment_service_us_us_central1.location
  project  = google_cloud_run_service.payment_service_us_us_central1.project
  service  = google_cloud_run_service.payment_service_us_us_central1.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service" "payment_service_us_us_east1" {
  name     = "payment-service-us-us-east1"
  location = "us-east1"
  project  = "eatn-production"

  depends_on = [
    google_vpc_access_connector.payment_service_us_us_east1_connector
  ]

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "5"     
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.payment_service_us_us_east1_connector.self_link
      }
    }

    spec {
      containers {
        image = "gcr.io/eatn-production/payment-service:v1"
        env {
          name = "COUNTRY_CODE"
          value = "us"
        }
        env {
          name = "POSTGRES_HOST"
          value = module.payment_service_us_db.master_private_ip_address
        }
        env {
          name = "POSTGRES_USER"
          value = module.payment_service_us_db.db_user_name
        }
        env {
          name = "POSTGRES_DB"
          value = module.payment_service_us_db.db_name
        }
        env {
          name = "POSTGRES_PASSWORD"
          value = module.payment_service_us_db.db_user_password
        }      
        env {
          name = "POSTGRES_REPLICA_IPS"
          value = join(",", module.payment_service_us_db.replica_private_ip_addresses)
        }  
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "payment_service_us_us_east1_public_access" {
  location = google_cloud_run_service.payment_service_us_us_east1.location
  project  = google_cloud_run_service.payment_service_us_us_east1.project
  service  = google_cloud_run_service.payment_service_us_us_east1.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "payment_service_us_us_central1_neg" {
  provider              = google-beta
  name                  = "payment-service-us-us-central1-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_service.payment_service_us_us_central1.name
  }
}


resource "google_compute_region_network_endpoint_group" "payment_service_us_us_east1_neg" {
  provider              = google-beta
  name                  = "payment-service-us-us-east1-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-east1"
  cloud_run {
    service = google_cloud_run_service.payment_service_us_us_east1.name
  }
}

resource "google_compute_backend_service" "payment_service_us_backend_service" {
  provider = google-beta
  project = "eatn-production"
  name = "payment-service-us-backend"

  description = null
  connection_draining_timeout_sec = null
  enable_cdn = false
  custom_request_headers = []

  backend {   
    group = google_compute_region_network_endpoint_group.payment_service_us_us_central1_neg.id   
  }


  backend {   
    group = google_compute_region_network_endpoint_group.payment_service_us_us_east1_neg.id   
  }
  
  security_policy                 = null    
  log_config {
    enable      = false
    sample_rate = null
  }
}

#  ========== End of Cloud Run Payment Service US ===================
