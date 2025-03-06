# Boot disk for VM
resource "google_compute_disk" "boot_disk" {
  name  = local.vm_name
  type  = "pd-standard"
  size  = var.boot_disk_size
  zone  = var.zone
  image = "projects/${var.image_project}/global/images/family/${var.image_family}"

  physical_block_size_bytes = 4096
}

# Data disk for the xplachain
resource "google_compute_disk" "data_disk" {
  name = "xplachain002"
  type = "pd-standard"
  size = var.data_disk_size
  zone = var.zone

  physical_block_size_bytes = 4096
}

# VM Instance
resource "google_compute_instance" "xpla_validator" {
  name         = local.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = local.network_tags

  labels = local.labels

  boot_disk {
    auto_delete = true
    source      = google_compute_disk.boot_disk.self_link
  }

  attached_disk {
    source      = google_compute_disk.data_disk.self_link
    device_name = "xplachain002"
    mode        = "READ_WRITE"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = <<EOF
deezle:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGgeZlDiX9xfAk6lzdXWEJKXEcaHAsg8fOiI0Wu8vkjAMSBs7VfhbIRBvGbHiTheNfRERuVtMMbjOtM86CM5hos= google-ssh {"userName":"deezle@yieldguild.games","expireOn":"2025-01-17T16:57:20+0000"}
deezle:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCAfoaDFW8qAc+q59IiISPgRDEqzHAevQOALkmwXtOJCI9BpPXxGwGsVH1Xep7IaAvRbWu+1BBhC8lpG+teDHWIQcS2Nc+IgWwzpq0J1HIFtGv9fq+RYn1QMUe2CfRuongZnGcTktNgldKom0XYTqsHna3JyD7XhZM4Aj/hqHL0wct3lI/iHp/D9/LAjGODYUQT2woovDp5lfJ8cE+b1onG99hBe964gqz22FdL0bb7aE3x9en679FqsavjN9nD9bP6m0CEC4MCHk9AwDac0QYxvDdF4O+/b2QOkw3yow9ZsKQNoX8TskVF74LiPZOFEovKF/ogVb9iFU6gv1pnZ60D google-ssh {"userName":"deezle@yieldguild.games","expireOn":"2025-01-17T16:57:24+0000"}
EOF
  }

  service_account {
    email = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  allow_stopping_for_update = true

  # Ensure directories for docker compose and data exist
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Install Docker and Docker Compose
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Create directories for data volumes
    mkdir -p /mnt/data/xpla
    mkdir -p /mnt/data/genesis

    # Create docker-compose configuration
    cat > /root/docker-compose.yml << 'COMPOSE'
    version: "3.7"
    services:
      node1:
        container_name: xpla-validator
        image: ${var.docker_image}
        logging:
            driver: "json-file"
            options:
                max-size: "100m"
                max-file: "5"
        command: xplad start
        volumes:
          - /mnt/data/xpla:/root/.xpla
          - /mnt/data/genesis:/root/.genesis
        ports:
          - "8545:8545"
          - "9090:9090"
          - "26656:26656"
          - "localhost:26657:26657"
    COMPOSE

    # Set the device name for the attached disk
    DEVICE_NAME=$(ls -l /dev/disk/by-id/google-xplachain002 | awk '{print $11}' | xargs basename)
    if [ -b "/dev/$DEVICE_NAME" ]; then
      # Check if disk is already formatted
      if ! blkid "/dev/$DEVICE_NAME"; then
        # Format the disk if not already formatted
        mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard "/dev/$DEVICE_NAME"
      fi

      # Create mount point
      mkdir -p /mnt/data

      # Add to fstab
      echo "/dev/$DEVICE_NAME /mnt/data ext4 discard,defaults,nofail 0 2" | tee -a /etc/fstab

      # Mount the disk
      mount -a
    fi
  EOT
}

# Get project info for service account
data "google_project" "project" {
  project_id = var.project_id
}

# Firewall rule to allow the exposed ports
resource "google_compute_firewall" "xpla_firewall" {
  name    = "allow-xpla-ports"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["8545", "9090", "26656", "26657"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.network_tags
} 