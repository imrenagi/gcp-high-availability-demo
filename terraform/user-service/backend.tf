terraform {
  backend "gcs" {
    bucket  = "gcp-ha-demo-terraform-state"
    prefix  = "user-service"
  }
}
