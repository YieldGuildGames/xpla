terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Local variables
locals {
  vm_name      = "xpla002"
  network_tags = ["rpc"]
  labels = {
    validator = "xpla"
    node      = "xpla"
  }
} 