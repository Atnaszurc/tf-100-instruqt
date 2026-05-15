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
    Multi-tier application infrastructure\n- Well-organized code structure\n- Automated
    configuration\n- Proper variable management\n- Complete outputs and documentation\n\n**No
    Step-by-Step Instructions!**\nYou'll receive requirements and must implement them
    yourself.\n\nShow what you've learned! \U0001F680\n"
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


## 📋 How to Approach This Challenge

**Don't Panic!** This challenge provides requirements, not step-by-step instructions. But you can break it down.

### Step-by-Step Approach

#### Phase 1: Planning (15 minutes)
Before writing ANY code:
1. Read all requirements twice
2. Sketch on paper what you need:
   - How many VMs?
   - What does each VM do?
   - What files do I need?
3. Look at previous challenges for similar patterns

#### Phase 2: Foundation (30 minutes)
Start with the basics:
1. Create `main.tf` with provider configuration
   - **Hint:** Copy from Challenge 3
2. Create `variables.tf` with basic variables
   - **Hint:** Look at Challenge 2
3. Test: `terraform init` should work

#### Phase 3: Network & Storage (20 minutes)
Build the infrastructure foundation:
1. Create `network.tf`
   - **Hint:** Challenge 3 has network examples
2. Create `storage.tf`
   - **Hint:** Base volume + derived volumes pattern
3. Test: `terraform plan` should show network and volumes

#### Phase 4: VMs (30 minutes)
Add the virtual machines:
1. Write cloud-init files first
   - **Hint:** Start with simple examples from Challenge 3
2. Create `vms.tf`
   - **Hint:** One resource block per VM type
3. Test: `terraform apply` should create VMs

#### Phase 5: Outputs & Polish (15 minutes)
Finish up:
1. Create `outputs.tf`
   - **Hint:** Challenge 2 has output examples
2. Run `terraform fmt`
3. Run `terraform validate`
4. Test all services work

**Total Time:** ~110 minutes (you have 120)

### If You Get Stuck

1. Check previous challenge solutions in `/root/terraform-lab-solutions/`
2. Use `terraform console` to test expressions
3. Read error messages carefully (they usually tell you what's wrong)
4. Take a 5-minute break and come back with fresh eyes

**You've got this!** You've learned everything you need in Challenges 1-4.
---

## 📋 Project Requirements

### Scenario

You're tasked with deploying infrastructure for a web application. The infrastructure must be:

- **Flexible**: Use variables for all configurable values
- **Well-organized**: Separate files for different resource types
- **Automated**: Proper configuration management
- **Well-documented**: Include comprehensive outputs
- **Production-ready**: Follow best practices

---

## 🎯 Technical Requirements

### 1. Infrastructure Components

You must create:

**Network Layer:**
- Custom virtual network with NAT mode
- DHCP and DNS enabled
- Network name should include environment

**Storage Layer:**
- Base Ubuntu 22.04 image (download once, reuse)
- Separate volumes for each VM
- VM disks: 15GB each

**Compute Layer:**
- **Web Server VM**:
  - 1GB RAM, 1 vCPU
  - Install and configure Nginx
  - Serve custom HTML page with environment info

- **Application Server VM**:
  - 1GB RAM, 1 vCPU
  - Run Python HTTP server on port 8080
  - Return JSON with server info

- **Database Server VM**:
  - 2GB RAM, 1 vCPU
  - Install SQLite
  - Create sample database with tables

### 2. Configuration Requirements

**Variables** (create `variables.tf`):
- `environment` - Environment name (default: "dev")
- `project_name` - Project identifier
- `network_cidr` - Network CIDR block (optional)
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

### 4. Environment Requirements

Deploy a complete environment with:
- Complete infrastructure (network + 3 VMs)
- Environment-specific resource names (controlled by `var.environment`)
- Environment-specific resource sizes (controlled by `var.environment`)
- Proper state management

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
- ✅ Environment-aware resource naming (using `var.environment`)
- ✅ Base volume + derived volume pattern
- ✅ Proper cloud-init integration

---

## 🧪 Testing Requirements

Your infrastructure must pass these tests:

### Functional Tests

1. **Infrastructure deploys successfully**
   ```bash
   terraform apply -auto-approve
   ```

2. **All VMs are running**
   ```bash
   virsh list --all
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
   - 1 network, 4 volumes, 3 VMs

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
8. Test your deployment
9. Verify everything works

### Common Patterns

**Environment-Aware Naming:**
```hcl
name = "${var.environment}-${var.project_name}-web"
```

**Environment-Specific Specs:**
```hcl
memory = var.vm_specs[var.environment].web.memory
```

**Base + Derived Volumes:**
```hcl
resource "libvirt_volume" "base" {
  name   = "ubuntu-base.qcow2"
  source = "https://cloud-images.ubuntu.com/..."
}

resource "libvirt_volume" "web_disk" {
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_specs[var.environment].web.disk_size
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
4. ✅ Infrastructure deploys successfully
5. ✅ All 3 VMs are running
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
- Environment-aware configuration (5 pts)
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
- Deploy and test your infrastructure thoroughly

**Good luck! You've got this! 💪**

---

## 📝 Submission Checklist

Before clicking "Check", verify:

- [ ] All required files exist
- [ ] Code is formatted (`terraform fmt`)
- [ ] Configuration is valid (`terraform validate`)
- [ ] Infrastructure is deployed
- [ ] All 3 VMs are running
- [ ] Outputs are defined and working
- [ ] Services are accessible (wait 2-3 min after apply)

---

**Time Limit**: 2 hours
**Difficulty**: Comprehensive Assessment
**Prerequisites**: Challenges 1-4 completed

Good luck! 🎯