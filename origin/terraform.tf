terraform {
  cloud {
    organization = "Geekle"
    workspaces {
      name = "status-monitor-origin"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
  }

  required_version = "~> 1.7"
}
