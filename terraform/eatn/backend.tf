terraform {
  backend "gcs" {
    bucket  = "eatn-prod-terraform"
    prefix  = "eatn"
  }
}
