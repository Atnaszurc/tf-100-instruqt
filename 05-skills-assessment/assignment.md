---
slug: skills-assessment
id: fv7s1evxx0qn
type: challenge
title: 'Challenge 5: Skills Assessment'
teaser: Put all your Terraform knowledge to the test with a comprehensive project
notes:
- type: text
  contents: "# Challenge 5: Skills Assessment\n\nThis is your final challenge - a
    comprehensive assessment of everything you've learned!\n\n**What You'll Build:**\n-
    Multi-tier application infrastructure\n- Multiple environments using workspaces\n-
    Automated configuration with cloud-init\n- Proper variable management\n- Complete
    outputs and documentation\n\n**No Step-by-Step Instructions!**\nYou'll receive
    requirements and must implement them yourself.\n\nShow what you've learned! \U0001F680\n"
tabs:
- id: ikynvrcwrkw8
  title: Terminal
  type: terminal
  hostname: workstation
- id: bt4sjhs5pelg
  title: Code Editor
  type: code
  hostname: workstation
  path: /root/terraform-lab
difficulty: basic
timelimit: 7200
enhanced_loading: null
---

> **📝 Note on Code Examples**: This assignment contains simplified code examples for teaching purposes. The complete working solution in `/root/terraform-lab-solutions/challenge-05` uses libvirt provider 0.9+ syntax. Refer to the solution directory for production-ready examples.

# Challenge 5: Skills Assessment

## 🎯 Assessment Overview

This is your final challenge! You'll build a complete, production-ready infrastructure using everything you've learned in the previous challenges.

**Important**: This challenge provides requirements, not step-by-step instructions. You must design and implement the solution yourself.

**Estimated Time**: 90-120 minutes

---

## 📋 Project Requirements

### Scenario

You're tasked with deploying a development and production environment for a web application. The infrastructure must be:

- **Flexible**: Use variables for all configurable values
- **Reusable**: Use workspaces for dev and prod environments
- **Automated**: Use cloud-init for VM configuration
- **Well-documented**: Include comprehensive outputs
- **Production-ready**: Follow best practices

---

## 🎯 Technical Requirements

### 1. Infrastructure Components

You must create:

**Network Layer:**
- Custom virtual network with NAT mode
- CIDR: 10.20.0.0/24
- DHCP and DNS enabled
- Network name should include environment (workspace)

**Storage Layer:**
- Base Ubuntu 22.04 image (download once, reuse)
- Separate volumes for each VM
- Dev VMs: 15GB disks
- Prod VMs: 25GB disks

**Compute Layer:**
- **Web Server VM**:
  - Dev: 1GB RAM, 1 vCPU
  - Prod: 2GB RAM, 2 vCPU
  - Install and configure Nginx
  - Serve custom HTML page with environment info

- **Application Server VM**:
  - Dev: 1GB RAM, 1 vCPU
  - Prod: 2GB RAM, 2 vCPU
  - Run Python HTTP server on port 8080
  - Return JSON with server info

- **Database Server VM**:
  - Dev: 1GB RAM, 1 vCPU
  - Prod: 4GB RAM, 2 vCPU
  - Install SQLite
  - Create sample database with tables

### 2. Configuration Requirements

**Variables** (create `variables.tf`):
- `environment` - Environment name (use workspace by default)
- `project_name` - Project identifier
- `network_cidr` - Network CIDR block
- `vm_specs` - Map of VM specifications per environment
- `tags` - Common resource tags

**Validation Rules**:
- Environment must be "dev" or "prod"
- Network CIDR must be valid
- VM specs must have required fields

**Local Values** (create `locals.tf`):
- Computed resource names (include environment)
- Common tags (merge user tags with defaults)
- VM configurations (derived from variables)

**Outputs** (create `outputs.tf`):
- All VM IP addresses
- Network information
- Infrastructure summary
- Service URLs
- Resource counts

### 3. Cloud-Init Requirements

Create separate cloud-init files for each VM type:

**Web Server** (`cloud-init-web.yaml`):
- Set hostname: `{environment}-web-server`
- Install: nginx, curl, vim
- Create custom index.html showing:
  - Environment name
  - Hostname
  - Server role
  - Deployment timestamp
- Enable and start nginx

**App Server** (`cloud-init-app.yaml`):
- Set hostname: `{environment}-app-server`
- Install: python3, curl, vim
- Create Python HTTP server script
- Return JSON with:
  - Environment
  - Hostname
  - Status
  - Timestamp
- Run server on port 8080

**DB Server** (`cloud-init-db.yaml`):
- Set hostname: `{environment}-db-server`
- Install: sqlite3, curl, vim
- Create database: `/opt/database/app.db`
- Create tables: users, products
- Insert sample data

### 4. Workspace Requirements

Create and deploy to two workspaces:
- **dev**: Development environment (smaller resources)
- **prod**: Production environment (larger resources)

Each workspace must have:
- Complete infrastructure (network + 3 VMs)
- Environment-specific resource names
- Environment-specific resource sizes
- Independent state files

### 5. Code Organization

Organize your code into these files:
- `main.tf` - Provider and terraform configuration
- `variables.tf` - All input variables
- `locals.tf` - Local values and computations
- `network.tf` - Network resources
- `storage.tf` - Storage volumes
- `cloud-init.tf` - Cloud-init disk resources
- `vms.tf` - Virtual machine definitions
- `outputs.tf` - All outputs
- `cloud-init-web.yaml` - Web server configuration
- `cloud-init-app.yaml` - App server configuration
- `cloud-init-db.yaml` - Database server configuration

### 6. Best Practices

Your solution must demonstrate:
- ✅ Proper variable usage and validation
- ✅ DRY principle (no repetition)
- ✅ Clear resource naming conventions
- ✅ Explicit dependencies where needed
- ✅ Comprehensive outputs
- ✅ Well-formatted code (`terraform fmt`)
- ✅ Valid configuration (`terraform validate`)
- ✅ Workspace-aware resource naming
- ✅ Base volume + derived volume pattern
- ✅ Proper cloud-init integration

---

## 🧪 Testing Requirements

Your infrastructure must pass these tests:

### Functional Tests

1. **Both workspaces deploy successfully**
   ```bash
   terraform workspace select dev
   terraform apply -auto-approve

   terraform workspace select prod
   terraform apply -auto-approve
   ```

2. **All VMs are running**
   ```bash
   virsh list | grep "dev-"
   virsh list | grep "prod-"
   ```

3. **VMs have IP addresses**
   ```bash
   terraform output vm_ips
   ```

4. **Web server responds** (after 2-3 min boot time)
   ```bash
   WEB_IP=$(terraform output -json vm_ips | jq -r '.web_server')
   curl http://$WEB_IP
   ```

5. **App server responds**
   ```bash
   APP_IP=$(terraform output -json vm_ips | jq -r '.app_server')
   curl http://$APP_IP:8080
   ```

6. **Resource counts are correct**
   - Dev: 1 network, 4 volumes, 3 VMs
   - Prod: 1 network, 4 volumes, 3 VMs

### Code Quality Tests

1. **Code is formatted**
   ```bash
   terraform fmt -check
   ```

2. **Configuration is valid**
   ```bash
   terraform validate
   ```

3. **No hardcoded values** (use variables)

4. **Outputs are comprehensive**

---

## 💡 Hints and Tips

### Getting Started

1. Start with `main.tf` and provider configuration
2. Define variables in `variables.tf`
3. Create network resources
4. Create storage resources
5. Write cloud-init files
6. Create VM resources
7. Define outputs
8. Test in dev workspace first
9. Deploy to prod workspace
10. Verify everything works

### Common Patterns

**Workspace-Aware Naming:**
```hcl
name = "${terraform.workspace}-${var.project_name}-web"
```

**Environment-Specific Specs:**
```hcl
memory = var.vm_specs[terraform.workspace].web.memory
```

**Base + Derived Volumes:**
```hcl
resource "libvirt_volume" "base" {
  name   = "ubuntu-base.qcow2"
  source = "https://cloud-images.ubuntu.com/..."
}

resource "libvirt_volume" "web_disk" {
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_specs[terraform.workspace].web.disk_size
}
```

### Troubleshooting

If you get stuck:
- Check previous challenge solutions in `/root/terraform-lab-solutions/`
- Use `terraform console` to test expressions
- Enable debug logging: `export TF_LOG=DEBUG`
- Validate frequently: `terraform validate`
- Check state: `terraform state list`

---

## 📚 Reference Materials

You can reference:
- Previous challenge solutions in `/root/terraform-lab-solutions/`
- Terraform documentation: `terraform -help`
- Provider documentation: https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs

---

## ✅ Success Criteria

Your solution is complete when:

1. ✅ All required files exist and are properly organized
2. ✅ Code is formatted and valid
3. ✅ Variables are defined with validation
4. ✅ Both workspaces (dev, prod) deploy successfully
5. ✅ All 6 VMs are running (3 per workspace)
6. ✅ All VMs have IP addresses
7. ✅ Web servers respond with custom HTML
8. ✅ App servers respond with JSON
9. ✅ Outputs provide complete infrastructure info
10. ✅ Resources are properly named with environment prefix
11. ✅ Cloud-init configurations work correctly
12. ✅ No hardcoded values (everything uses variables)

---

## 🎓 Assessment Rubric

Your solution will be evaluated on:

### Functionality (40 points)
- Infrastructure deploys successfully (10 pts)
- All VMs are created and running (10 pts)
- Services are accessible (10 pts)
- Cloud-init works correctly (10 pts)

### Code Quality (30 points)
- Proper file organization (5 pts)
- Variable usage and validation (10 pts)
- DRY principle (no repetition) (5 pts)
- Code formatting and validation (5 pts)
- Clear naming conventions (5 pts)

### Best Practices (20 points)
- Workspace usage (5 pts)
- Base + derived volume pattern (5 pts)
- Comprehensive outputs (5 pts)
- Proper dependencies (5 pts)

### Documentation (10 points)
- Variable descriptions (5 pts)
- Output descriptions (5 pts)

**Total: 100 points**

**Passing Score: 70 points**

---

## 🚀 Ready to Begin?

This is your chance to demonstrate everything you've learned!

**Remember:**
- Take your time and plan your approach
- Test frequently as you build
- Use previous challenges as reference
- Don't hesitate to use `terraform console` to test expressions
- Start with dev workspace, then deploy to prod

**Good luck! You've got this! 💪**

---

## 📝 Submission Checklist

Before clicking "Check", verify:

- [ ] All required files exist
- [ ] Code is formatted (`terraform fmt`)
- [ ] Configuration is valid (`terraform validate`)
- [ ] Dev workspace is deployed
- [ ] Prod workspace is deployed
- [ ] All VMs are running
- [ ] Outputs are defined and working
- [ ] Services are accessible (wait 2-3 min after apply)

---

**Time Limit**: 2 hours
**Difficulty**: Comprehensive Assessment
**Prerequisites**: Challenges 1-4 completed

Good luck! 🎯