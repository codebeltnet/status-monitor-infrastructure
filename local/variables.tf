variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment"
  default     = "LocalDevelopment"
}

variable "service" {
  description = "K8S service name"
  default = "localstack-svc"
}

variable "app" {
  description = "K8S application name"
  default = "localstack"
}

variable "port" {
  description = "K8S service port"
  default = 4566
}
