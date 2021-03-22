variable "name" {
  description = "name of cloudsql instance"
  type        = string
}

variable "region" {
  description = "region where this cloudsql master will be created"
  type        = string
}

variable "master_zone" {
  description = "region where this cloudsql master will be created"
  type        = string
}

variable "network" {
  description = "vpc name"
  type        = string
}

variable "project" {
  description = "project name"
  type        = string
}

variable "db_user_name" {
  description = "dabatase user name"
  type        = string
}

variable "db_user_password" {
  description = "database user password"
  type        = string
}

variable "db_name" {
  description = "database name"
  type = string
}

variable "replicas" {
  description = "list of where replicas will be created"
  type = list(object({
    region = string
    zone   = string
  }))
  default = []
}
