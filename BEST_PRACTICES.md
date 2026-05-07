# Terraform Best Practices Guide

This guide covers industry-standard best practices for writing, organizing, and managing Terraform code. Following these practices will help you create maintainable, scalable, and production-ready infrastructure.

---

## Table of Contents

1. [Code Organization](#code-organization)
2. [Naming Conventions](#naming-conventions)
3. [Variable Management](#variable-management)
4. [State Management](#state-management)
5. [Resource Management](#resource-management)
6. [Security Practices](#security-practices)
7. [Testing and Validation](#testing-and-validation)
8. [Documentation](#documentation)
9. [Version Control](#version-control)
10. [Team Collaboration](#team-collaboration)

---

## Code Organization

### File Structure

**✅ DO: Use standard file layout**
```
terraform-project/
├── main.tf           # Primary resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider versions
├── terraform.tfvars  # Variable values (gitignored)
├── README.md         # Documentation
└── modules/          # Local modules
    └── network/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**❌ DON'T: Put everything in one file**
```
# Bad: single massive file
everything.tf  # 2000+ lines
```

### Logical Grouping

**✅ DO: Group related resources**
```hcl
# network.tf
resource "libvirt_network" "app" { }
resource "libvirt_network" "db" { }

# compute.tf
resource "libvirt_domain" "web" { }
resource "libvirt_domain" "app" { }

# storage.tf
resource "libvirt_volume" "data" { }
resource "libvirt_pool" "storage" { }
```

**❌ DON'T: Mix unrelated resources**
```hcl
# main.tf - confusing mix
resource "libvirt_network" "app" { }
resource "libvirt_domain" "web" { }
resource "libvirt_network" "db" { }
resource "libvirt_volume" "data" { }
```

---

## Naming Conventions

### Resource Names

**✅ DO: Use descriptive, consistent names**
```hcl
# Good: clear purpose and scope
resource "libvirt_network" "web_tier_network" {
  name = "${var.environment}-web-network"
}

resource "libvirt_domain" "application_server" {
  name = "${var.environment}-app-server-${count.index + 1}"
}
```

**❌ DON'T: Use vague or inconsistent names**
```hcl
# Bad: unclear purpose
resource "libvirt_network" "net1" {
  name = "network"
}

resource "libvirt_domain" "vm" {
  name = "server"
}
```

### Naming Patterns

**Use consistent patterns:**
```hcl
# Pattern: {environment}-{component}-{resource_type}
"dev-web-server"
"prod-app-database"
"staging-api-loadbalancer"

# Pattern: {project}-{environment}-{component}
"myapp-dev-frontend"
"myapp-prod-backend"
```

### Variable Names

**✅ DO: Use clear, descriptive variable names**
```hcl
variable "web_server_memory_mb" {
  description = "Memory allocation for web servers in MB"
  type        = number
  default     = 2048
}

variable "database_backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7
}
```

**❌ DON'T: Use cryptic abbreviations**
```hcl
variable "mem" {
  type    = number
  default = 2048
}

variable "bkp_ret" {
  type    = number
  default = 7
}
```

---

## Variable Management

### Variable Definitions

**✅ DO: Provide complete variable metadata**
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}
```

**❌ DON'T: Skip descriptions and validation**
```hcl
variable "environment" {
  type = string
}

variable "vm_count" {
  default = 1
}
```

### Variable Organization

**✅ DO: Group related variables**
```hcl
# variables.tf

# Environment Configuration
variable "environment" { }
variable "region" { }
variable "project_name" { }

# Network Configuration
variable "network_cidr" { }
variable "subnet_cidrs" { }

# Compute Configuration
variable "vm_count" { }
variable "vm_memory" { }
variable "vm_vcpu" { }
```

### Sensitive Variables

**✅ DO: Mark sensitive data**
```hcl
variable "database_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API authentication key"
  type        = string
  sensitive   = true
}
```

**✅ DO: Use external secret management**
```hcl
# Retrieve from HashiCorp Vault
data "vault_generic_secret" "db_password" {
  path = "secret/database/password"
}

resource "libvirt_domain" "db" {
  # Use secret from Vault
  cloudinit = templatefile("cloud-init.yaml", {
    db_password = data.vault_generic_secret.db_password.data["password"]
  })
}
```

**❌ DON'T: Hardcode secrets**
```hcl
# Bad: hardcoded password
resource "libvirt_domain" "db" {
  cloudinit = templatefile("cloud-init.yaml", {
    db_password = "SuperSecret123!"  # Never do this!
  })
}
```

---

## State Management

### Remote State

**✅ DO: Use remote state for teams**
```hcl
# versions.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**Benefits:**
- Team collaboration
- State locking
- Encryption at rest
- Version history
- Disaster recovery

### State Security

**✅ DO: Protect state files**
```bash
# .gitignore
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform/
```

**✅ DO: Enable state encryption**
```hcl
terraform {
  backend "s3" {
    encrypt = true  # Always encrypt
    # ... other config
  }
}
```

**✅ DO: Use state locking**
```hcl
terraform {
  backend "s3" {
    dynamodb_table = "terraform-locks"  # Prevents concurrent modifications
  }
}
```

### Workspace Strategy

**✅ DO: Use workspaces for environments**
```bash
# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Use workspace in configuration
resource "libvirt_domain" "vm" {
  name   = "${terraform.workspace}-vm"
  memory = terraform.workspace == "prod" ? 4096 : 2048
}
```

**Alternative: Separate directories**
```
environments/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

---

## Resource Management

### Resource Dependencies

**✅ DO: Use implicit dependencies**
```hcl
# Preferred: implicit dependency through reference
resource "libvirt_volume" "disk" {
  base_volume_id = libvirt_volume.base.id
}

resource "libvirt_domain" "vm" {
  disk {
    volume_id = libvirt_volume.disk.id
  }
}
```

**⚠️ CAUTION: Use explicit dependencies sparingly**
```hcl
# Only when implicit dependencies aren't sufficient
resource "libvirt_domain" "vm" {
  depends_on = [libvirt_network.app]
}
```

### Resource Lifecycle

**✅ DO: Protect critical resources**
```hcl
resource "libvirt_domain" "production_db" {
  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
  }
}
```

**✅ DO: Handle resource replacement carefully**
```hcl
resource "libvirt_domain" "vm" {
  lifecycle {
    create_before_destroy = true  # Minimize downtime
  }
}
```

**✅ DO: Ignore expected changes**
```hcl
resource "libvirt_domain" "vm" {
  lifecycle {
    ignore_changes = [
      cloudinit,  # Ignore cloud-init changes after creation
    ]
  }
}
```

### Resource Tagging

**✅ DO: Tag all resources consistently**
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.team_name
    CostCenter  = var.cost_center
  }
}

resource "libvirt_domain" "vm" {
  # Apply common tags
  xml {
    xslt = templatefile("tags.xslt", {
      tags = local.common_tags
    })
  }
}
```

---

## Security Practices

### Least Privilege

**✅ DO: Use minimal permissions**
```hcl
# Grant only necessary permissions
# Example: Read-only access for monitoring
data "libvirt_network" "existing" {
  name = "default"
}

# Don't create/modify unless needed
```

### Secrets Management

**✅ DO: Use secret management systems**
```hcl
# HashiCorp Vault
data "vault_generic_secret" "api_key" {
  path = "secret/api/key"
}

# AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}
```

**❌ DON'T: Store secrets in code or state**
```hcl
# Bad: secret in code
variable "api_key" {
  default = "sk-1234567890"  # Never do this!
}

# Bad: secret in tfvars (committed to git)
api_key = "sk-1234567890"
```

### Network Security

**✅ DO: Implement network segmentation**
```hcl
# Separate networks for different tiers
resource "libvirt_network" "web_tier" {
  addresses = ["10.0.1.0/24"]
}

resource "libvirt_network" "app_tier" {
  addresses = ["10.0.2.0/24"]
}

resource "libvirt_network" "db_tier" {
  addresses = ["10.0.3.0/24"]
}
```

**✅ DO: Use security groups/firewall rules**
```hcl
# Restrict access to necessary ports only
# (Implementation depends on provider)
```

---

## Testing and Validation

### Pre-Deployment Validation

**✅ DO: Validate before applying**
```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Check for security issues
tfsec .

# Review plan
terraform plan -out=tfplan

# Review plan in detail
terraform show tfplan
```

### Automated Testing

**✅ DO: Write Terraform tests**
```hcl
# tests/main.tftest.hcl
run "verify_vm_creation" {
  command = apply

  assert {
    condition     = libvirt_domain.vm.memory == 2048
    error_message = "VM memory should be 2048 MB"
  }
}
```

**✅ DO: Use policy as code**
```rego
# policy/vm_size.rego
package terraform

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "libvirt_domain"
  resource.change.after.memory > 8192
  msg := "VMs cannot exceed 8GB memory"
}
```

### Continuous Integration

**✅ DO: Automate validation in CI/CD**
```yaml
# .github/workflows/terraform.yml
name: Terraform CI
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      - run: terraform fmt -check
      - run: terraform init
      - run: terraform validate
      - run: terraform plan
```

---

## Documentation

### Code Documentation

**✅ DO: Document complex logic**
```hcl
# Calculate subnet CIDR blocks for each availability zone
# Uses cidrsubnet to create /24 subnets from /16 VPC
locals {
  subnet_cidrs = [
    for i in range(var.az_count) :
    cidrsubnet(var.vpc_cidr, 8, i)
  ]
}
```

**✅ DO: Document variable purposes**
```hcl
variable "vm_memory" {
  description = <<-EOT
    Memory allocation for VMs in MB.
    - Dev: 1024 MB (1 GB)
    - Staging: 2048 MB (2 GB)
    - Prod: 4096 MB (4 GB)
  EOT
  type    = number
  default = 2048
}
```

### README Documentation

**✅ DO: Maintain comprehensive README**
```markdown
# Project Name

## Overview
Brief description of infrastructure

## Prerequisites
- Terraform >= 1.15
- Libvirt/KVM installed

## Usage
```bash
terraform init
terraform plan
terraform apply
```

## Variables
| Name | Description | Default |
|------|-------------|---------|
| environment | Environment name | dev |

## Outputs
| Name | Description |
|------|-------------|
| vm_ip | VM IP address |
```

### Module Documentation

**✅ DO: Document module interfaces**
```hcl
# modules/network/README.md
# Network Module

Creates isolated network with DHCP.

## Inputs
- `network_name`: Network name (required)
- `cidr`: Network CIDR (required)

## Outputs
- `network_id`: Network ID
- `network_name`: Network name

## Example
```hcl
module "network" {
  source       = "./modules/network"
  network_name = "app-network"
  cidr         = "10.0.1.0/24"
}
```
```

---

## Version Control

### Git Practices

**✅ DO: Use .gitignore**
```gitignore
# .gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform.lock.hcl
*.tfvars
!example.tfvars
crash.log
override.tf
override.tf.json
```

**✅ DO: Commit lock file**
```bash
# Commit provider lock file for consistency
git add .terraform.lock.hcl
git commit -m "Update provider versions"
```

**✅ DO: Use meaningful commit messages**
```bash
# Good commit messages
git commit -m "Add network segmentation for 3-tier architecture"
git commit -m "Update VM memory from 2GB to 4GB for prod"
git commit -m "Fix: Correct CIDR block for database subnet"

# Bad commit messages
git commit -m "update"
git commit -m "fix stuff"
git commit -m "changes"
```

### Branching Strategy

**✅ DO: Use feature branches**
```bash
# Create feature branch
git checkout -b feature/add-monitoring

# Make changes, test, commit
terraform plan
git add .
git commit -m "Add monitoring infrastructure"

# Create pull request for review
git push origin feature/add-monitoring
```

---

## Team Collaboration

### Code Reviews

**✅ DO: Review Terraform changes**
- Check for security issues
- Verify resource naming
- Review state changes
- Validate variable usage
- Check for hardcoded values
- Ensure documentation is updated

### Change Management

**✅ DO: Use pull requests**
```bash
# Always use PRs for changes
git checkout -b feature/new-infrastructure
# Make changes
git push origin feature/new-infrastructure
# Create PR, get review, merge
```

**✅ DO: Require plan review**
```bash
# Include plan output in PR
terraform plan -out=tfplan
terraform show tfplan > plan.txt
# Attach plan.txt to PR
```

### Communication

**✅ DO: Document changes**
```markdown
## Pull Request: Add Database Infrastructure

### Changes
- Added PostgreSQL database VM
- Created isolated database network
- Configured automated backups

### Testing
- [x] terraform validate passed
- [x] terraform plan reviewed
- [x] Security scan passed
- [x] Tested in dev environment

### Rollback Plan
If issues occur:
1. terraform destroy -target=libvirt_domain.database
2. Restore from backup
```

---

## Performance Optimization

### Parallelism

**✅ DO: Adjust parallelism for large deployments**
```bash
# Increase parallelism (default: 10)
terraform apply -parallelism=20

# Decrease for rate-limited APIs
terraform apply -parallelism=5
```

### Resource Targeting

**✅ DO: Use targeted operations when appropriate**
```bash
# Apply changes to specific resource
terraform apply -target=libvirt_domain.web_server

# Destroy specific resource
terraform destroy -target=libvirt_network.old_network
```

**⚠️ CAUTION: Understand implications**
- Targeted operations can break dependencies
- Use for emergency fixes or specific scenarios
- Always follow with full apply/plan

---

## Monitoring and Maintenance

### Regular Maintenance

**✅ DO: Keep Terraform updated**
```bash
# Check current version
terraform version

# Update to latest
# (Use version manager like tfenv)
tfenv install latest
tfenv use latest
```

**✅ DO: Update providers regularly**
```bash
# Update providers
terraform init -upgrade

# Review changes
git diff .terraform.lock.hcl
```

### State Maintenance

**✅ DO: Regular state cleanup**
```bash
# Remove orphaned resources
terraform state list
terraform state rm resource.name

# Refresh state
terraform refresh
```

**✅ DO: Backup state regularly**
```bash
# Pull and backup state
terraform state pull > backup-$(date +%Y%m%d).tfstate

# Store backups securely
```

---

## Quick Reference Checklist

### Before Committing
- [ ] Run `terraform fmt`
- [ ] Run `terraform validate`
- [ ] Review `terraform plan` output
- [ ] Check for hardcoded values
- [ ] Verify variable descriptions
- [ ] Update documentation
- [ ] Add/update tests
- [ ] Check .gitignore

### Before Applying
- [ ] Review plan carefully
- [ ] Verify workspace/environment
- [ ] Check resource names
- [ ] Confirm with team (if applicable)
- [ ] Have rollback plan
- [ ] Backup state (if local)

### After Applying
- [ ] Verify resources created correctly
- [ ] Test functionality
- [ ] Update documentation
- [ ] Commit state changes (if remote)
- [ ] Notify team

---

## Additional Resources

### Official Documentation
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Module Development](https://www.terraform.io/docs/language/modules/develop/index.html)

### Community Resources
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)

### Tools
- **tfsec**: Security scanner
- **terraform-docs**: Documentation generator
- **tflint**: Linter
- **checkov**: Policy as code
- **infracost**: Cost estimation

---

## Summary

Following these best practices will help you:
- Write maintainable code
- Collaborate effectively
- Avoid common pitfalls
- Build secure infrastructure
- Scale your infrastructure as code

Remember: **Good practices today save hours of debugging tomorrow!** 🚀