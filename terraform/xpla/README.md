# XPLA Validator Terraform Configuration

This Terraform configuration sets up a GCP infrastructure for running an XPLA validator node with Docker Compose.

## Components

- GCP VM instance (e2-standard-4)
- Boot disk (Debian 11)
- Data disk (1000GB)
- Firewall rules for required ports
- Docker and Docker Compose installation
- Automatic configuration of Docker Compose for XPLA validator

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (v1.0.0+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
- A GCP project with billing enabled
- Service account with appropriate permissions

## Setup

1. Authenticate with Google Cloud:

```shell
gcloud auth application-default login
```

2. Initialize Terraform:

```shell
terraform init
```

3. Review the execution plan:

```shell
terraform plan
```

4. Apply the configuration:

```shell
terraform apply
```

5. To destroy the resources when no longer needed:

```shell
terraform destroy
```

## Customization

You can customize the deployment by modifying the variables in `variables.tf` or by providing them at runtime:

```shell
terraform apply -var="project_id=your-project" -var="machine_type=e2-standard-8"
```

## Docker Image

The configuration uses the XPLA Docker image specified in the `docker_image` variable. Make sure the image exists in your Google Container Registry (GCR) before deploying.

## Accessing the VM

After a successful deployment, you can SSH into the VM using the output command:

```shell
ssh deezle@<EXTERNAL_IP>
```

## Running the XPLA Validator

Once you've SSHed into the VM, you can start the validator:

```shell
cd /root
docker compose up -d
```

## Ports

The following ports are configured and exposed:

- 8545: Ethereum JSON-RPC
- 9090: gRPC
- 26656: P2P
- 26657: Tendermint RPC (localhost only)
