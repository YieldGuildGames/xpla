variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "xpla-371616"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for the VM instance"
  type        = string
  default     = "e2-standard-4"
}

variable "boot_disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 10
}

variable "data_disk_size" {
  description = "The size of the data disk in GB"
  type        = number
  default     = 1000
}

variable "image_family" {
  description = "The image family for the boot disk"
  type        = string
  default     = "debian-11"
}

variable "image_project" {
  description = "The project containing the image"
  type        = string
  default     = "debian-cloud"
}

variable "network" {
  description = "The network to deploy the VM in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to deploy the VM in"
  type        = string
  default     = "default"
}

variable "docker_image" {
  description = "The Docker image to use for the XPLA validator"
  type        = string
  default     = "gcr.io/xpla-371616/xpla:latest"
} 