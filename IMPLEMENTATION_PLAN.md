# TF-100 Language Improvements - Implementation Plan

**Created**: 2026-05-15  
**Purpose**: Step-by-step implementation guide for improving TF-100 language for beginners  
**Approach**: One challenge at a time, test after each change

---

## Overview

This plan implements the suggestions from `BEGINNER_LANGUAGE_REVIEW.md` in a safe, incremental manner. Each challenge is improved independently and tested before moving to the next.

**Total Estimated Time**: 2-3 days  
**Risk Level**: Low (changes are additive, not destructive)

---

## Implementation Strategy: Progressive Disclosure

**Key Principle**: Use collapsible `<details>` sections to provide optional depth without overwhelming beginners.

### Why Collapsible Sections?

✅ **Beginners get**: Simple, clear explanations upfront
✅ **Curious learners get**: Deep dives when they want them
✅ **Everyone wins**: No information overload, but depth available

### Pattern to Use Throughout

```markdown
**Simple explanation here for everyone**

<details>
<summary>🔍 Click here to learn more about [topic]</summary>

**Deeper explanation with:**
- Technical details
- Edge cases
- Advanced concepts
- Real-world examples

</details>
```

### When to Use Collapsible Sections

Use `<details>` for:
- ✅ Technical deep dives (e.g., "How providers work internally")
- ✅ Advanced concepts (e.g., "State locking mechanisms")
- ✅ Optional context (e.g., "History of IaC")
- ✅ Troubleshooting details (e.g., "Why this error happens")
- ✅ Alternative approaches (e.g., "Other ways to do this")

Don't use for:
- ❌ Core concepts everyone needs
- ❌ Step-by-step instructions
- ❌ Critical warnings or errors
- ❌ Required reading

---

## Pre-Implementation Checklist

Before starting any changes:

- [ ] Create a backup branch: `git checkout -b tf-100-language-improvements`
- [ ] Ensure you have access to test the lab on Instruqt
- [ ] Review the BEGINNER_LANGUAGE_REVIEW.md document
- [ ] Have 2-3 test users ready for validation (optional but recommended)
- [ ] Understand the collapsible section pattern above

---

## Challenge 1: Introduction to IaC & Terraform Basics

**File**: `01-intro-to-iac-and-terraform/assignment.md`  
**Estimated Time**: 4-5 hours  
**Risk**: Low (mostly additions)

### Task 1.1: Add HCL Explanation (Lines 60-130)

**Location**: After "What is Infrastructure as Code?" section
**Action**: Add new subsection with collapsible deep dive

```markdown
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
```

**Testing**:
- [ ] Read through the section - does it flow naturally?
- [ ] Ask: "Would a beginner understand this?"
- [ ] Verify collapsible section works in markdown preview
- [ ] Verify no broken links or formatting issues

---

### Task 1.2: Expand Provider Configuration Explanation (Lines 220-240)

**Location**: In "Terraform Providers" section  
**Action**: Replace existing provider configuration with expanded version

**Current**:
```markdown
### Provider Configuration

Every Terraform configuration needs:
1. Terraform block
2. Provider block
```

**Replace with**:
```markdown
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
- `required_version`: Minimum Terraform version needed
- `required_providers`: Which providers (plugins) to download
- `source`: Where to get the provider (like an app store address)
- `version`: Which version to use (`~> 2.7` means "2.7 or newer, but not 3.0")

<details>
<summary>🔍 Click here to understand version constraints</summary>

**Version Constraint Syntax:**

- `= 2.7.0` - Exactly version 2.7.0
- `>= 2.7.0` - Version 2.7.0 or newer
- `~> 2.7` - Version 2.7.x (but not 3.0)
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
```

**Testing**:
- [ ] Verify collapsible sections work
- [ ] Check that examples are clear
- [ ] Ensure version constraint explanation is accurate

**`source = "hashicorp/local"`**
- `hashicorp` = The company that made it (like a brand name)
- `local` = The specific provider (like a product name)
- Think of it like: `company/product`

**`version = "~> 2.7"`**
- The `~>` symbol means "approximately version 2.7"
- ✅ Will use: 2.7.0, 2.7.1, 2.7.2 (bug fixes)
- ❌ Won't use: 2.8.0, 3.0.0 (breaking changes)
- **Why?** Keeps your code working with bug fixes, prevents breaking changes

#### 2. Provider Block - The Connection

```hcl
provider "local" {
  # Configuration options (if any)
}
```

This tells Terraform: "I'm ready to use the local provider now!"
```

**Testing**:
- [ ] Verify code blocks render correctly
- [ ] Check that examples are accurate
- [ ] Ensure formatting is consistent

---

### Task 1.3: Break Down First Configuration Example (Lines 300-400)

**Location**: "Your First Terraform Configuration" section  
**Action**: Split the large example into progressive steps

**Current**: One large code block with 3 resources  
**Replace with**: Three separate subsections

**Add before the current example**:
```markdown
### Step 2A: Your First Simple File

Let's start with the simplest possible Terraform resource:

```hcl
resource "local_file" "hello" {
  content  = "Hello, Terraform!"
  filename = "hello.txt"
}
```

**That's it!** This creates a file called `hello.txt` with the text "Hello, Terraform!"

### Step 2B: Understanding the Syntax

Let's break down what each part means:

```hcl
resource "local_file" "hello" {
  ↑        ↑           ↑
  |        |           |
  |        |           └─ Name YOU choose (like a variable name)
  |        └───────────── Type of resource (file on local computer)
  └────────────────────── Keyword that means "create something"
  
  content  = "Hello, Terraform!"
  ↑          ↑
  |          └─ The value (what goes IN the file)
  └──────────── The setting (WHAT to configure)
  
  filename = "hello.txt"
  ↑          ↑
  |          └─ The value (WHERE to create the file)
  └──────────── The setting (WHAT to configure)
}
```

### Step 2C: The Complete Configuration

Now that you understand the basics, here's the complete configuration with multiple resources:

[Keep existing full example here]
```

**Testing**:
- [ ] Verify ASCII diagrams render correctly
- [ ] Test that code examples are valid
- [ ] Check progressive flow makes sense

---

### Task 1.4: Add "Why terraform init?" Explanation (Lines 410-420)

**Location**: Before "Step 3: Initialize Terraform"  
**Action**: Add new subsection

```markdown
### Why Do We Need `terraform init`?

**Think of Terraform like a toolbox:**
- **Terraform itself** = The toolbox (installed on your computer)
- **Providers** = The actual tools (screwdriver, hammer, etc.)

When you run `terraform init`, you're saying:
> "Look at my configuration and download the specific tools I need"

**Without `init`:**
- ❌ Terraform doesn't have the `local` provider
- ❌ It can't create files
- ❌ Commands will fail

**After `init`:**
- ✅ Provider downloaded
- ✅ Ready to create resources
- ✅ Can run plan/apply

**Real-World Analogy**: 
It's like installing an app on your phone before you can use it. Terraform is installed, but it needs to "install" the providers you want to use.

### Step 3: Initialize Terraform

Now let's actually run it:

[Keep existing content]
```

**Testing**:
- [ ] Verify analogy makes sense
- [ ] Check formatting and flow
- [ ] Ensure it connects to next section

---

### Task 1.5: Testing Challenge 1 Changes

**Before moving to Challenge 2:**

1. **Visual Review**:
   - [ ] Read through entire assignment.md
   - [ ] Check all formatting renders correctly
   - [ ] Verify code blocks are valid
   - [ ] Ensure flow is logical

2. **Technical Validation**:
   - [ ] Run `terraform fmt` on any code examples
   - [ ] Verify all Terraform code is syntactically correct
   - [ ] Check that line numbers in review doc still match

3. **Beginner Test** (if possible):
   - [ ] Have someone unfamiliar with Terraform read it
   - [ ] Ask: "Do you understand what Terraform does?"
   - [ ] Note any confusion points

4. **Git Commit**:
   ```bash
   git add 01-intro-to-iac-and-terraform/assignment.md
   git commit -m "TF-100 Challenge 1: Improve language for beginners
   
   - Add HCL explanation with examples
   - Expand provider configuration details
   - Break down first configuration into progressive steps
   - Add 'why terraform init' explanation
   - Improve terminology and analogies"
   ```

---

## Challenge 2: Variables, Loops & Functions

**File**: `02-variables-loops-functions/assignment.md`  
**Estimated Time**: 4-5 hours  
**Risk**: Low (mostly additions)

### Task 2.1: Simplify Variable Introduction (Lines 71-120)

**Location**: Start of "Core Concepts" section  
**Action**: Add progressive variable examples

**Add before current content**:
```markdown
### Variables: Start Simple

Let's begin with the easiest type of variable - a simple text value:

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

**Using it:**
```hcl
resource "local_file" "config" {
  content  = "Environment: ${var.environment}"
  filename = "config.txt"
}
```

**Now when you create the file, it will say "Environment: dev"**

### Variables: Adding Numbers

Once you're comfortable with text, let's add numbers:

```hcl
variable "vm_memory" {
  type    = number
  default = 1024
}
```

**That's it!** Same idea, but for numbers instead of text.

### Variables: Getting Fancy (Later)

After you master simple variables, we'll learn about:
- Lists (multiple values)
- Maps (key-value pairs)
- Objects (complex structures)

**But don't worry about those yet!**

### 1. Input Variables (Complete Reference)

[Keep existing comprehensive content here]
```

**Testing**:
- [ ] Verify progressive flow
- [ ] Check code examples are valid
- [ ] Ensure it connects to existing content

---

### Task 2.2: Prioritize Essential Functions (Lines 294-429)

**Location**: "Built-in Functions" section  
**Action**: Add "Essential 5" section before comprehensive list

**Add at start of functions section**:
```markdown
### Functions: The Essential 5

As a beginner, you only need to know **5 functions** to start:

#### 1. `format()` - Create text with variables
```hcl
format("%s-vm", var.environment)  # "dev-vm"
```
**Use when:** Building names or messages

#### 2. `length()` - Count items in a list
```hcl
length(["a", "b", "c"])  # 3
```
**Use when:** Need to know how many items you have

#### 3. `lookup()` - Get value from a map
```hcl
lookup(var.settings, "memory", 1024)  # Get memory, or 1024 if not found
```
**Use when:** Getting values from maps with a default

#### 4. `file()` - Read a file
```hcl
file("config.txt")  # Contents of config.txt
```
**Use when:** Loading configuration from files

#### 5. `timestamp()` - Current time
```hcl
timestamp()  # "2024-01-15T10:30:00Z"
```
**Use when:** Adding timestamps to resources

**That's it!** Master these 5 first. The other 45+ functions are for advanced use cases.

### Functions: The Complete Reference (Optional)

<details>
<summary>Click here for the full function list (you can skip this for now)</summary>

[Move existing comprehensive list here]

</details>
```

**Testing**:
- [ ] Verify collapsible section works
- [ ] Check function examples are correct
- [ ] Ensure formatting is clean

---

### Task 2.3: Clarify Count vs For_each (Lines 183-293)

**Location**: "Loops and Iteration" section  
**Action**: Add decision tree and clearer examples

**Add before existing content**:
```markdown
### Loops: Which One Should I Use?

**Simple Decision Tree:**

```
Do you need to create multiple identical things?
│
├─ YES, and I just need 3 of them
│  └─ Use COUNT
│     Example: 3 identical VMs
│
└─ YES, but each one is slightly different
   └─ Use FOR_EACH
      Example: VMs with different names/sizes
```

#### Count (Simple Numeric Loops)

**Use when:** Creating X copies of the same thing

**Example:**
```hcl
# Create 3 identical files
resource "local_file" "example" {
  count    = 3
  content  = "File number ${count.index}"
  filename = "file-${count.index}.txt"
}
# Creates: file-0.txt, file-1.txt, file-2.txt
```

**Key Point:** `count.index` starts at 0

#### For_each (Map/Set Iteration)

**Use when:** Creating one of each thing in your list, and they're different

**Example:**
```hcl
# Create files with different content
resource "local_file" "example" {
  for_each = {
    dev  = "Development"
    prod = "Production"
  }
  content  = each.value
  filename = "${each.key}.txt"
}
# Creates: dev.txt (contains "Development"), prod.txt (contains "Production")
```

**Key Point:** `each.key` = the name, `each.value` = the value

#### Rule of Thumb

- **Count** = "Make X copies of the same thing"
- **For_each** = "Make one of each thing in my list"

### Detailed Loop Documentation

[Keep existing comprehensive content]
```

**Testing**:
- [ ] Verify decision tree is clear
- [ ] Check examples are accurate
- [ ] Ensure flow is logical

---

### Task 2.4: Testing Challenge 2 Changes

**Before moving to Challenge 3:**

1. **Visual Review**:
   - [ ] Read through entire assignment.md
   - [ ] Check collapsible sections work
   - [ ] Verify code blocks render correctly
   - [ ] Ensure decision trees are clear

2. **Technical Validation**:
   - [ ] Test all code examples
   - [ ] Verify function examples are correct
   - [ ] Check that loops examples work

3. **Git Commit**:
   ```bash
   git add 02-variables-loops-functions/assignment.md
   git commit -m "TF-100 Challenge 2: Simplify variables and functions
   
   - Add progressive variable introduction
   - Prioritize essential 5 functions
   - Add count vs for_each decision tree
   - Improve loop examples and explanations
   - Add collapsible sections for advanced content"
   ```

---

## Challenge 3: Infrastructure Resources

**File**: `03-infrastructure-resources/assignment.md`  
**Estimated Time**: 3-4 hours  
**Risk**: Low (mostly additions)

### Task 3.1: Explain Libvirt Context (Lines 79-117)

**Location**: Start of "Core Concepts" section  
**Action**: Add "What is Libvirt?" section

**Add before "Virtual Networks"**:
```markdown
### What is Libvirt? (And Why Are We Using It?)

**Libvirt** is a tool that creates virtual machines on your local computer.

**Why not AWS/Azure?**
- ✅ Free (no cloud costs)
- ✅ Fast (no internet delays)
- ✅ Safe (can't accidentally create expensive resources)
- ✅ Same concepts (skills transfer to real cloud)

**Think of it like:**
- **Libvirt** = Practice driving in a parking lot
- **AWS/Azure** = Driving on real highways

**The skills are the same!** Once you master Terraform with libvirt, you can use the exact same concepts with AWS, Azure, or GCP. Only the provider name changes:

```hcl
# Libvirt (practice)
resource "libvirt_domain" "vm" {
  name = "my-vm"
}

# AWS (production)
resource "aws_instance" "vm" {
  ami = "ami-12345"
}
```

**Same Terraform, different provider!**

### 1. Virtual Networks

[Keep existing content]
```

**Testing**:
- [ ] Verify analogy makes sense
- [ ] Check code examples are accurate
- [ ] Ensure it flows into next section

---

### Task 3.2: Simplify Cloud-Init Explanation (Lines 159-213)

**Location**: "Cloud-Init Configuration" section  
**Action**: Add beginner-friendly explanation

**Replace existing introduction with**:
```markdown
### 3. Cloud-Init Configuration

#### What is Cloud-Init? (Simple Explanation)

**The Problem:**
When you create a VM, it's like a blank computer. You need to:
- Set the hostname
- Install software
- Configure services
- Create users

**The Old Way (Manual):**
1. Create VM
2. Wait for it to boot
3. SSH into it
4. Run commands manually
5. Hope you didn't forget anything

**The Cloud-Init Way (Automated):**
1. Create VM with cloud-init configuration
2. VM automatically configures itself on first boot
3. Done!

**Real-World Analogy:**
- **Manual** = Buying furniture and assembling it yourself
- **Cloud-Init** = Buying pre-assembled furniture

#### Why YAML?

Cloud-init uses YAML because it's easy to read and write. Don't worry if you haven't seen YAML before - it's just a way to write configuration that looks like this:

```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
packages:
  - nginx
  - curl
```

**In plain English:** "Create a user named ubuntu with sudo access, and install nginx and curl"

**You don't need to be a YAML expert!** Just follow the examples.

#### Cloud-Init Example

[Keep existing detailed examples]
```

**Testing**:
- [ ] Verify YAML examples are valid
- [ ] Check analogies make sense
- [ ] Ensure flow is logical

---

### Task 3.3: Explain Resource Dependencies (Lines 261-290)

**Location**: "Resource Dependencies" section  
**Action**: Add beginner-friendly explanation

**Replace existing content with**:
```markdown
### 5. Resource Dependencies

#### Why Do Dependencies Matter?

**The Problem:**
Imagine you're building a house. You need to:
1. Pour the foundation
2. Build the walls
3. Add the roof

**What happens if you try to add the roof first?**
❌ It falls down! You need the walls first.
❌ The walls need the foundation first.

**Same with infrastructure:**
- VM needs a disk (can't boot without storage)
- Disk needs a network (can't download OS without network)
- Everything needs to happen in the right order

#### Terraform's Job

Figure out the correct order automatically!

#### How Terraform Knows

```hcl
resource "libvirt_volume" "disk" {
  name = "my-disk"
}

resource "libvirt_domain" "vm" {
  disk {
    volume_id = libvirt_volume.disk.id  # ← This tells Terraform: "I need the disk first!"
  }
}
```

**Terraform sees:** "VM uses disk.id, so I must create disk before VM"

**You don't need to tell Terraform the order!** Just reference resources, and Terraform figures it out.

#### When You DO Need to Help

Sometimes Terraform can't figure it out automatically. Then you use `depends_on`:

```hcl
resource "libvirt_domain" "vm" {
  depends_on = [libvirt_network.app]  # "Create network first, even though I don't directly reference it"
}
```

**But 95% of the time, you don't need this!** Terraform is smart.

[Keep existing detailed examples]
```

**Testing**:
- [ ] Verify examples are accurate
- [ ] Check analogies make sense
- [ ] Ensure code is valid

---

### Task 3.4: Testing Challenge 3 Changes

**Before moving to Challenge 4:**

1. **Visual Review**:
   - [ ] Read through entire assignment.md
   - [ ] Check all analogies make sense
   - [ ] Verify YAML examples are valid
   - [ ] Ensure flow is logical

2. **Technical Validation**:
   - [ ] Test all code examples
   - [ ] Verify libvirt syntax is correct
   - [ ] Check cloud-init examples

3. **Git Commit**:
   ```bash
   git add 03-infrastructure-resources/assignment.md
   git commit -m "TF-100 Challenge 3: Improve infrastructure concepts
   
   - Add libvirt context and explanation
   - Simplify cloud-init introduction
   - Improve resource dependencies explanation
   - Add real-world analogies throughout
   - Clarify YAML syntax for beginners"
   ```

---

## Challenge 4: State Management & CLI

**File**: `04-state-management-cli/assignment.md`  
**Estimated Time**: 3-4 hours  
**Risk**: Low (mostly additions)

### Task 4.1: Simplify State Concept (Lines 83-130)

**Location**: "Understanding Terraform State" section  
**Action**: Add beginner-friendly explanation

**Add before existing content**:
```markdown
### What is State? (The Simple Explanation)

#### Terraform's Memory Problem

Imagine you create 10 VMs with Terraform. A week later, you want to add 2 more.

**Question:** How does Terraform know which 10 VMs it created?

**Without State:**
- Terraform would have to check EVERY VM in your account
- It wouldn't know which ones it created
- It might try to create duplicates
- It couldn't track changes

**With State:**
- Terraform writes down: "I created these 10 VMs"
- Next time: "Oh, I already have 10. I just need to add 2 more"
- Fast and accurate!

#### Real-World Analogy

- **State file** = Your shopping receipt
- **Infrastructure** = The groceries you bought

Without the receipt, how do you know what you bought? The state file is Terraform's receipt.

#### What's in the State File?

```json
{
  "resources": [
    {
      "type": "libvirt_domain",
      "name": "my-vm",
      "id": "abc123",
      "memory": 2048
    }
  ]
}
```

**In plain English:** "I created a VM named 'my-vm' with ID 'abc123' and 2GB RAM"

#### Important Rules

1. ❌ Never edit state files manually (you'll break things)
2. ✅ Let Terraform manage state automatically
3. ✅ Backup state files (they're important!)

### Understanding Terraform State (Technical Details)

[Keep existing detailed content]
```

**Testing**:
- [ ] Verify analogy makes sense
- [ ] Check JSON example is valid
- [ ] Ensure flow is logical

---

### Task 4.2: Prioritize Essential Commands (Lines 131-320)

**Location**: "State Inspection Commands" section  
**Action**: Add "Essential 3" section

**Add before existing content**:
```markdown
### State Commands: The Essential 3

As a beginner, you only need **3 commands** for 95% of situations:

#### 1. `terraform state list` - See What You Have
```bash
terraform state list
```
**Shows:** All resources Terraform is managing

**When to use:** "What did I create?"

**Example output:**
```
libvirt_network.app
libvirt_domain.web
libvirt_volume.disk
```

#### 2. `terraform state show` - See Details
```bash
terraform state show libvirt_domain.vm
```
**Shows:** All details about a specific resource

**When to use:** "What are the settings for this VM?"

**Example output:**
```
resource "libvirt_domain" "vm" {
  name   = "my-vm"
  memory = 2048
  vcpu   = 2
  ...
}
```

#### 3. `terraform show` - See Everything
```bash
terraform show
```
**Shows:** Your entire infrastructure in readable format

**When to use:** "Show me everything I've created"

**That's it!** Master these 3 first.

### Advanced State Commands (Skip for Now)

<details>
<summary>Click here for advanced state commands (you can learn these later)</summary>

[Move existing comprehensive list here]

</details>
```

**Testing**:
- [ ] Verify commands are correct
- [ ] Check examples are accurate
- [ ] Ensure collapsible section works

---

### Task 4.3: Clarify Workspace Note (Lines 177-178)

**Location**: Workspace note  
**Action**: Expand explanation

**Replace existing note with**:
```markdown
### A Note About Workspaces (Confusing Terminology Alert! ⚠️)

**You might see "workspaces" mentioned in Terraform tutorials.**

**IMPORTANT: There are TWO different things both called "workspaces":**

#### 1. CLI Workspaces (terraform workspace command)
```bash
terraform workspace new dev
terraform workspace select prod
```
- ❌ **NOT recommended for production** by HashiCorp
- ❌ Can cause confusion and accidents
- ❌ All environments share same backend
- ⚠️ This is what we're skipping in this course

#### 2. HCP Terraform/Enterprise Workspaces
- ✅ **Completely different concept** (confusing naming!)
- ✅ Recommended for production
- ✅ Each workspace has separate state, variables, and permissions
- ✅ Think of these as "projects" not "environments"

**The Confusion:**
HashiCorp used the same word "workspace" for two different things:
- **CLI workspaces** = Multiple environments in one config (not recommended)
- **HCP workspaces** = Separate projects with full isolation (recommended)

**For this course:** We're NOT teaching CLI workspaces because:
- ❌ HashiCorp doesn't recommend them for production
- ❌ They can cause confusion and accidents
- ❌ Better alternatives exist

**What to use instead of CLI workspaces:**
- ✅ Separate directories for each environment
- ✅ Separate state backends per environment
- ✅ HCP Terraform workspaces (the good kind!)

**Don't worry about this now!** Just know that if you see "workspace" in other tutorials:
1. Ask: "CLI workspace or HCP workspace?"
2. CLI workspaces = older pattern we're skipping
3. HCP workspaces = different thing, used in enterprise

**Focus on:** Learning state management properly first. You'll learn about HCP Terraform workspaces in advanced courses.
```

**Testing**:
- [ ] Verify explanation is clear
- [ ] Check it clarifies the CLI vs HCP workspace confusion
- [ ] Ensure it doesn't confuse beginners
- [ ] Ensure it flows with surrounding content

---

### Task 4.4: Testing Challenge 4 Changes

**Before moving to Challenge 5:**

1. **Visual Review**:
   - [ ] Read through entire assignment.md
   - [ ] Check all analogies make sense
   - [ ] Verify command examples are correct
   - [ ] Ensure collapsible sections work

2. **Technical Validation**:
   - [ ] Test all commands
   - [ ] Verify state examples are accurate
   - [ ] Check that explanations are clear

3. **Git Commit**:
   ```bash
   git add 04-state-management-cli/assignment.md
   git commit -m "TF-100 Challenge 4: Simplify state management
   
   - Add beginner-friendly state explanation
   - Prioritize essential 3 commands
   - Clarify workspace note
   - Add shopping receipt analogy
   - Improve command examples"
   ```

---

## Challenge 5: Skills Assessment

**File**: `05-skills-assessment/assignment.md`  
**Estimated Time**: 2-3 hours  
**Risk**: Low (mostly additions)

### Task 5.1: Add Phased Approach (Lines 30-40)

**Location**: After "Challenge Overview"  
**Action**: Add step-by-step approach

**Add new section**:
```markdown
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

## 📋 Project Requirements

[Keep existing requirements]
```

**Testing**:
- [ ] Verify timeline is realistic
- [ ] Check hints are helpful
- [ ] Ensure it reduces anxiety

---

### Task 5.2: Prioritize Requirements (Lines 59-184)

**Location**: "Technical Requirements" section  
**Action**: Add priority levels

**Add before existing requirements**:
```markdown
## 🎯 Technical Requirements - Priority Levels

Not all requirements are equal. Here's what matters most:

### 🔴 Critical (Must Have)
If these don't work, the challenge fails:
- [ ] 3 VMs created and running
- [ ] VMs have IP addresses
- [ ] Infrastructure deploys without errors
- [ ] Code is valid (`terraform validate` passes)

### 🟡 Important (Should Have)
These show you understand the concepts:
- [ ] Variables used (no hardcoded values)
- [ ] Outputs defined
- [ ] Files organized properly
- [ ] Environment-aware naming

### 🟢 Nice to Have (Extra Credit)
These show mastery:
- [ ] Variable validation
- [ ] Comprehensive outputs
- [ ] Perfect code formatting
- [ ] Detailed documentation

### Strategy

1. Get the 🔴 Critical items working first
2. Then add 🟡 Important features
3. Finally polish with 🟢 Nice to Have items

**Minimum Passing:** All 🔴 Critical + Most 🟡 Important = 70+ points

## 📋 Detailed Requirements

[Keep existing detailed requirements]
```

**Testing**:
- [ ] Verify priority levels make sense
- [ ] Check strategy is clear
- [ ] Ensure it reduces overwhelm

---

### Task 5.3: Testing Challenge 5 Changes

**Before finalizing:**

1. **Visual Review**:
   - [ ] Read through entire assignment.md
   - [ ] Check phased approach is clear
   - [ ] Verify priority levels make sense
   - [ ] Ensure it reduces anxiety

2. **Git Commit**:
   ```bash
   git add 05-skills-assessment/assignment.md
   git commit -m "TF-100 Challenge 5: Add scaffolding for assessment
   
   - Add phased approach with timeline
   - Prioritize requirements (critical/important/nice-to-have)
   - Add 'if you get stuck' guidance
   - Reduce assessment anxiety
   - Provide clear strategy"
   ```

---

## Final Steps

### Step 1: Create Glossary

**File**: `instruqt/iac-bootcamp/tf-100-fundamentals-lab/GLOSSARY.md`  
**Estimated Time**: 1 hour

```markdown
# TF-100 Glossary

Quick reference for Terraform terms used in this lab.

## A

**Apply**: The command that creates/updates infrastructure (`terraform apply`)

## C

**Cloud-Init**: Automated VM configuration on first boot

## D

**Declarative**: Describing what you want, not how to build it

## H

**HCL**: HashiCorp Configuration Language - the language Terraform uses

## I

**IaC**: Infrastructure as Code - managing infrastructure through code files

**Init**: The command that downloads providers (`terraform init`)

## P

**Plan**: The command that shows what changes Terraform will make (`terraform plan`)

**Provider**: A plugin that lets Terraform talk to a service (AWS, Azure, libvirt, etc.)

## R

**Resource**: A piece of infrastructure (VM, network, file, etc.)

## S

**State**: Terraform's memory of what infrastructure it created

## V

**Variable**: A value that can be changed without modifying code
```

**Testing**:
- [ ] Verify all terms are defined
- [ ] Check definitions are beginner-friendly
- [ ] Ensure alphabetical order

**Git Commit**:
```bash
git add GLOSSARY.md
git commit -m "TF-100: Add glossary for beginners"
```

---

### Step 2: Update README

**File**: `instruqt/iac-bootcamp/tf-100-fundamentals-lab/README.md`  
**Action**: Add link to glossary and review document

**Add to "Additional Resources" section**:
```markdown
### Lab Documentation
- **[Glossary](GLOSSARY.md)** - Quick reference for Terraform terms
- **[Common Mistakes Guide](COMMON_MISTAKES.md)** - Avoid common pitfalls
- **[Best Practices Guide](BEST_PRACTICES.md)** - Industry-standard practices
```

**Git Commit**:
```bash
git add README.md
git commit -m "TF-100: Update README with glossary link"
```

---

### Step 3: Final Testing

**Complete Lab Walkthrough**:
1. [ ] Start lab from beginning
2. [ ] Complete Challenge 1 with new language
3. [ ] Complete Challenge 2 with new language
4. [ ] Complete Challenge 3 with new language
5. [ ] Complete Challenge 4 with new language
6. [ ] Complete Challenge 5 with new language
7. [ ] Note any issues or confusion points

**Beginner Testing** (if possible):
1. [ ] Have 2-3 beginners attempt the lab
2. [ ] Observe where they get stuck
3. [ ] Note any confusion points
4. [ ] Iterate on language based on feedback

---

### Step 4: Deploy to Instruqt

**Deployment Checklist**:
- [ ] All changes committed to git
- [ ] All tests passing
- [ ] README updated
- [ ] Glossary created
- [ ] No broken links
- [ ] All code examples valid

**Deploy**:
```bash
# Push to GitHub
git push origin tf-100-language-improvements

# Push to Instruqt
instruqt track push

# Test on Instruqt platform
instruqt track test
```

---

## Success Metrics

After implementation, measure:

1. **Completion Rate**: % of students who finish all 5 challenges
   - **Target**: 85%+ (up from estimated 60%)

2. **Time to Complete**: Average time per challenge
   - **Target**: Within estimated times

3. **Support Requests**: Number of "I don't understand" questions
   - **Target**: <5% of students need help

4. **Student Feedback**: Post-lab survey
   - **Target**: 4.5/5.0 rating

5. **Concept Understanding**: Post-lab quiz
   - **Target**: 80%+ correct answers

---

## Rollback Plan

If issues arise:

```bash
# Revert to previous version
git checkout main
instruqt track push

# Or revert specific challenge
git checkout main -- 01-intro-to-iac-and-terraform/assignment.md
instruqt track push
```

---

## Summary

**Total Implementation Time**: 2-3 days  
**Risk Level**: Low (additive changes)  
**Expected Impact**: 60% → 85%+ success rate

**Key Principles**:
1. One challenge at a time
2. Test after each change
3. Commit frequently
4. Get beginner feedback
5. Iterate based on data

**Remember**: The goal is to make Terraform accessible to complete beginners while maintaining technical accuracy.

---

**Created by**: Bob  
**Date**: 2026-05-15  

---

## Appendix: Collapsible Section Examples by Use Case

This appendix provides ready-to-use collapsible section templates for common scenarios throughout the challenges.

### 1. Technical Deep Dives

**Use when**: Explaining how something works internally

```markdown
**Simple explanation of the concept**

<details>
<summary>🔍 Click here to understand how this works internally</summary>

**Technical Details:**
- Internal mechanism explanation
- Architecture diagrams (if applicable)
- Performance considerations
- Edge cases

**Why this matters:** Practical implications

</details>
```

**Example locations**:
- Challenge 1: How Terraform state works
- Challenge 2: How for_each differs from count internally
- Challenge 3: How libvirt networking works
- Challenge 4: How state locking prevents conflicts

---

### 2. Alternative Approaches

**Use when**: Showing other ways to accomplish the same goal

```markdown
**Recommended approach shown above**

<details>
<summary>💡 Click here to see alternative approaches</summary>

**Alternative 1: [Name]**
```hcl
# Code example
```
**Pros:** Benefits  
**Cons:** Drawbacks  
**When to use:** Specific scenarios

**Alternative 2: [Name]**
```hcl
# Code example
```
**Pros:** Benefits  
**Cons:** Drawbacks  
**When to use:** Specific scenarios

</details>
```

**Example locations**:
- Challenge 1: Different ways to organize Terraform files
- Challenge 2: count vs for_each vs for expressions
- Challenge 3: Different cloud-init approaches
- Challenge 4: Local vs remote state backends

---

### 3. Troubleshooting Details

**Use when**: Explaining why errors happen and how to fix them

```markdown
**Error message or symptom**

<details>
<summary>🔧 Click here to understand why this happens and how to fix it</summary>

**Why This Happens:**
Root cause explanation in simple terms

**How to Fix:**
1. Step-by-step solution
2. With code examples
3. And verification steps

**How to Prevent:**
- Best practices to avoid this issue
- Warning signs to watch for

**Related Issues:**
- Link to similar problems
- Common variations

</details>
```

**Example locations**:
- Challenge 1: "terraform: command not found"
- Challenge 2: "Invalid for_each argument"
- Challenge 3: "VM won't start"
- Challenge 4: "State lock timeout"

---

### 4. Historical Context

**Use when**: Explaining why things are the way they are

```markdown
**Current best practice**

<details>
<summary>📚 Click here to learn the history behind this</summary>

**The Old Way:**
How things used to be done

**Why It Changed:**
Problems with the old approach

**The New Way:**
Current best practice and why it's better

**Migration Path:**
If you have old code, here's how to update it

</details>
```

**Example locations**:
- Challenge 1: Evolution of IaC tools
- Challenge 2: Why Terraform moved from count to for_each
- Challenge 3: Libvirt provider version changes
- Challenge 4: Why workspaces aren't recommended anymore

---

### 5. Advanced Concepts

**Use when**: Introducing concepts beyond the current scope

```markdown
**Basic concept explanation**

<details>
<summary>🚀 Click here for advanced concepts (optional)</summary>

**Advanced Topic 1:**
Explanation with examples

**Advanced Topic 2:**
Explanation with examples

**When You'll Need This:**
Scenarios where advanced knowledge helps

**Further Learning:**
- Links to documentation
- Related courses
- Community resources

</details>
```

**Example locations**:
- Challenge 1: Terraform modules (preview)
- Challenge 2: Dynamic blocks
- Challenge 3: Custom providers
- Challenge 4: Remote state backends in depth

---

### 6. Real-World Examples

**Use when**: Showing how concepts apply in production

```markdown
**Concept explanation**

<details>
<summary>🌍 Click here to see real-world examples</summary>

**Example 1: [Company/Scenario]**
- Context: What they needed
- Solution: How they used this concept
- Result: What they achieved

**Example 2: [Company/Scenario]**
- Context: What they needed
- Solution: How they used this concept
- Result: What they achieved

**Key Takeaways:**
- Lessons learned
- Best practices from production use

</details>
```

**Example locations**:
- Challenge 1: How Netflix uses Terraform
- Challenge 2: Variable patterns at scale
- Challenge 3: Multi-region infrastructure
- Challenge 4: State management in large teams

---

### 7. Comparison Tables

**Use when**: Comparing multiple options

```markdown
**Brief comparison summary**

<details>
<summary>📊 Click here for detailed comparison</summary>

| Feature | Option A | Option B | Option C |
|---------|----------|----------|----------|
| Speed | Fast | Medium | Slow |
| Complexity | Simple | Medium | Complex |
| Use Case | Small projects | Medium projects | Large projects |

**Recommendation:**
- Use Option A when: [scenarios]
- Use Option B when: [scenarios]
- Use Option C when: [scenarios]

</details>
```

**Example locations**:
- Challenge 1: Terraform vs other IaC tools
- Challenge 2: count vs for_each vs for expressions
- Challenge 3: Different VM configurations
- Challenge 4: State backend options

---

### 8. Code Walkthroughs

**Use when**: Explaining complex code line-by-line

```markdown
**Code example shown**

<details>
<summary>🔍 Click here for line-by-line explanation</summary>

```hcl
# Line 1: What this does and why
resource "type" "name" {
  
  # Line 3: What this argument does
  argument = "value"
  
  # Line 6: Why this block is needed
  nested_block {
    # Line 8: How this works
    nested_arg = "value"
  }
}
```

**Key Points:**
- Important concepts highlighted
- Common mistakes to avoid
- Best practices demonstrated

</details>
```

**Example locations**:
- Challenge 1: First Terraform configuration
- Challenge 2: Complex for_each example
- Challenge 3: Complete VM configuration
- Challenge 4: State manipulation commands

---

### 9. Documentation Links

**Use when**: Providing official documentation references

```markdown
**Concept explanation**

<details>
<summary>📖 Click here for official documentation links</summary>

**Official Terraform Documentation:**
- [Topic Name](https://www.terraform.io/docs/...) - Brief description
- [Related Topic](https://www.terraform.io/docs/...) - Brief description

**Provider Documentation:**
- [Provider Resource](https://registry.terraform.io/providers/...) - Brief description

**HashiCorp Learn:**
- [Tutorial Name](https://learn.hashicorp.com/...) - Brief description

**Community Resources:**
- [Blog Post/Article](https://...) - Brief description
- [Video Tutorial](https://...) - Brief description

**Why these links are helpful:**
- Official docs are always up-to-date
- Learn tutorials provide hands-on practice
- Community resources show real-world usage

</details>
```

**Example locations**:
- Challenge 1: Terraform basics, HCL syntax, providers
- Challenge 2: Variables, functions, expressions
- Challenge 3: Libvirt provider, cloud-init
- Challenge 4: State management, CLI commands

---

## Implementation Checklist for Collapsible Sections

When adding collapsible sections to each challenge:

### Challenge 1: Introduction
- [ ] Add HCL syntax deep dive
- [ ] Add provider configuration details
- [ ] Add state file structure explanation
- [ ] Add Terraform workflow internals
- [ ] Add IaC tool comparison
- [ ] Add documentation links section

### Challenge 2: Variables & Loops
- [ ] Add variable validation deep dive
- [ ] Add count vs for_each comparison
- [ ] Add function reference tables
- [ ] Add type system explanation
- [ ] Add locals vs variables comparison
- [ ] Add documentation links section

### Challenge 3: Infrastructure
- [ ] Add networking concepts deep dive
- [ ] Add cloud-init detailed explanation
- [ ] Add storage pool architecture
- [ ] Add VM lifecycle explanation
- [ ] Add dependency resolution details
- [ ] Add documentation links section

### Challenge 4: State Management
- [ ] Add state file format deep dive
- [ ] Add locking mechanism explanation
- [ ] Add workspace alternatives comparison
- [ ] Add import process details
- [ ] Add backend options comparison
- [ ] Add documentation links section

### Challenge 5: Assessment
- [ ] Add architecture planning guide
- [ ] Add troubleshooting decision tree
- [ ] Add optimization tips
- [ ] Add production readiness checklist
- [ ] Add documentation links section

---

## Official Documentation Links by Challenge

### Challenge 1: Introduction to IaC & Terraform Basics

Add this collapsible section at the end of the challenge:

```markdown
<details>
<summary>📖 Official Documentation & Learning Resources</summary>

**Terraform Core Documentation:**
- [What is Terraform?](https://www.terraform.io/intro) - Official introduction
- [Terraform Language](https://www.terraform.io/language) - HCL syntax reference
- [Terraform CLI](https://www.terraform.io/cli) - Command-line interface guide
- [Get Started Tutorials](https://learn.hashicorp.com/terraform) - Hands-on learning

**Key Concepts:**
- [Providers](https://www.terraform.io/language/providers) - How providers work
- [Resources](https://www.terraform.io/language/resources) - Resource blocks explained
- [State](https://www.terraform.io/language/state) - Understanding state
- [Configuration Syntax](https://www.terraform.io/language/syntax) - HCL basics

**Local Provider:**
- [Local Provider Documentation](https://registry.terraform.io/providers/hashicorp/local/latest/docs) - Provider reference
- [local_file Resource](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) - File resource docs

**HashiCorp Learn:**
- [Terraform Basics](https://learn.hashicorp.com/collections/terraform/aws-get-started) - Step-by-step tutorials
- [Infrastructure as Code](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code) - IaC concepts

**Community Resources:**
- [Terraform Best Practices](https://www.terraform-best-practices.com/) - Community guide
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform) - Curated resources

</details>
```

---

### Challenge 2: Variables, Loops & Functions

Add this collapsible section at the end of the challenge:

```markdown
<details>
<summary>📖 Official Documentation & Learning Resources</summary>

**Variables & Values:**
- [Input Variables](https://www.terraform.io/language/values/variables) - Variable definition and usage
- [Output Values](https://www.terraform.io/language/values/outputs) - Outputs explained
- [Local Values](https://www.terraform.io/language/values/locals) - Locals vs variables
- [Variable Validation](https://www.terraform.io/language/values/variables#custom-validation-rules) - Validation rules

**Expressions & Loops:**
- [Expressions](https://www.terraform.io/language/expressions) - All expression types
- [For Expressions](https://www.terraform.io/language/expressions/for) - List/map transformations
- [count Meta-Argument](https://www.terraform.io/language/meta-arguments/count) - Numeric loops
- [for_each Meta-Argument](https://www.terraform.io/language/meta-arguments/for_each) - Map/set iteration

**Functions:**
- [Built-in Functions](https://www.terraform.io/language/functions) - Complete function reference
- [String Functions](https://www.terraform.io/language/functions/string) - Text manipulation
- [Collection Functions](https://www.terraform.io/language/functions/collection) - List/map operations
- [Numeric Functions](https://www.terraform.io/language/functions/numeric) - Math operations

**HashiCorp Learn:**
- [Define Input Variables](https://learn.hashicorp.com/tutorials/terraform/variables) - Variables tutorial
- [Query Data with Outputs](https://learn.hashicorp.com/tutorials/terraform/outputs) - Outputs tutorial
- [Create Dynamic Expressions](https://learn.hashicorp.com/tutorials/terraform/expressions) - Expressions tutorial

**Interactive Tools:**
- [Terraform Console](https://www.terraform.io/cli/commands/console) - Test expressions interactively

</details>
```

---

### Challenge 3: Infrastructure Resources

Add this collapsible section at the end of the challenge:

```markdown
<details>
<summary>📖 Official Documentation & Learning Resources</summary>

**Libvirt Provider:**
- [Libvirt Provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) - Provider overview
- [libvirt_domain](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/domain) - VM resource
- [libvirt_volume](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) - Storage volumes
- [libvirt_network](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/network) - Networks
- [libvirt_cloudinit_disk](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/cloudinit) - Cloud-init

**Cloud-Init:**
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/) - Official cloud-init docs
- [Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html) - Configuration examples
- [Cloud-Init Modules](https://cloudinit.readthedocs.io/en/latest/topics/modules.html) - Available modules

**Terraform Resource Management:**
- [Resources](https://www.terraform.io/language/resources) - Resource blocks
- [Resource Dependencies](https://www.terraform.io/language/resources/behavior#resource-dependencies) - Dependency management
- [Data Sources](https://www.terraform.io/language/data-sources) - Reading existing resources
- [Resource Lifecycle](https://www.terraform.io/language/meta-arguments/lifecycle) - Lifecycle management

**HashiCorp Learn:**
- [Manage Resources](https://learn.hashicorp.com/tutorials/terraform/resource) - Resource tutorial
- [Manage Resource Drift](https://learn.hashicorp.com/tutorials/terraform/resource-drift) - Drift detection

**Networking Concepts:**
- [CIDR Notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) - IP addressing
- [NAT Networking](https://en.wikipedia.org/wiki/Network_address_translation) - NAT explained

</details>
```

---

### Challenge 4: State Management & CLI

Add this collapsible section at the end of the challenge:

```markdown
<details>
<summary>📖 Official Documentation & Learning Resources</summary>

**State Management:**
- [State](https://www.terraform.io/language/state) - State overview
- [State Purpose](https://www.terraform.io/language/state/purpose) - Why state exists
- [Remote State](https://www.terraform.io/language/state/remote) - Remote backends
- [State Locking](https://www.terraform.io/language/state/locking) - Preventing conflicts

**State Commands:**
- [terraform state](https://www.terraform.io/cli/commands/state) - State command overview
- [state list](https://www.terraform.io/cli/commands/state/list) - List resources
- [state show](https://www.terraform.io/cli/commands/state/show) - Show resource details
- [state mv](https://www.terraform.io/cli/commands/state/mv) - Move resources
- [state rm](https://www.terraform.io/cli/commands/state/rm) - Remove resources
- [state pull/push](https://www.terraform.io/cli/commands/state/pull) - Backup/restore state

**Import & Migration:**
- [Import](https://www.terraform.io/cli/import) - Import existing resources
- [Moved Block](https://www.terraform.io/language/modules/develop/refactoring) - Refactoring resources

**CLI Commands:**
- [CLI Documentation](https://www.terraform.io/cli) - All CLI commands
- [terraform console](https://www.terraform.io/cli/commands/console) - Interactive console
- [terraform fmt](https://www.terraform.io/cli/commands/fmt) - Format code
- [terraform validate](https://www.terraform.io/cli/commands/validate) - Validate configuration

**Debugging:**
- [Debugging Terraform](https://www.terraform.io/internals/debugging) - Debug guide
- [Log Levels](https://www.terraform.io/internals/debugging#terraform-log-levels) - Logging options

**HashiCorp Learn:**
- [Manage Terraform State](https://learn.hashicorp.com/tutorials/terraform/state-cli) - State tutorial
- [Import Terraform Configuration](https://learn.hashicorp.com/tutorials/terraform/state-import) - Import tutorial
- [Use Refresh-Only Mode](https://learn.hashicorp.com/tutorials/terraform/refresh) - Refresh tutorial

**Backends:**
- [Backend Configuration](https://www.terraform.io/language/settings/backends) - Backend types
- [S3 Backend](https://www.terraform.io/language/settings/backends/s3) - AWS S3 backend
- [HCP Terraform](https://www.terraform.io/cloud-docs) - Terraform Cloud backend

</details>
```

---

### Challenge 5: Skills Assessment

Add this collapsible section at the end of the challenge:

```markdown
<details>
<summary>📖 Official Documentation & Learning Resources</summary>

**Complete Reference:**
- [Terraform Documentation](https://www.terraform.io/docs) - Full documentation
- [Terraform Registry](https://registry.terraform.io/) - Provider and module registry
- [HashiCorp Learn](https://learn.hashicorp.com/terraform) - All tutorials

**Best Practices:**
- [Terraform Style Guide](https://www.terraform.io/language/syntax/style) - Code style conventions
- [Recommended Practices](https://www.terraform.io/cloud-docs/recommended-practices) - HashiCorp recommendations
- [Module Development](https://www.terraform.io/language/modules/develop) - Module best practices

**Advanced Topics:**
- [Terraform Testing](https://www.terraform.io/language/tests) - Testing framework
- [Policy as Code](https://www.terraform.io/cloud-docs/policy-enforcement) - Sentinel policies
- [Workspaces](https://www.terraform.io/language/state/workspaces) - Workspace usage

**Community:**
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core) - Get help
- [Terraform GitHub](https://github.com/hashicorp/terraform) - Source code and issues
- [Terraform Blog](https://www.hashicorp.com/blog/products/terraform) - Latest updates

**Certification:**
- [Terraform Associate Certification](https://www.hashicorp.com/certification/terraform-associate) - Official certification
- [Exam Review](https://learn.hashicorp.com/tutorials/terraform/associate-review) - Certification prep

**Next Steps:**
- [TF-200: Modules & Patterns](link-to-tf-200) - Continue learning
- [Terraform on AWS](https://learn.hashicorp.com/collections/terraform/aws) - Cloud-specific tutorials
- [Terraform on Azure](https://learn.hashicorp.com/collections/terraform/azure) - Azure tutorials
- [Terraform on GCP](https://learn.hashicorp.com/collections/terraform/gcp) - GCP tutorials

</details>
```

---

## Testing Collapsible Sections

After adding collapsible sections:

1. **Markdown Preview Test**
   ```bash
   # View in VS Code markdown preview
   # Verify sections collapse/expand correctly
   ```

2. **Instruqt Rendering Test**
   - Deploy to Instruqt test environment
   - Verify sections render correctly
   - Test on different browsers/devices

3. **User Experience Test**
   - Ask test users: "Did you notice the expandable sections?"
   - Ask: "Did you click on any? Which ones?"
   - Ask: "Was the information helpful?"

4. **Content Balance Test**
   - Main content should be complete without expanding
   - Expanded content should add value, not repeat
   - No critical information hidden in collapsible sections

---
**Status**: Ready for implementation