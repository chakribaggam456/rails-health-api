variable "project_name" {
  type    = string
  default = "rails-health-api"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type    = string
}