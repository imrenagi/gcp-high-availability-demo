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

variable "instance_group_zones" {
  description = "zone where instance group will be created"
  type        = list(string)
  default     = []
}

variable "instance_group_replicas" {
  description = "number of replicase created per managed instance group"
  type        = number
  default     = 1
}