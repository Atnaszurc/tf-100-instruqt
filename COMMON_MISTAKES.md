# Common Mistakes and How to Avoid Them

This guide covers the most common mistakes learners make in the TF-100 Fundamentals Lab and how to avoid or fix them.

---

## Table of Contents

1. [Configuration Errors](#configuration-errors)
2. [State Management Issues](#state-management-issues)
3. [Resource Management Problems](#resource-management-problems)
4. [Variable and Data Handling](#variable-and-data-handling)
5. [Workspace Confusion](#workspace-confusion)
6. [Cloud-Init Issues](#cloud-init-issues)
7. [Networking Problems](#networking-problems)
8. [Performance and Timing](#performance-and-timing)

---

## Configuration Errors

### Mistake 1: Forgetting to Initialize Terraform

**Problem:**
```bash
$ terraform plan
Error: Terraform has not been initialized
```

**Why It Happens:**
Running Terraform commands before `terraform init`.

**Solution:**
```bash
# Always initialize first
terraform init

# Then proceed with other commands
terraform plan
terraform apply
```

**Prevention:**
- Make `terraform init` your first command in any new directory
- Re-run after adding new providers or modules

---

### Mistake 2: Invalid HCL Syntax

**Problem:**
```hcl
resource "libvirt_domain" "vm" {
  name = "my-vm"
  memory = 2048
  vcpu = 2
  # Missing closing brace
```

**Why It Happens:**
- Missing braces, brackets, or quotes
- Incorrect indentation
- Typos in resource/attribute names

**Solution:**
```bash
# Validate configuration
terraform validate

# Format code properly
terraform fmt

# Use editor with HCL syntax highlighting
```

**Prevention:**
- Use `terraform fmt` regularly
- Enable syntax highlighting in your editor
- Validate after each significant change

---

### Mistake 3: Wrong Provider Configuration

**Problem:**
```hcl
provider "libvirt" {
  uri = "qemu://system"  # Wrong: should be qemu:///system
}
```

**Why It Happens:**
Typos in provider URI or configuration.

**Solution:**
```hcl
# Correct provider configuration
provider "libvirt" {
  uri = "qemu:///system"  # Note the three slashes
}
```

**Prevention:**
- Copy provider configuration from documentation
- Test provider connection early
- Check provider version compatibility

---

## State Management Issues

### Mistake 4: Editing State Files Manually

**Problem:**
```bash
# DON'T DO THIS!
vim terraform.tfstate
```

**Why It Happens:**
Trying to "fix" state issues by editing JSON directly.

**Solution:**
```bash
# Use state commands instead
terraform state list
terraform state show resource.name
terraform state mv old new
terraform state rm resource.name

# Always backup first
terraform state pull > backup.tfstate
```

**Prevention:**
- Never edit state files manually
- Use state commands for all modifications
- Keep backups before state operations

---

### Mistake 5: Losing State File

**Problem:**
```bash
$ terraform plan
Error: No state file was found!
```

**Why It Happens:**
- Deleted state file accidentally
- Working in wrong directory
- State file not committed (if using version control)

**Solution:**
```bash
# Check if state exists
ls -la terraform.tfstate*

# Check workspace
terraform workspace show

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Or re-import resources
terraform import resource.name resource-id
```

**Prevention:**
- Use remote state for teams
- Don't commit state to git (use .gitignore)
- Keep regular backups
- Use state locking

---

### Mistake 6: State Lock Conflicts

**Problem:**
```bash
Error: Error acquiring the state lock
Lock Info:
  ID: abc123
  Who: user@hostname
```

**Why It Happens:**
- Another terraform process is running
- Previous process crashed without releasing lock
- Network issues with remote state

**Solution:**
```bash
# Check if process is actually running
ps aux | grep terraform

# If stuck, force unlock (use carefully!)
terraform force-unlock abc123

# Better: wait for other operation to complete
```

**Prevention:**
- Don't run multiple terraform commands simultaneously
- Use proper CI/CD pipelines with locking
- Monitor long-running operations

---

## Resource Management Problems

### Mistake 7: Resource Name Conflicts

**Problem:**
```bash
Error: resource with name "vm" already exists
```

**Why It Happens:**
- Creating resources with duplicate names
- Not using workspace-aware naming
- Reusing names across environments

**Solution:**
```hcl
# Use workspace in names
resource "libvirt_domain" "vm" {
  name = "${terraform.workspace}-vm"  # dev-vm, prod-vm, etc.
}

# Or use unique identifiers
resource "libvirt_domain" "vm" {
  name = "${var.environment}-${var.project}-vm"
}
```

**Prevention:**
- Always include environment in resource names
- Use consistent naming conventions
- Check existing resources before creating

---

### Mistake 8: Incorrect Resource Dependencies

**Problem:**
```bash
Error: resource depends on resource that doesn't exist yet
```

**Why It Happens:**
Terraform can't determine correct creation order.

**Solution:**
```hcl
# Use implicit dependencies (preferred)
resource "libvirt_domain" "vm" {
  disk {
    volume_id = libvirt_volume.disk.id  # Implicit dependency
  }
}

# Or explicit dependencies when needed
resource "libvirt_domain" "vm" {
  depends_on = [libvirt_network.app_network]
}
```

**Prevention:**
- Reference resource attributes for implicit dependencies
- Use `depends_on` only when necessary
- Review dependency graph: `terraform graph`

---

### Mistake 9: Destroying Resources Accidentally

**Problem:**
```bash
$ terraform destroy
# Oops! Destroyed production!
```

**Why It Happens:**
- Running destroy in wrong workspace
- Not checking what will be destroyed
- No confirmation step

**Solution:**
```bash
# Always check workspace first
terraform workspace show

# Review what will be destroyed
terraform plan -destroy

# Use targeted destroy if needed
terraform destroy -target=resource.name

# Protect critical resources
resource "libvirt_domain" "prod_vm" {
  lifecycle {
    prevent_destroy = true
  }
}
```

**Prevention:**
- Always verify workspace before destroy
- Use `prevent_destroy` for critical resources
- Require approval for production destroys
- Use separate accounts/credentials for prod

---

## Variable and Data Handling

### Mistake 10: Hardcoded Values

**Problem:**
```hcl
resource "libvirt_domain" "vm" {
  name   = "my-vm"        # Hardcoded
  memory = 2048           # Hardcoded
  vcpu   = 2              # Hardcoded
}
```

**Why It Happens:**
Not using variables for configurable values.

**Solution:**
```hcl
# Define variables
variable "vm_name" {
  type = string
}

variable "vm_memory" {
  type    = number
  default = 2048
}

# Use variables
resource "libvirt_domain" "vm" {
  name   = var.vm_name
  memory = var.vm_memory
  vcpu   = var.vm_vcpu
}
```

**Prevention:**
- Use variables for all configurable values
- Use locals for computed values
- Keep configuration DRY (Don't Repeat Yourself)

---

### Mistake 11: Missing Variable Validation

**Problem:**
```hcl
variable "environment" {
  type = string
  # No validation - accepts any value!
}
```

**Why It Happens:**
Not adding validation rules to variables.

**Solution:**
```hcl
variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

**Prevention:**
- Add validation to all critical variables
- Provide clear error messages
- Test validation rules

---

### Mistake 12: Incorrect for_each Usage

**Problem:**
```hcl
resource "libvirt_domain" "vm" {
  for_each = ["vm1", "vm2", "vm3"]  # Error: must be map or set
}
```

**Why It Happens:**
Using list instead of map/set with for_each.

**Solution:**
```hcl
# Convert list to set
resource "libvirt_domain" "vm" {
  for_each = toset(["vm1", "vm2", "vm3"])
  name     = each.key
}

# Or use map
resource "libvirt_domain" "vm" {
  for_each = {
    vm1 = { memory = 1024 }
    vm2 = { memory = 2048 }
  }
  name   = each.key
  memory = each.value.memory
}
```

**Prevention:**
- Use `toset()` for lists
- Prefer maps for complex data
- Use count for simple numeric iteration

---

## Workspace Confusion

### Mistake 13: Wrong Workspace

**Problem:**
```bash
# Thinking you're in dev, but actually in prod
$ terraform workspace show
prod

$ terraform destroy  # Oops!
```

**Why It Happens:**
Not checking current workspace before operations.

**Solution:**
```bash
# Always check workspace first
terraform workspace show

# Switch to correct workspace
terraform workspace select dev

# List all workspaces
terraform workspace list
```

**Prevention:**
- Check workspace before every operation
- Use workspace in shell prompt
- Add workspace to resource names
- Use separate state backends per environment

---

### Mistake 14: Workspace State Confusion

**Problem:**
```bash
# Created resources in default workspace
# Can't find them in dev workspace
```

**Why It Happens:**
Each workspace has separate state.

**Solution:**
```bash
# Check which workspace has the resources
terraform workspace select default
terraform state list

terraform workspace select dev
terraform state list

# Resources are in the workspace where they were created
```

**Prevention:**
- Understand workspace isolation
- Document which workspace is for what
- Use consistent workspace naming
- Consider separate directories for complex cases

---

## Cloud-Init Issues

### Mistake 15: Invalid YAML Syntax

**Problem:**
```yaml
#cloud-config
users:
  - name: ubuntu
  sudo: ALL=(ALL) NOPASSWD:ALL  # Wrong indentation!
```

**Why It Happens:**
Incorrect YAML indentation or syntax.

**Solution:**
```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL  # Correct indentation
```

**Prevention:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('cloud-init.yaml'))"

# Use YAML linter
yamllint cloud-init.yaml

# Check cloud-init logs on VM
# (via console after boot)
cloud-init status
journalctl -u cloud-init
```

---

### Mistake 16: Cloud-Init Not Running

**Problem:**
VM boots but cloud-init configuration not applied.

**Why It Happens:**
- Cloud-init disk not attached
- Wrong cloud-init format
- VM doesn't support cloud-init

**Solution:**
```hcl
# Ensure cloud-init disk is attached
resource "libvirt_domain" "vm" {
  cloudinit = libvirt_cloudinit_disk.init.id  # Must be set
  
  # ... other configuration
}

# Check cloud-init disk exists
resource "libvirt_cloudinit_disk" "init" {
  name      = "init.iso"
  pool      = "default"
  user_data = file("cloud-init.yaml")
}
```

**Prevention:**
- Always attach cloud-init disk to VMs
- Use cloud-enabled base images
- Test cloud-init on one VM first
- Check cloud-init logs after boot

---

## Networking Problems

### Mistake 17: Network Address Conflicts

**Problem:**
```bash
Error: network address conflicts with existing network
```

**Why It Happens:**
Using CIDR that overlaps with existing networks.

**Solution:**
```hcl
# Use non-conflicting private ranges
resource "libvirt_network" "app" {
  addresses = ["10.17.3.0/24"]   # Good
  # Not: ["192.168.1.0/24"]      # Might conflict with host
}
```

**Prevention:**
- Use unique private IP ranges
- Check existing networks: `virsh net-list`
- Document network allocations
- Use /24 or smaller subnets

---

### Mistake 18: VMs Not Getting IP Addresses

**Problem:**
VMs start but don't get IP addresses.

**Why It Happens:**
- DHCP not enabled on network
- Not waiting for lease
- Network not started

**Solution:**
```hcl
resource "libvirt_network" "app" {
  dhcp {
    enabled = true  # Must be enabled
  }
}

resource "libvirt_domain" "vm" {
  network_interface {
    network_id     = libvirt_network.app.id
    wait_for_lease = true  # Wait for IP
  }
}
```

**Prevention:**
- Enable DHCP on networks
- Use `wait_for_lease = true`
- Check network is active: `virsh net-list`
- Verify DHCP leases: `virsh net-dhcp-leases network-name`

---

## Performance and Timing

### Mistake 19: Not Waiting for VMs to Boot

**Problem:**
```bash
$ terraform apply
# Immediately try to access service
$ curl http://VM_IP
# Connection refused
```

**Why It Happens:**
VMs need time to boot and run cloud-init.

**Solution:**
```bash
# Wait after apply
terraform apply -auto-approve
sleep 180  # Wait 2-3 minutes

# Then test services
WEB_IP=$(terraform output -json vm_ips | jq -r '.web_server')
curl http://$WEB_IP
```

**Prevention:**
- Always wait 2-3 minutes after VM creation
- Check VM console for boot progress
- Use health checks in automation
- Be patient with cloud-init

---

### Mistake 20: Running Out of Resources

**Problem:**
```bash
Error: insufficient memory to create VM
```

**Why It Happens:**
- Too many VMs running
- VMs configured with too much memory
- Host system resource limits

**Solution:**
```bash
# Check available resources
free -h
virsh list --all

# Destroy unused VMs
terraform workspace select old-workspace
terraform destroy

# Reduce VM sizes
variable "vm_memory" {
  default = 1024  # Instead of 4096
}
```

**Prevention:**
- Monitor host resources
- Use appropriate VM sizes for testing
- Clean up old workspaces
- Use smaller VMs for dev/testing

---

## Quick Reference: Error Messages

### "No state file found"
- **Cause**: State file missing or wrong directory
- **Fix**: Check directory, restore from backup, or re-import

### "Resource already exists"
- **Cause**: Duplicate resource names
- **Fix**: Use unique names with workspace/environment prefix

### "Invalid for_each argument"
- **Cause**: Using list instead of map/set
- **Fix**: Use `toset()` or convert to map

### "State lock timeout"
- **Cause**: Another process has lock or stuck lock
- **Fix**: Wait or use `terraform force-unlock`

### "Provider configuration not found"
- **Cause**: Missing or incorrect provider block
- **Fix**: Add proper provider configuration

### "Variable validation failed"
- **Cause**: Invalid variable value
- **Fix**: Provide valid value matching validation rules

### "Network not found"
- **Cause**: Network doesn't exist or wrong name
- **Fix**: Check network exists with `virsh net-list`

### "Volume not found"
- **Cause**: Volume doesn't exist or wrong reference
- **Fix**: Check volume exists with `virsh vol-list default`

---

## Best Practices Summary

1. **Always initialize**: Run `terraform init` first
2. **Validate often**: Use `terraform validate` frequently
3. **Format code**: Run `terraform fmt` regularly
4. **Check workspace**: Verify workspace before operations
5. **Use variables**: Avoid hardcoded values
6. **Add validation**: Validate critical variables
7. **Backup state**: Before state modifications
8. **Wait for VMs**: Give cloud-init time to run
9. **Clean up**: Destroy unused resources
10. **Read errors**: Error messages usually tell you what's wrong

---

## Getting Help

If you're stuck:

1. **Read the error message carefully** - it usually tells you what's wrong
2. **Check previous challenge solutions** in `/root/terraform-lab-solutions/`
3. **Use `terraform console`** to test expressions
4. **Enable debug logging**: `export TF_LOG=DEBUG`
5. **Validate configuration**: `terraform validate`
6. **Check state**: `terraform state list`
7. **Review documentation**: `terraform -help <command>`

Remember: Everyone makes mistakes! The key is learning from them. 🚀