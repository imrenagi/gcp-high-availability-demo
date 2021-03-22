provider "google" {
  project = "eatn-production"
  region  = "asia-southeast2"
}

provider "google-beta" {
  project = "eatn-production"
  region  = "asia-southeast2"
}

provider "aws" {
  access_key                  = "${var.aws_access_key}"
  secret_key                  = "${var.aws_secret_key}"
  region                      = "ap-southeast-1"
  profile                     = "${var.aws_profile}"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}