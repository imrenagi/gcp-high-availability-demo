variable "name" {
  description = "name of instance template"
  type        = string
}

variable "region" {
  description = "region where this instance template can be used"
  type        = string
}

variable "network" {
  description = "vpc name"
  type        = string
}

variable "subnetwork" {
  description = "subnet name"
  type        = string
}

variable "postgres_host" {
  description = "postgres main host"
  type        = string
}

variable "postgres_replica_hosts" {
  description = "postgres replica hosts"
  type        = string
}