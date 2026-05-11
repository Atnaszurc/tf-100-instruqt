# Challenge 5 Solution: Multi-Tier Infrastructure

Complete production-ready infrastructure with dev and prod environments.

## Architecture

- **Web Server**: Nginx serving custom HTML
- **App Server**: Python HTTP server on port 8080
- **DB Server**: SQLite database

## Usage

### Deploy to Dev
```bash
terraform workspace new dev
terraform workspace select dev
terraform init
terraform apply
```

### Deploy to Prod
```bash
terraform workspace new prod
terraform workspace select prod
terraform apply
```

## Features

- ✅ Workspace-based environments
- ✅ Variable validation
- ✅ Comprehensive outputs
- ✅ Production-ready specs
- ✅ Multi-tier architecture

## Environment Differences

**Dev Environment:**
- 1 vCPU per VM
- 1 GB RAM per VM
- 15 GB disk per VM

**Prod Environment:**
- 2 vCPU per VM
- 2-4 GB RAM per VM
- 25 GB disk per VM

## Testing

```bash
# Check state
terraform state list

# View outputs
terraform output

# Inspect resources
terraform show