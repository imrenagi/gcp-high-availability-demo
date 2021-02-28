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
