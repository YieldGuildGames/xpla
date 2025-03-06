output "instance_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.xpla_validator.name
}

output "instance_external_ip" {
  description = "The external IP address of the VM instance"
  value       = google_compute_instance.xpla_validator.network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ip" {
  description = "The internal IP address of the VM instance"
  value       = google_compute_instance.xpla_validator.network_interface[0].network_ip
}

output "boot_disk_name" {
  description = "The name of the boot disk"
  value       = google_compute_disk.boot_disk.name
}

output "data_disk_name" {
  description = "The name of the data disk"
  value       = google_compute_disk.data_disk.name
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh deezle@${google_compute_instance.xpla_validator.network_interface[0].access_config[0].nat_ip}"
} 