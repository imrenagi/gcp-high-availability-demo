variable "name" {
  description = "name of instance template"
  type        = string
}

variable "instance_template_id" {
  description = "zone where instance group will be created"
  type        = string
}

variable "zones" {
  description = "zone where instance group will be created"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "region"
  type        = string
}

variable "replicas" {
  description = "number of replicase created per managed instance group"
  type        = number
  default     = 1
}