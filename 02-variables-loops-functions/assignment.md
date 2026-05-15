---
slug: variables-loops-functions
id: 9fjioaj1cryo
type: challenge
title: 'Challenge 2: Variables, Loops & Functions'
teaser: Master Terraform's data handling with variables, loops, and built-in functions
notes:
- type: text
  contents: "# Challenge 2: Variables, Loops & Functions\n\nIn this challenge, you'll
    learn how to make your Terraform configurations dynamic and reusable using:\n\n-
    **Input Variables**: Accept configuration values from users\n- **Output Values**:
    Export information for other configurations\n- **Local Values**: Compute and reuse
    expressions\n- **Loops**: Create multiple similar resources efficiently\n- **Functions**:
    Transform and manipulate data\n\nLet's make your infrastructure code flexible
    and powerful! \U0001F680\n"
tabs:
- id: vtfidvhcwo52
  title: Terminal
  type: terminal
  hostname: workstation
- id: 9rx5zokgvr3o
  title: Code Editor
  type: code
  hostname: workstation
  path: /root/terraform-lab
difficulty: basic
timelimit: 5400
enhanced_loading: null
---

# Challenge 2: Variables, Loops & Functions

## 🎯 Learning Objectives

By the end of this challenge, you will be able to:

1. **Define and use input variables** with different types and validation
2. **Create output values** to expose infrastructure information
3. **Use local values** to simplify complex expressions
4. **Implement loops** using `count`, `for_each`, and `for` expressions
5. **Apply built-in functions** to transform and manipulate data
6. **Understand variable precedence** and best practices

**Estimated Time**: 90 minutes

---

## 📚 Why This Matters

### Real-World Scenario

Imagine you're managing infrastructure for multiple environments (dev, staging, production). Without variables and loops, you'd need to:

- Copy-paste configurations for each environment
- Manually update values in multiple places
- Risk inconsistencies and errors
- Struggle to scale your infrastructure

**With variables, loops, and functions**, you can:

✅ Define infrastructure once, deploy anywhere
✅ Customize deployments without changing code
✅ Create multiple similar resources efficiently
✅ Transform data to meet your needs
✅ Maintain consistency across environments

---

## 🔍 Core Concepts

### Variables: Start Simple

Before diving into all the details, let's start with the absolute basics.

**What is a variable?**
A variable is like a blank form field that you can fill in later. Instead of hardcoding "dev" everywhere in your code, you create a variable and use it wherever you need that value.

**The Simplest Variable:**

```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

**What this means in plain English:**
- "I'm creating a variable called 'environment'"
- "It holds text (string)"
- "If nobody provides a value, use 'dev'"

**Using it in your code:**
```hcl
resource "local_file" "config" {
  content  = "Environment: ${var.environment}"
  filename = "config.txt"
}
```

**Result:** When you create the file, it will say "Environment: dev"

**The magic:** Change the variable once, and it updates everywhere you used it!

---

### Variables: Adding Numbers

Once you're comfortable with text variables, numbers work the same way:

```hcl
variable "vm_memory" {
  type    = number
  default = 1024
}
```

**That's it!** Same concept, just for numbers instead of text.

**Using it:**
```hcl
resource "libvirt_domain" "vm" {
  name   = "my-vm"
  memory = var.vm_memory  # Uses 1024
}
```

---

### Variables: The Three Types You Need to Know

As a beginner, focus on these three types:

1. **string** - Text (like "dev", "hello", "192.168.1.1")
2. **number** - Numbers (like 1024, 5, 100)
3. **bool** - True or false (like true, false)

**Examples:**
```hcl
variable "name" {
  type    = string
  default = "my-app"
}

variable "count" {
  type    = number
  default = 3
}

variable "enabled" {
  type    = bool
  default = true
}
```

---

### Variables: Getting Fancy (Later)

After you master simple variables, you'll learn about:
- **Lists** - Multiple values: `["dev", "staging", "prod"]`
- **Maps** - Key-value pairs: `{dev = "small", prod = "large"}`
- **Objects** - Complex structures with multiple fields

**But don't worry about those yet!** Master simple variables first.

<details>
<summary>🔍 Click here to see advanced variable types (optional)</summary>

**List Example:**
```hcl
variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}
```

**Map Example:**
```hcl
variable "vm_sizes" {
  type = map(number)
  default = {
    dev  = 1024
    prod = 4096
  }
}
```

**Object Example:**
```hcl
variable "vm_config" {
  type = object({
    name   = string
    memory = number
    vcpu   = number
  })
  default = {
    name   = "my-vm"
    memory = 2048
    vcpu   = 2
  }
}
```

You'll use these in more advanced scenarios, but simple variables will get you very far!

</details>

---


### 1. Input Variables

Input variables let you parameterize your Terraform configurations:

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
```

**Variable Types**:
- **Primitive**: `string`, `number`, `bool`
- **Complex**: `list(type)`, `map(type)`, `set(type)`
- **Structural**: `object({...})`, `tuple([...])`

**Terraform 1.15+ Feature - Deprecated Attribute**:
```hcl
variable "old_setting" {
  type       = string
  default    = "legacy"
  deprecated = "Use 'new_setting' instead. This will be removed in v2.0."
}
```

### 2. Output Values

Outputs expose information about your infrastructure:

```hcl
output "instance_ips" {
  description = "IP addresses of created instances"
  value       = [for instance in libvirt_domain.vm : instance.network_interface[0].addresses[0]]
}

output "environment_info" {
  description = "Environment configuration summary"
  value = {
    name          = var.environment
    instance_count = var.instance_count
    created_at    = timestamp()
  }
  sensitive = false
}

# Terraform 1.15+ Feature - Output Type Constraints
output "validated_output" {
  description = "Output with type constraint"
  type        = string
  value       = var.environment
}
```

### 3. Local Values

Locals help you avoid repetition and compute derived values:

```hcl
locals {
  # Computed naming convention
  name_prefix = "${var.environment}-${var.project_name}"

  # Common tags merged with custom tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  )

  # Conditional logic
  instance_type = var.environment == "prod" ? "large" : "small"

  # Complex transformations
  vm_configs = {
    for idx in range(var.instance_count) :
    "vm-${idx}" => {
      name   = "${local.name_prefix}-vm-${idx}"
      memory = var.environment == "prod" ? 4096 : 2048
      vcpu   = var.environment == "prod" ? 4 : 2
    }
  }
}
```

### 4. Loops and Iteration

#### Count (Simple Numeric Loops)

```hcl
resource "libvirt_volume" "disk" {
  count    = var.instance_count
  name     = "disk-${count.index}.qcow2"
  pool     = "default"
  capacity = 10737418240  # 10GB
  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "vm" {
  count  = var.instance_count
  name   = "vm-${count.index}"
  memory = 2048
  vcpu   = 2
  type   = "kvm"

  devices = {
    disk = [
      {
        volume = {
          volume = libvirt_volume.disk[count.index].id
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]
  }
}
```

#### For_each (Map/Set Iteration)

```hcl
variable "vms" {
  type = map(object({
    memory = number
    vcpu   = number
  }))
  default = {
    web = {
      memory = 2048
      vcpu   = 2
    }
    db = {
      memory = 4096
      vcpu   = 4
    }
  }
}

resource "libvirt_domain" "vm" {
  for_each = var.vms

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu
  type   = "kvm"

  devices = {
    disk = [
      {
        volume = {
          volume = libvirt_volume.disk[each.key].id
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]
  }
}
```

#### For Expressions (List/Map Comprehensions)

```hcl
# List comprehension
locals {
  vm_names = [for vm in libvirt_domain.vm : vm.name]

  # With filtering
  prod_vms = [for name, vm in var.vms : name if vm.memory >= 4096]

  # Map transformation
  vm_memory_map = {
    for name, vm in var.vms :
    name => vm.memory
  }

  # Complex transformation
  vm_configs = [
    for idx in range(var.instance_count) : {
      name   = "vm-${idx}"
      memory = idx == 0 ? 4096 : 2048  # First VM gets more memory
      vcpu   = 2
    }
  ]
}
```

### 5. Built-in Functions

Terraform provides 100+ built-in functions. Here are the most useful:

#### String Functions

```hcl
locals {
  # String manipulation
  upper_env     = upper(var.environment)           # "DEV"
  lower_env     = lower(var.environment)           # "dev"
  title_env     = title(var.environment)           # "Dev"

  # String formatting
  vm_name       = format("vm-%s-%03d", var.environment, 1)  # "vm-dev-001"

  # String operations
  trimmed       = trim("  hello  ", " ")           # "hello"
  replaced      = replace("hello-world", "-", "_") # "hello_world"

  # String splitting/joining
  parts         = split("-", "web-server-01")      # ["web", "server", "01"]
  joined        = join("-", ["web", "server"])     # "web-server"
}
```

#### Collection Functions

```hcl
locals {
  # List operations
  first_vm      = element(var.vm_list, 0)
  last_vm       = element(var.vm_list, length(var.vm_list) - 1)

  # Terraform 1.9+ - Negative indices
  last_vm_new   = element(var.vm_list, -1)

  # List manipulation
  unique_tags   = distinct(["web", "db", "web"])   # ["web", "db"]
  sorted_tags   = sort(["db", "web", "cache"])     # ["cache", "db", "web"]

  # Map operations
  merged_tags   = merge(var.default_tags, var.custom_tags)

  # Lookup with default
  instance_type = lookup(var.instance_types, var.environment, "t2.micro")

  # Check membership
  is_prod       = contains(["prod", "production"], var.environment)
}
```

#### Numeric Functions

```hcl
locals {
  # Math operations
  max_memory    = max(2048, 4096, 8192)            # 8192
  min_memory    = min(2048, 4096, 8192)            # 2048

  # Rounding
  rounded       = ceil(2.3)                        # 3
  floored       = floor(2.7)                       # 2

  # Power
  memory_gb     = pow(2, 10)                       # 1024
}
```

#### Type Conversion Functions

```hcl
locals {
  # Type conversions
  string_num    = tostring(42)                     # "42"
  num_string    = tonumber("42")                   # 42
  bool_string   = tobool("true")                   # true

  # Terraform 1.15+ - convert() function
  converted     = convert("42", number)            # 42

  # Collection conversions
  list_set      = toset(["a", "b", "a"])          # ["a", "b"]
  map_list      = tolist(toset(["a", "b"]))       # ["a", "b"]
}
```

#### Encoding Functions

```hcl
locals {
  # JSON encoding/decoding
  json_string   = jsonencode({ name = "vm", count = 3 })
  json_data     = jsondecode(file("config.json"))

  # YAML decoding
  yaml_data     = yamldecode(file("config.yaml"))

  # Base64 encoding/decoding
  encoded       = base64encode("hello")
  decoded       = base64decode(local.encoded)
}
```

#### Filesystem Functions

```hcl
locals {
  # File operations
  config_file   = file("${path.module}/config.txt")
  template_file = templatefile("${path.module}/template.tpl", {
    name = var.vm_name
    env  = var.environment
  })

  # Path operations
  module_path   = path.module
  root_path     = path.root
  cwd_path      = path.cwd
}
```

#### Date/Time Functions

```hcl
locals {
  # Current timestamp
  created_at    = timestamp()                      # "2024-01-15T10:30:00Z"

  # Format timestamp
  formatted     = formatdate("YYYY-MM-DD", timestamp())
}
```

---

## 🔧 Hands-On Lab

### Lab Overview

You'll create a flexible Terraform configuration that:

1. Accepts variables for environment and VM specifications
2. Uses loops to create multiple VMs
3. Applies functions to transform data
4. Outputs useful information about created resources

### Step 1: Create Variables File

Create `variables.tf`:

```bash
cat > variables.tf << 'EOF'
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-lab"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 5
    error_message = "VM count must be between 1 and 5."
  }
}

variable "vm_specs" {
  description = "VM specifications by environment"
  type = map(object({
    memory = number
    vcpu   = number
  }))
  default = {
    dev = {
      memory = 1024
      vcpu   = 1
    }
    staging = {
      memory = 2048
      vcpu   = 2
    }
    prod = {
      memory = 4096
      vcpu   = 4
    }
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
EOF
```

### Step 2: Create Locals File

Create `locals.tf`:

```bash
cat > locals.tf << 'EOF'
locals {
  # Naming convention
  name_prefix = "${var.environment}-${var.project_name}"

  # Get specs for current environment
  vm_memory = var.vm_specs[var.environment].memory
  vm_vcpu   = var.vm_specs[var.environment].vcpu

  # Common tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
    }
  )

  # Generate VM configurations using for expression
  vm_configs = {
    for idx in range(var.vm_count) :
    "vm-${idx}" => {
      name   = "${local.name_prefix}-vm-${idx}"
      memory = local.vm_memory
      vcpu   = local.vm_vcpu
      disk_size = 10737418240  # 10GB
    }
  }

  # Tag string for metadata
  tag_string = join(",", [for k, v in local.common_tags : "${k}=${v}"])
}
EOF
```

### Step 3: Create Main Configuration

Create `main.tf`:

```bash
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Create volumes using for_each
resource "libvirt_volume" "vm_disk" {
  for_each = local.vm_configs

  name     = "${each.value.name}-disk.qcow2"
  pool     = "default"
  capacity = each.value.disk_size
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create VMs using for_each
resource "libvirt_domain" "vm" {
  for_each = local.vm_configs

  name   = each.value.name
  memory = each.value.memory
  vcpu   = each.value.vcpu
  type   = "kvm"

  devices = {
    disk = [
      {
        volume = {
          volume = libvirt_volume.vm_disk[each.key].id
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]
    interface = [
      {
        network = {
          network = "default"
        }
        model = {
          type = "virtio"
        }
        wait_for_lease = true
      }
    ]
    console = [
      {
        type = "pty"
        target = {
          port = 0
          type = "serial"
        }
      }
    ]
    graphics = [
      {
        type = "spice"
        listen = {
          type = "address"
        }
        autoport = true
      }
    ]
  }
}

# Create a file with VM information using terraform_data
resource "terraform_data" "vm_info" {
  provisioner "local-exec" {
    command = <<-EOT
      cat > vm_inventory.txt << 'INVENTORY'
      # VM Inventory - ${var.environment} Environment
      # Generated: ${timestamp()}
      # Tags: ${local.tag_string}

      ${join("\n", [for k, v in local.vm_configs : "- ${v.name}: ${v.memory}MB RAM, ${v.vcpu} vCPU"])}
      INVENTORY
    EOT
  }

  triggers_replace = {
    vm_configs = jsonencode(local.vm_configs)
  }
}
EOF
```

### Step 4: Create Outputs File

Create `outputs.tf`:

```bash
cat > outputs.tf << 'EOF'
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "vm_names" {
  description = "Names of created VMs"
  value       = [for vm in libvirt_domain.vm : vm.name]
}

output "vm_details" {
  description = "Detailed VM information"
  value = {
    for k, vm in libvirt_domain.vm :
    k => {
      name   = vm.name
      memory = vm.memory
      vcpu   = vm.vcpu
      id     = vm.id
    }
  }
}

output "total_memory" {
  description = "Total memory allocated (MB)"
  value       = sum([for vm in libvirt_domain.vm : vm.memory])
}

output "total_vcpus" {
  description = "Total vCPUs allocated"
  value       = sum([for vm in libvirt_domain.vm : vm.vcpu])
}

output "resource_tags" {
  description = "Common resource tags"
  value       = local.common_tags
}
EOF
```

### Step 5: Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

### Step 6: Experiment with Variables

Try different variable values:

```bash
# Create staging environment with 3 VMs
terraform apply -var="environment=staging" -var="vm_count=3" -auto-approve

# View outputs
terraform output

# View specific output
terraform output vm_names

# View output in JSON format
terraform output -json vm_details
```

### Step 7: Use Variable Files

Create `dev.tfvars`:

```bash
cat > dev.tfvars << 'EOF'
environment  = "dev"
project_name = "my-project"
vm_count     = 2

tags = {
  Owner = "DevTeam"
  CostCenter = "Engineering"
}
EOF
```

Apply with variable file:

```bash
terraform apply -var-file="dev.tfvars" -auto-approve
```

### Step 8: Explore Terraform Console

Use the console to experiment with functions:

```bash
# Start console
terraform console

# Try these expressions:
> var.environment
> local.name_prefix
> local.vm_configs
> [for vm in libvirt_domain.vm : vm.name]
> upper(var.environment)
> formatdate("YYYY-MM-DD", timestamp())
> length(local.vm_configs)

# Exit console
> exit
```

### Step 9: View Created Inventory

```bash
# View the generated inventory file
cat vm_inventory.txt
```

### Step 10: Clean Up

```bash
terraform destroy -auto-approve
```

---

## 🧪 Knowledge Check

Test your understanding with these questions:

<details>
<summary><strong>Question 1:</strong> What's the difference between <code>count</code> and <code>for_each</code>?</summary>

**Answer:**

- **`count`**: Creates a numeric index (0, 1, 2...). Best for simple cases where you need N identical resources. Resources are referenced by index: `resource.name[0]`

- **`for_each`**: Creates resources based on map keys or set values. Best when resources have unique identifiers. Resources are referenced by key: `resource.name["key"]`

**Key Difference**: With `count`, removing an item from the middle causes Terraform to destroy and recreate all subsequent resources. With `for_each`, each resource has a stable identifier, so removing one doesn't affect others.

**Example:**
```hcl
# count - fragile to reordering
resource "libvirt_domain" "vm" {
  count = 3
  name  = "vm-${count.index}"  # vm-0, vm-1, vm-2
}

# for_each - stable identifiers
resource "libvirt_domain" "vm" {
  for_each = toset(["web", "db", "cache"])
  name     = each.key  # web, db, cache
}
```
</details>

<details>
<summary><strong>Question 2:</strong> When should you use local values instead of variables?</summary>

**Answer:**

Use **variables** when:
- Values come from external sources (users, CI/CD)
- Values change between deployments
- You want to provide defaults but allow overrides

Use **locals** when:
- Computing derived values from variables
- Avoiding repetition of complex expressions
- Creating intermediate values for clarity
- Values are internal to the configuration

**Example:**
```hcl
# Variable - external input
variable "environment" {
  type = string
}

# Local - computed from variable
locals {
  name_prefix = "${var.environment}-myapp"
  is_prod     = var.environment == "prod"
  memory      = local.is_prod ? 4096 : 2048
}
```
</details>

<details>
<summary><strong>Question 3:</strong> What happens if you reference a variable that doesn't have a default value?</summary>

**Answer:**

Terraform will prompt you to provide a value interactively, or you must provide it via:

1. **Command line**: `-var="name=value"`
2. **Variable file**: `-var-file="file.tfvars"`
3. **Environment variable**: `TF_VAR_name=value`
4. **Auto-loaded files**: `terraform.tfvars` or `*.auto.tfvars`

If no value is provided and there's no default, Terraform will error:

```
Error: No value for required variable

  on variables.tf line 1:
   1: variable "environment" {

The variable "environment" is required, but no definition was found.
```

**Best Practice**: Always provide defaults for optional variables, and document required variables clearly.
</details>

<details>
<summary><strong>Question 4:</strong> How does variable precedence work in Terraform?</summary>

**Answer:**

Terraform applies variables in this order (later sources override earlier ones):

1. **Environment variables** (`TF_VAR_name`)
2. **terraform.tfvars** file (if present)
3. **terraform.tfvars.json** file (if present)
4. **`*.auto.tfvars`** or **`*.auto.tfvars.json`** files (alphabetical order)
5. **`-var-file`** flags (in order specified)
6. **`-var`** flags (in order specified)

**Example:**
```bash
# Variable defined in multiple places
export TF_VAR_environment=dev           # Precedence: 1
echo 'environment = "staging"' > terraform.tfvars  # Precedence: 2
terraform apply -var="environment=prod"  # Precedence: 6 (wins!)
```

Result: `environment = "prod"`
</details>

<details>
<summary><strong>Question 5:</strong> What's the difference between <code>merge()</code> and <code>concat()</code>?</summary>

**Answer:**

- **`merge()`**: Combines maps, with later maps overriding earlier ones
- **`concat()`**: Combines lists, appending all elements

**Examples:**
```hcl
# merge() - for maps
locals {
  default_tags = { Environment = "dev", ManagedBy = "Terraform" }
  custom_tags  = { Owner = "TeamA", Environment = "prod" }

  # Later values override earlier ones
  all_tags = merge(local.default_tags, local.custom_tags)
  # Result: { Environment = "prod", ManagedBy = "Terraform", Owner = "TeamA" }
}

# concat() - for lists
locals {
  list1 = ["a", "b"]
  list2 = ["c", "d"]

  combined = concat(local.list1, local.list2)
  # Result: ["a", "b", "c", "d"]
}
```
</details>

---

## 🔍 Troubleshooting Guide

### Issue: "Invalid for_each argument"

**Error:**
```
Error: Invalid for_each argument
The given "for_each" argument value is unsuitable: the "for_each" argument must be a map, or set of strings
```

**Solution:**
Ensure your `for_each` value is a map or set:

```hcl
# ❌ Wrong - list
for_each = ["a", "b", "c"]

# ✅ Correct - set
for_each = toset(["a", "b", "c"])

# ✅ Correct - map
for_each = {
  a = { value = 1 }
  b = { value = 2 }
}
```

### Issue: "Invalid count argument"

**Error:**
```
Error: Invalid count argument
The "count" value depends on resource attributes that cannot be determined until apply
```

**Solution:**
`count` must be known at plan time. Use `for_each` if the value depends on resource attributes:

```hcl
# ❌ Wrong - depends on resource
count = length(libvirt_domain.vm)

# ✅ Correct - use variable
count = var.vm_count

# ✅ Correct - use for_each for dynamic resources
for_each = { for vm in var.vms : vm.name => vm }
```

### Issue: "Variable validation failed"

**Error:**
```
Error: Invalid value for variable
Variable validation failed: Environment must be dev, staging, or prod.
```

**Solution:**
Provide a valid value that meets the validation condition:

```bash
# Check validation rules in variables.tf
terraform apply -var="environment=dev"
```

### Issue: "Output refers to sensitive value"

**Error:**
```
Error: Output refers to sensitive values
Output "password" contains sensitive data
```

**Solution:**
Mark the output as sensitive:

```hcl
output "password" {
  value     = var.db_password
  sensitive = true
}
```

---

## 💡 Common Pitfalls

### 1. Mixing count and for_each

**Problem:**
```hcl
resource "libvirt_domain" "vm" {
  count    = 2
  for_each = var.vms  # ❌ Can't use both!
}
```

**Solution:** Choose one approach:
```hcl
# Use count OR for_each, not both
resource "libvirt_domain" "vm" {
  for_each = var.vms
  # ...
}
```

### 2. Forgetting to convert lists to sets

**Problem:**
```hcl
for_each = var.vm_names  # ❌ If vm_names is a list
```

**Solution:**
```hcl
for_each = toset(var.vm_names)  # ✅ Convert to set
```

### 3. Using count.index in names without padding

**Problem:**
```hcl
name = "vm-${count.index}"  # vm-0, vm-1, ..., vm-10 (poor sorting)
```

**Solution:**
```hcl
name = format("vm-%03d", count.index)  # vm-000, vm-001, ..., vm-010
```

### 4. Not handling empty collections

**Problem:**
```hcl
first_vm = var.vm_list[0]  # ❌ Fails if list is empty
```

**Solution:**
```hcl
first_vm = length(var.vm_list) > 0 ? var.vm_list[0] : null
# Or use try()
first_vm = try(var.vm_list[0], null)
```

### 5. Overusing locals

**Problem:**
```hcl
locals {
  a = 1
  b = 2
  c = 3
  # ... 50 more locals
}
```

**Solution:** Use locals for computed values, not constants. Consider using variables or data sources instead.

---

## 🎓 Key Takeaways

1. **Variables make configurations flexible** - Accept input, provide defaults, validate values
2. **Outputs expose information** - Share data between modules and with users
3. **Locals simplify complex logic** - Compute once, use many times
4. **Loops enable scale** - Create multiple resources efficiently with `count` and `for_each`
5. **Functions transform data** - 100+ built-in functions for any transformation
6. **for_each is more stable than count** - Use for_each when resources have unique identifiers
7. **Validation prevents errors** - Catch invalid values before apply
8. **Terraform console is your friend** - Test expressions interactively

---

## 📚 Additional Resources

- [Terraform Variables Documentation](https://www.terraform.io/language/values/variables)
- [Terraform Functions Reference](https://www.terraform.io/language/functions)
- [For Expressions Guide](https://www.terraform.io/language/expressions/for)
- [Variable Validation](https://www.terraform.io/language/values/variables#custom-validation-rules)

---

## ✅ Challenge Complete!

You've mastered Terraform's data handling capabilities! You can now:

✅ Define flexible input variables with validation
✅ Create informative outputs
✅ Use locals to simplify configurations
✅ Implement loops with count and for_each
✅ Apply functions to transform data
✅ Build dynamic, reusable infrastructure code

**Next Challenge**: Infrastructure Resources - Create networks, security groups, and VMs! 🚀