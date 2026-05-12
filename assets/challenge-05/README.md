# Challenge 5 Solution: Multi-Tier Infrastructure

Complete production-ready infrastructure with environment-aware configuration.

## Architecture

- **Web Server**: Nginx serving custom HTML
- **App Server**: Python HTTP server on port 8080
- **DB Server**: SQLite database

## Usage

### Deploy Infrastructure
```bash
terraform init
terraform apply
```

The environment is controlled via the `environment` variable (default: "dev").

## Features

- ✅ Environment-aware configuration
- ✅ Variable validation
- ✅ Comprehensive outputs
- ✅ Production-ready specs
- ✅ Multi-tier architecture

## Environment Configuration

The `environment` variable controls resource specifications:
- **Dev**: 1 vCPU, 1 GB RAM, 15 GB disk per VM
- **Prod**: 2 vCPU, 2-4 GB RAM, 25 GB disk per VM

Configure via `terraform.tfvars` or `-var` flag.

## Testing

```bash
# Check state
terraform state list

# View outputs
terraform output

# Inspect resources
terraform show