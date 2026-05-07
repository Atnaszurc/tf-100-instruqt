# TF-100 Lab Deployment Guide

This guide covers how to deploy the TF-100 Fundamentals Lab to Instruqt using the CLI.

---

## Prerequisites

### 1. Install Instruqt CLI

```bash
# Linux
curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
chmod +x /usr/local/bin/instruqt

# macOS
brew install instruqt/tap/instruqt

# Verify installation
instruqt version
```

### 2. Authenticate

```bash
# Login interactively
instruqt auth login

# Or use API token
export INSTRUQT_TOKEN="your-api-token-here"

# Verify authentication
instruqt auth status
```

---

## Deployment Steps

### Step 1: Navigate to Track Directory

```bash
cd instruqt/iac-bootcamp/tf-100-fundamentals-lab
```

### Step 2: Validate Track

Before pushing, always validate:

```bash
# Validate track structure
instruqt track validate

# Expected output:
# ✓ Track is valid
```

If validation fails, fix the errors before proceeding.

### Step 3: Push Track to Instruqt

The CLI reads from your local folder and creates/updates the track on Instruqt:

```bash
# Push to your default organization
instruqt track push

# Or specify organization
instruqt track push --organization your-org-name

# Push with a specific tag/version
instruqt track push --tag v1.0.0
```

**What happens:**
- Instruqt CLI reads all files from current directory
- Creates or updates the track based on `track.yml`
- Uploads all challenge content (assignment.md, scripts)
- Uploads track-level scripts
- Processes configuration from `config.yml`

### Step 4: Verify Deployment

```bash
# List your tracks
instruqt track list

# Get track details
instruqt track info

# Test the track
instruqt track test
```

---

## Working with Local Folder

### Directory Structure

The CLI expects this structure (which we have):

```
tf-100-fundamentals-lab/
├── track.yml                    # Track configuration
├── config.yml                   # VM/environment config
├── track_scripts/               # Track-level scripts
│   ├── setup-workstation
│   └── cleanup-workstation
├── 01-intro-to-iac-and-terraform/
│   ├── assignment.md
│   ├── setup-workstation
│   └── check-workstation
├── 02-variables-loops-functions/
│   ├── assignment.md
│   ├── setup-workstation
│   └── check-workstation
└── ... (other challenges)
```

### How CLI Reads Local Folder

1. **track.yml** - Defines track metadata and challenge list
2. **config.yml** - Defines infrastructure (VMs, containers)
3. **Challenge directories** - Named with pattern `NN-slug-name/`
4. **Scripts** - Must be named exactly `setup-<tab>` and `check-<tab>`
5. **Assignment** - Must be named `assignment.md`

---

## Common Commands

### Create New Track (First Time)

If the track doesn't exist yet:

```bash
# The push command will create it automatically
instruqt track push
```

### Update Existing Track

```bash
# Push updates
instruqt track push

# Push with version tag
instruqt track push --tag v1.0.1
```

### Test Track Locally

```bash
# Test entire track
instruqt track test

# Test specific challenge
instruqt track test --challenge 01-intro-to-iac-and-terraform

# Skip failure checks (useful for development)
instruqt track test --skip-fail-check
```

### Pull Track from Instruqt

If you need to download an existing track:

```bash
# Pull track to current directory
instruqt track pull

# Pull specific version
instruqt track pull --tag v1.0.0
```

---

## Version Management

### Tagging Versions

```bash
# Push with semantic version
instruqt track push --tag v1.0.0

# Push with descriptive tag
instruqt track push --tag production-2024-01

# Push development version
instruqt track push --tag dev-$(date +%Y%m%d)
```

### List Versions

```bash
# List all versions of track
instruqt track versions
```

### Rollback to Previous Version

```bash
# Pull specific version
instruqt track pull --tag v1.0.0

# Push it again (creates new version)
instruqt track push --tag v1.0.0-restored
```

---

## Troubleshooting

### Validation Errors

```bash
# Run validation with verbose output
instruqt track validate --verbose

# Common issues:
# - Missing required files (assignment.md, scripts)
# - Invalid YAML syntax in track.yml or config.yml
# - Incorrect challenge directory naming
# - Missing shebang in scripts
```

### Push Failures

```bash
# Check authentication
instruqt auth status

# Re-authenticate if needed
instruqt auth login

# Check organization access
instruqt organization list
```

### Script Errors

```bash
# Test scripts locally first
bash -n track_scripts/setup-workstation
bash -n 01-intro-to-iac-and-terraform/setup-workstation

# Use our validation script
./tests/validate-track.sh
```

---

## Best Practices

### Before Every Push

1. **Validate locally:**
   ```bash
   ./tests/validate-track.sh
   instruqt track validate
   ```

2. **Test changes:**
   ```bash
   instruqt track test --skip-fail-check
   ```

3. **Tag versions:**
   ```bash
   instruqt track push --tag v1.0.X
   ```

### Development Workflow

```bash
# 1. Make changes to local files
vim 01-intro-to-iac-and-terraform/assignment.md

# 2. Validate
./tests/validate-track.sh

# 3. Test specific challenge
./tests/test-challenge.sh 01

# 4. Push to development
instruqt track push --tag dev-$(date +%Y%m%d-%H%M)

# 5. Test on Instruqt
# (Use Instruqt web interface to test)

# 6. If good, push to production
instruqt track push --tag v1.0.X
```

### Production Deployment

```bash
# 1. Ensure all tests pass
./tests/validate-track.sh

# 2. Tag with version
VERSION="v1.0.$(date +%Y%m%d)"

# 3. Push to production
instruqt track push --tag $VERSION

# 4. Document in git
git tag -a $VERSION -m "Production release $VERSION"
git push origin $VERSION
```

---

## Configuration Options

### track.yml Key Fields

```yaml
slug: tf-100-terraform-fundamentals  # Unique identifier
title: "TF-100: Terraform Fundamentals"
teaser: "Learn Terraform from zero to proficient"
description: "Comprehensive hands-on lab..."
icon: https://...  # Track icon URL
tags:
  - terraform
  - iac
  - fundamentals
owner: your-org-name
developers:
  - your-email@example.com
idle_timeout: 32400  # 9 hours
timelimit: 32400
skipping_enabled: true
```

### config.yml Key Fields

```yaml
version: "3"
virtualmachines:
  - name: workstation
    image: ubuntu2204
    machine_type: n1-standard-4
    nested_virtualization: true  # Required for Libvirt
```

---

## Getting Help

### CLI Help

```bash
# General help
instruqt --help

# Command-specific help
instruqt track --help
instruqt track push --help
instruqt track test --help
```

### Documentation

- [Instruqt CLI Reference](https://docs.instruqt.com/reference/cli)
- [Track Development Guide](https://docs.instruqt.com/tracks)
- [Configuration Reference](https://docs.instruqt.com/reference/config)

### Support

- Instruqt Community Forum
- Instruqt Support (support@instruqt.com)
- Our TESTING_GUIDE.md for local testing

---

## Quick Reference

```bash
# Essential commands
instruqt auth login                    # Authenticate
instruqt track validate                # Validate track
instruqt track push                    # Deploy track
instruqt track push --tag v1.0.0      # Deploy with version
instruqt track test                    # Test track
instruqt track info                    # Get track details
instruqt track list                    # List your tracks

# Development workflow
./tests/validate-track.sh              # Local validation
./tests/test-challenge.sh 01           # Test challenge
instruqt track push --tag dev-test    # Push to dev
instruqt track test --skip-fail-check  # Quick test
instruqt track push --tag v1.0.X      # Push to prod
```

---

## Next Steps

After deployment:

1. **Test the track** in Instruqt web interface
2. **Share with team** for feedback
3. **Monitor usage** via Instruqt analytics
4. **Iterate** based on user feedback
5. **Update** using `instruqt track push`

---

**Ready to deploy? Run these commands:**

```bash
cd instruqt/iac-bootcamp/tf-100-fundamentals-lab
instruqt auth login
instruqt track validate
instruqt track push --tag v1.0.0
```

Good luck! 🚀