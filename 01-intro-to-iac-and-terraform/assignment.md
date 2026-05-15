---
slug: intro-to-iac-and-terraform
id: foh86dzsqmms
type: challenge
title: 'Challenge 1: Introduction to IaC & Terraform Basics'
teaser: Learn Infrastructure as Code fundamentals and write your first Terraform configuration
notes:
- type: text
  contents: "# Welcome to TF-100: Terraform Fundamentals! \U0001F680\n\nIn this first
    challenge, you'll learn:\n- What Infrastructure as Code (IaC) is and why it matters\n-
    How Terraform works and its core concepts\n- How to write and execute your first
    Terraform configuration\n\nLet's begin your Terraform journey!\n"
tabs:
- id: 9xjicnddy6d4
  title: Terminal
  type: terminal
  hostname: workstation
- id: j6xgiqozfq2m
  title: Code Editor
  type: code
  hostname: workstation
  path: /root/terraform-workspace
difficulty: basic
timelimit: 5400
enhanced_loading: null
---

# Challenge 1: Introduction to IaC & Terraform Basics

## 🎯 What You'll Learn

By the end of this challenge, you will be able to:

- ✅ Explain what Infrastructure as Code (IaC) is and its benefits
- ✅ Understand Terraform's declarative approach
- ✅ Write basic Terraform configuration files
- ✅ Use the Terraform CLI workflow (init, plan, apply, destroy)
- ✅ Create resources using the `local` provider
- ✅ Understand Terraform state management basics

## ⏱️ Estimated Time

**1.5 hours** - Take your time to understand each concept!

## 💡 Why This Matters

Infrastructure as Code is a fundamental skill for modern DevOps and Cloud Engineering. Instead of manually clicking through cloud consoles or running ad-hoc scripts, you'll learn to define infrastructure in code that can be:

- **Version controlled** - Track changes over time
- **Reviewed** - Team members can review before deployment
- **Tested** - Validate before applying to production
- **Reused** - Deploy the same infrastructure multiple times
- **Automated** - Integrate with CI/CD pipelines

**Real-World Example:** At companies like Netflix, Airbnb, and Uber, thousands of infrastructure resources are managed through Terraform, enabling teams to deploy safely and consistently across multiple environments.

---

## 📚 Part 1: Understanding Infrastructure as Code

### What is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of managing and provisioning infrastructure through machine-readable definition files, rather than manual processes or interactive configuration tools.

### The Traditional Way (Manual) ❌

Imagine you need to create a development environment:

1. Log into cloud console
2. Click "Create VM"
3. Fill out form (name, size, region, etc.)
4. Click "Create Network"
5. Configure security rules manually
6. Repeat for each environment (dev, staging, prod)
7. Document what you did (maybe)
8. Hope you remember the exact steps next time

**Problems:**
- ⚠️ Time-consuming and error-prone
- ⚠️ Hard to replicate exactly
- ⚠️ No version history
- ⚠️ Difficult to review changes
- ⚠️ Manual documentation often outdated

### The IaC Way (Automated) ✅

With Infrastructure as Code:

```hcl
# infrastructure.tf
resource "aws_instance" "web_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name        = "web-server"
    Environment = "development"
  }
}
```

**Benefits:**
- ✅ Consistent and repeatable
- ✅ Version controlled (Git)
- ✅ Code review process
- ✅ Automated testing
- ✅ Self-documenting
- ✅ Fast deployment

### Declarative vs Imperative

**Imperative** (How to do it):
```bash
# Step-by-step commands
create_vm --name web1 --size small
create_network --name vpc1
attach_vm_to_network --vm web1 --network vpc1
```

**Declarative** (What you want):
```hcl
# Desired end state
resource "vm" "web1" {
  size    = "small"
  network = "vpc1"
}
```

Terraform is **declarative** - you describe the desired state, and Terraform figures out how to achieve it.

### What is HCL?

HCL stands for **HashiCorp Configuration Language**. It's the language Terraform uses - think of it like English is to writing, or Python is to programming.

**Example - This is HCL:**
```hcl
resource "local_file" "hello" {
  content  = "Hello!"
  filename = "hello.txt"
}
```

**In Plain English:** "Create a file called hello.txt with the content 'Hello!'"

**Why HCL?** It's designed to be human-readable. You can understand what this does even without knowing Terraform!

<details>
<summary>🔍 Click here to learn more about HCL syntax</summary>

**HCL Syntax Basics:**

HCL uses **blocks** and **arguments**:

```hcl
block_type "label" "name" {
  argument1 = "value1"
  argument2 = "value2"

  nested_block {
    nested_argument = "value"
  }
}
```

**Key Features:**
- **Human-readable**: Looks like configuration, not code
- **Declarative**: You say what you want, not how to do it
- **Structured**: Uses blocks and arguments consistently
- **Type-safe**: Validates data types automatically

**Compared to Other Languages:**
- **JSON**: More readable than JSON (no quotes everywhere)
- **YAML**: More structured than YAML (clearer hierarchy)
- **Python**: Simpler than Python (no programming logic needed)

**You don't need to memorize this!** You'll learn by doing in the exercises.

</details>

---

## 🚀 Part 2: What is Terraform?

### Overview

**Terraform** is an open-source Infrastructure as Code tool created by HashiCorp. It allows you to define infrastructure in human-readable configuration files that you can version, reuse, and share.

### Key Features

#### 1. Multi-Cloud Support
Terraform works with 3000+ providers:
- Cloud: AWS, Azure, GCP, Oracle Cloud
- SaaS: GitHub, Datadog, PagerDuty
- Infrastructure: Kubernetes, VMware, Libvirt

#### 2. Declarative Syntax
You describe **what** you want, not **how** to create it:
```hcl
resource "local_file" "example" {
  content  = "Hello, Terraform!"
  filename = "hello.txt"
}
```

#### 3. State Management
Terraform tracks your infrastructure in a **state file**, knowing what exists and what needs to change.

#### 4. Plan Before Apply
Preview changes before making them:
```bash
terraform plan  # Shows what will change
terraform apply # Actually makes the changes
```

#### 5. Resource Graph
Terraform automatically determines the correct order to create resources based on dependencies.

### Terraform Workflow

```
┌─────────────┐
│   Write     │  Write .tf configuration files
│   Code      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Download required providers
│    init     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Preview changes
│    plan     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Create/update infrastructure
│    apply    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  terraform  │  Remove infrastructure (when needed)
│   destroy   │
└─────────────┘
```

---

## 🔌 Part 3: Terraform Providers

### What is a Provider?

A **provider** is a plugin that enables Terraform to interact with an API. Each provider adds a set of resource types and data sources that Terraform can manage.

Examples:
- `aws` provider → Manage AWS resources
- `azurerm` provider → Manage Azure resources
- `local` provider → Manage local files (what we'll use today)
- `libvirt` provider → Manage VMs (we'll use this later)

### Provider Configuration

Every Terraform configuration needs two blocks:

#### 1. Terraform Block - The Setup

```hcl
terraform {
  required_version = ">= 1.14"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}
```

**What each part means:**
- `required_version`: Minimum Terraform version needed (like "you need iOS 15 or newer")
- `required_providers`: Which providers (plugins) to download
- `source`: Where to get the provider (like an app store address: `hashicorp/local`)
- `version`: Which version to use (`~> 2.7` means "2.7 or newer, but not 3.0")

<details>
<summary>🔍 Click here to understand version constraints</summary>

**Version Constraint Syntax:**

- `= 2.7.0` - Exactly version 2.7.0
- `>= 2.7.0` - Version 2.7.0 or newer
- `~> 2.7` - Version 2.7.x (but not 3.0) - **Recommended!**
- `>= 2.7, < 3.0` - Between 2.7 and 3.0

**Why `~> 2.7` is recommended:**
- ✅ Gets bug fixes automatically (2.7.1, 2.7.2, etc.)
- ✅ Prevents breaking changes (won't jump to 3.0)
- ✅ Balances stability and updates

**In production:** Pin to exact versions for maximum stability.

</details>

#### 2. Provider Block - The Configuration

```hcl
provider "local" {
  # Configuration options (if any)
}
```

**What this does:** Configures how the provider behaves. The `local` provider doesn't need configuration, but others (like AWS) need credentials, regions, etc.

<details>
<summary>🔍 Click here to see provider configuration examples</summary>

**AWS Provider Example:**
```hcl
provider "aws" {
  region = "us-east-1"
  # Credentials from environment variables or AWS CLI
}
```

**Azure Provider Example:**
```hcl
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id"
}
```

**Why local provider is simple:** It just creates files on your computer - no cloud credentials needed!

</details>

⚠️ **Common Pitfall:** Forgetting the `terraform` block leads to version inconsistencies across team members.

---

## 📝 Part 4: Your First Terraform Configuration

### Terraform File Structure

```
project/
├── main.tf              # Main configuration
├── variables.tf         # Input variables (optional)
├── outputs.tf           # Output values (optional)
├── .terraform/          # Provider plugins (created by init)
├── .terraform.lock.hcl  # Provider version lock (created by init)
└── terraform.tfstate    # State file (created by apply)
```

For this lab, we'll keep it simple with just `main.tf`.

### What is a Resource?

A **resource** is a piece of infrastructure you want to create. Think of it as a "thing" you're building.

**Examples of resources:**
- A file on your computer (`local_file`)
- A virtual machine (`libvirt_domain`)
- A network (`libvirt_network`)
- An AWS server (`aws_instance`)
- A database (`aws_db_instance`)

**In simple terms:** If you can point to something and say "I want one of those," it's probably a resource!

**The pattern is always the same:**
1. Tell Terraform WHAT you want (resource type)
2. Give it a NAME (so you can refer to it later)
3. Configure HOW you want it (arguments)

<details>
<summary>🔍 Click here to understand resource types</summary>

**Resource Type Format:** `provider_resourcetype`

Examples:
- `local_file` = local provider + file resource
- `aws_instance` = AWS provider + instance (VM) resource
- `libvirt_domain` = libvirt provider + domain (VM) resource

**Why this format?**
- The provider name tells you which plugin handles it
- The resource type tells you what kind of thing it is
- Together: `aws_instance` = "an AWS virtual machine"

**Finding resource types:**
- Check the [Terraform Registry](https://registry.terraform.io/)
- Look at provider documentation
- Each provider lists all its resource types

</details>


### Resource Block Anatomy

```hcl
resource "PROVIDER_TYPE" "NAME" {
  argument1 = "value1"
  argument2 = "value2"
}
```

- `resource` - Keyword declaring a resource
- `PROVIDER_TYPE` - Type of resource (e.g., `local_file`, `aws_instance`)
- `NAME` - Logical name you choose (used to reference this resource)
- Arguments - Configuration specific to the resource type

**Example:**
```hcl
resource "local_file" "hello" {
  content  = "Hello, Terraform!"
  filename = "${path.module}/hello.txt"
}
```

### Special Expressions

#### `${path.module}`
- Returns the filesystem path of the current module
- Ensures files are created in the correct directory
- Example: `"${path.module}/hello.txt"` → `./hello.txt`

#### Heredoc Syntax (`<<-EOT`)

**What is this?** A way to write multi-line text without using quotes on every line.

**Simple example:**
```hcl
content = <<-EOT
  Line 1
  Line 2
  Line 3
EOT
```

**What each part means:**
- `<<-EOT` = "Start of multi-line text" (EOT = End Of Text)
- Lines in between = Your actual content
- `EOT` = "End of multi-line text"

**Why use it?** Much easier than this:
```hcl
# Without heredoc (messy!)
content = "Line 1\nLine 2\nLine 3"
```

<details>
<summary>🔍 Click here to learn more about heredoc</summary>

**The name "EOT" is just a convention:**
- You can use any word: `<<-EOF`, `<<-END`, `<<-CONTENT`
- Just make sure the ending matches the beginning
- EOT (End Of Text) is most common

**The `<<-` vs `<<` difference:**
- `<<-EOT` = Ignores leading spaces (recommended)
- `<<EOT` = Keeps all spaces exactly as written

**Real-world example:**
```hcl
resource "local_file" "readme" {
  content = <<-EOT
    # My Project

    This is a README file.
    It has multiple lines.

    ## Installation
    Run: terraform apply
  EOT
  filename = "README.md"
}
```

**You'll see this a lot in:**
- Cloud-init configurations
- Script files
- Configuration files
- Any multi-line text

</details>

---

## 🧪 Part 5: Hands-On Lab

Now let's put theory into practice! You'll create your first Terraform configuration.

### Step 1: Navigate to Workspace

Your environment is pre-configured with Terraform and all necessary tools.

```bash
cd /root/terraform-workspace
```

### Step 2: Create Your First Configuration

Create a file named `main.tf`:

```bash
cat > main.tf << 'EOF'
# My First Terraform Configuration
# TF-101: Introduction to IaC & Terraform Basics

terraform {
  required_version = ">= 1.14"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

provider "local" {}

# Resource 1: Simple greeting file
resource "local_file" "hello" {
  content  = "Hello, Terraform! This is my first infrastructure as code."
  filename = "${path.module}/hello.txt"
}

# Resource 2: Training information with heredoc
resource "local_file" "info" {
  content  = <<-EOT
    Terraform Training
    ==================
    Course: TF-101
    Topic: Introduction to IaC & Terraform Basics

    This file was created by Terraform!
    Timestamp: ${timestamp()}
  EOT
  filename = "${path.module}/info.txt"
}

# Resource 3: Configuration file
resource "local_file" "config" {
  content  = <<-EOT
    # Application Configuration
    app_name = "terraform-training"
    version  = "1.0.0"
    environment = "development"

    # Features
    enable_logging = true
    enable_metrics = true
  EOT
  filename = "${path.module}/app-config.txt"
}

# Outputs: Display information about created resources
output "hello_file_id" {
  description = "ID of the hello.txt file"
  value       = local_file.hello.id
}

output "all_files" {
  description = "List of all created files"
  value = [
    local_file.hello.filename,
    local_file.info.filename,
    local_file.config.filename
  ]
}
EOF
```

**💡 What's in this configuration?**
- **Terraform block**: Specifies required Terraform version and providers
- **Provider block**: Configures the local provider
- **3 Resources**: Creates three different text files
- **2 Outputs**: Displays information after apply

### Step 3: Initialize Terraform

This downloads the required provider plugins:

```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.7"...
- Installing hashicorp/local v2.7.x...
- Installed hashicorp/local v2.7.x

Terraform has been successfully initialized!
```

**What happened?**
- ✅ Downloaded the `local` provider plugin
- ✅ Created `.terraform/` directory
- ✅ Created `.terraform.lock.hcl` file (locks provider versions)

💡 **Tip:** Run `ls -la` to see the new files created.

### Step 4: Preview Changes with Plan

Before making any changes, let's see what Terraform will do:

```bash
terraform plan
```

**Expected Output:**
```
Terraform will perform the following actions:

  # local_file.config will be created
  + resource "local_file" "config" {
      + content  = <<-EOT
            # Application Configuration
            app_name = "terraform-training"
            ...
        EOT
      + filename = "./app-config.txt"
      + id       = (known after apply)
    }

  # local_file.hello will be created
  + resource "local_file" "hello" {
      + content  = "Hello, Terraform! This is my first infrastructure as code."
      + filename = "./hello.txt"
      + id       = (known after apply)
    }

  # local_file.info will be created
  + resource "local_file" "info" {
      + content  = <<-EOT
            Terraform Training
            ...
        EOT
      + filename = "./info.txt"
      + id       = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

**Understanding the Output:**
- `+` symbol = Resource will be **created**
- `~` symbol = Resource will be **modified** (you'll see this later)
- `-` symbol = Resource will be **destroyed**
- `(known after apply)` = Value determined during creation

### Step 5: Apply Changes

Now let's actually create the resources:

```bash
terraform apply
```

You'll see the plan again, then a prompt:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Type `yes` and press Enter.

**Expected Output:**
```
local_file.hello: Creating...
local_file.info: Creating...
local_file.config: Creating...
local_file.hello: Creation complete after 0s [id=...]
local_file.info: Creation complete after 0s [id=...]
local_file.config: Creation complete after 0s [id=...]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

all_files = [
  "./hello.txt",
  "./info.txt",
  "./app-config.txt",
]
hello_file_id = "..."
```

🎉 **Congratulations!** You just created your first infrastructure with Terraform!

### Step 6: Verify Resources Created

Let's check that the files were actually created:

```bash
ls -la *.txt
```

You should see:
- `hello.txt`
- `info.txt`
- `app-config.txt`

View the contents:

```bash
cat hello.txt
cat info.txt
cat app-config.txt
```

### Step 7: Understand Terraform State

Terraform created a `terraform.tfstate` file. This tracks what infrastructure exists:

```bash
cat terraform.tfstate
```

You'll see JSON containing information about your resources.

⚠️ **Important:** The state file is critical! It's how Terraform knows what it manages. In real projects, this is stored remotely (we'll learn about that later).

You can also view state in a readable format:

```bash
terraform show
```

**🤔 What is Terraform State?**

Think of state as Terraform's **memory** or **notebook**. It's how Terraform remembers:
- What infrastructure it created
- What the current configuration looks like
- What needs to change when you update your code

**Simple Analogy:**
Imagine you're building with LEGO blocks:
- Your `.tf` files = The instruction manual (what you WANT to build)
- The state file = A photo of what you've ALREADY built
- Terraform compares the photo to the manual to know what to add, change, or remove

**Why State Matters:**

1. **Tracks Resources**: Without state, Terraform wouldn't know it created those files
2. **Enables Updates**: State lets Terraform know what exists so it can update it
3. **Prevents Duplicates**: State prevents creating the same resource twice
4. **Shows Dependencies**: State tracks relationships between resources

**What's in the State File?**

The `terraform.tfstate` file contains:
- Resource IDs (unique identifiers)
- Current attribute values
- Resource dependencies
- Metadata about your infrastructure

<details>
<summary>🔍 Click here to learn more about state management</summary>

**State File Format:**
- JSON format (human-readable but don't edit manually!)
- Contains sensitive data (passwords, keys, etc.)
- Should be stored securely in production

**Important State Concepts:**

1. **Local vs Remote State:**
   - **Local**: State file on your computer (what we're using now)
   - **Remote**: State stored in cloud (S3, Azure, HCP Terraform) - better for teams

2. **State Locking:**
   - Prevents multiple people from changing infrastructure simultaneously
   - Automatic with remote backends
   - Prevents conflicts and corruption

3. **State Commands:**
   ```bash
   terraform state list              # List all resources
   terraform state show <resource>   # Show resource details
   terraform state pull              # Download remote state
   terraform state push              # Upload state (careful!)
   ```

4. **Best Practices:**
   - ✅ Never edit state files manually
   - ✅ Use remote state for team projects
   - ✅ Enable state locking
   - ✅ Keep state files secure (they contain sensitive data)
   - ✅ Back up state files regularly
   - ❌ Don't commit state files to git (use `.gitignore`)

**Real-World Example:**

In production, you'd use remote state:
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
```

This stores state in AWS S3 with encryption, so your team can collaborate safely.

</details>

### Step 8: Make a Change

Let's modify our configuration. Edit `main.tf` and change the hello file content:

```bash
# Update the hello resource
sed -i 's/Hello, Terraform!/Hello, Terraform World!/' main.tf
```

Or manually edit the file in the Code Editor tab.

Now run plan again:

```bash
terraform plan
```

Notice the output shows:
```
  # local_file.hello must be replaced
-/+ resource "local_file" "hello" {
      ~ content  = "Hello, Terraform! ..." -> "Hello, Terraform World! ..."
        filename = "./hello.txt"
      ~ id       = "..." -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

The `~` shows what changed, and `-/+` means the resource will be replaced (destroyed and recreated).

Apply the change:

```bash
terraform apply -auto-approve
```

💡 **Tip:** `-auto-approve` skips the confirmation prompt (use carefully!).

### Step 9: Destroy Resources

When you're done, clean up:

```bash
terraform destroy
```

Confirm with `yes`.

**Expected Output:**
```
local_file.hello: Destroying... [id=...]
local_file.info: Destroying... [id=...]
local_file.config: Destroying... [id=...]
local_file.hello: Destruction complete after 0s
local_file.info: Destruction complete after 0s
local_file.config: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```

Verify files are gone:

```bash
ls -la *.txt
# Should show "No such file or directory"
```

---

## ✅ Knowledge Check

Test your understanding with these questions:

### Question 1: What is Infrastructure as Code?
<details>
<summary>Click to reveal answer</summary>

**Answer:** Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through machine-readable definition files, rather than manual processes. It allows infrastructure to be version controlled, tested, and automated.

**Key Benefits:**
- Consistency and repeatability
- Version control and history
- Code review process
- Automated testing
- Self-documenting
</details>

### Question 2: What does "declarative" mean in Terraform?
<details>
<summary>Click to reveal answer</summary>

**Answer:** Declarative means you describe the **desired end state** of your infrastructure, not the steps to achieve it. Terraform figures out what actions are needed to reach that state.

**Example:**
```hcl
# You declare what you want
resource "local_file" "example" {
  content  = "Hello"
  filename = "hello.txt"
}
# Terraform figures out how to create it
```
</details>

### Question 3: What is a Terraform provider?
<details>
<summary>Click to reveal answer</summary>

**Answer:** A provider is a plugin that enables Terraform to interact with an API. It adds resource types and data sources that Terraform can manage.

**Examples:**
- `aws` - Manages AWS resources
- `local` - Manages local files
- `kubernetes` - Manages Kubernetes resources
</details>

### Question 4: What does `terraform init` do?
<details>
<summary>Click to reveal answer</summary>

**Answer:** `terraform init` initializes a Terraform working directory by:
1. Downloading required provider plugins
2. Creating the `.terraform/` directory
3. Creating the `.terraform.lock.hcl` lock file
4. Initializing the backend (state storage)

**You must run this before any other Terraform commands!**
</details>

### Question 5: What's the difference between `plan` and `apply`?
<details>
<summary>Click to reveal answer</summary>

**Answer:**
- **`terraform plan`**: Shows what changes Terraform **would** make (preview only, no changes)
- **`terraform apply`**: Actually **makes** the changes to your infrastructure

**Best Practice:** Always run `plan` before `apply` to review changes!
</details>

---

## 🎓 Summary

### What You Learned

In this challenge, you:

✅ Understood what Infrastructure as Code is and why it matters
✅ Learned Terraform's declarative approach
✅ Wrote your first Terraform configuration
✅ Used the complete Terraform workflow (init → plan → apply → destroy)
✅ Created resources with the `local` provider
✅ Understood Terraform state basics

### Key Concepts

- **IaC**: Managing infrastructure through code
- **Declarative**: Describe what you want, not how to get it
- **Provider**: Plugin that enables Terraform to manage resources
- **Resource**: A piece of infrastructure (file, VM, network, etc.)
- **State**: Terraform's record of managed infrastructure
- **Workflow**: init → plan → apply → destroy

### Commands You Learned

```bash
terraform init      # Initialize working directory
terraform plan      # Preview changes
terraform apply     # Create/update infrastructure
terraform show      # Display current state
terraform destroy   # Remove all managed infrastructure
```

---

## 🚀 What's Next?

In **Challenge 2**, you'll learn about:
- Variables and input values
- Loops with `count` and `for_each`
- Built-in functions
- For expressions (list/map comprehensions)

---

## 💡 Common Pitfalls to Avoid

⚠️ **Forgetting `terraform init`**
- Always run `init` first in a new directory
- Re-run if you add new providers

⚠️ **Not reviewing `plan` output**
- Always check what will change before applying
- Unexpected changes? Investigate before proceeding

⚠️ **Deleting state files**
- Never manually delete `terraform.tfstate`
- Terraform loses track of your infrastructure

⚠️ **Hardcoding values**
- Use variables instead (you'll learn this next!)
- Makes configurations reusable

---

## 🆘 Troubleshooting

### "terraform: command not found"
**Solution:** Terraform is pre-installed. Try:
```bash
which terraform
terraform version
```

### "Error: Failed to query available provider packages"
**Solution:** Check internet connectivity or provider source:
```bash
terraform init -upgrade
```

### "Error: Inconsistent dependency lock file"
**Solution:** Update the lock file:
```bash
terraform init -upgrade
```

### Files not created after apply
**Solution:** Check you're in the right directory:
```bash
pwd
ls -la
```

---

## 📚 Additional Resources

<details>
<summary>📖 Official Documentation & Learning Resources</summary>

### Core Documentation
- [Terraform Documentation](https://www.terraform.io/docs) - Complete reference for all Terraform features
- [HCL Syntax](https://www.terraform.io/language/syntax/configuration) - HashiCorp Configuration Language guide
- [Terraform CLI Commands](https://www.terraform.io/cli/commands) - All available commands explained
- [Configuration Language](https://www.terraform.io/language) - Deep dive into Terraform's language

### Getting Started Guides
- [Get Started - Terraform](https://learn.hashicorp.com/collections/terraform/aws-get-started) - Official tutorial series
- [Terraform Basics](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code) - Infrastructure as Code fundamentals
- [Write Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/aws-build) - Step-by-step configuration guide

### Providers
- [Terraform Registry](https://registry.terraform.io/) - Browse all available providers and modules
- [Provider Documentation](https://registry.terraform.io/browse/providers) - Documentation for specific providers
- [Local Provider](https://registry.terraform.io/providers/hashicorp/local/latest/docs) - The provider we used in this challenge

### State Management
- [State Overview](https://www.terraform.io/language/state) - Understanding Terraform state
- [Remote State](https://www.terraform.io/language/state/remote) - Storing state remotely for teams
- [State Commands](https://www.terraform.io/cli/commands/state) - Managing state with CLI

### Best Practices
- [Terraform Style Guide](https://www.terraform.io/language/syntax/style) - Code formatting conventions
- [Best Practices](https://www.terraform.io/cloud-docs/recommended-practices) - HashiCorp's recommendations
- [Security Best Practices](https://www.terraform.io/language/values/variables#suppressing-values-in-cli-output) - Keeping your infrastructure secure

### Community & Support
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core) - Ask questions and get help
- [Terraform GitHub](https://github.com/hashicorp/terraform) - Source code and issue tracking
- [HashiCorp Blog](https://www.hashicorp.com/blog/products/terraform) - Latest news and tutorials

### Video Tutorials
- [Terraform in 15 Minutes](https://www.youtube.com/watch?v=l5k1ai_GBDE) - Quick introduction
- [HashiCorp YouTube Channel](https://www.youtube.com/c/HashiCorp) - Official video content

</details>

---

**🎉 Congratulations on completing Challenge 1!**

Click **Check** to validate your work and proceed to the next challenge.