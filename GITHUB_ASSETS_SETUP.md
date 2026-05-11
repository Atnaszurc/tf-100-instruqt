# GitHub-Based Assets Distribution

## Overview

This lab uses a GitHub repository to distribute Terraform configuration files to Instruqt challenges. This approach is necessary because Instruqt's built-in assets feature only supports markdown files, not arbitrary file distribution.

## Architecture

```
GitHub Repository (Public)
    └── instruqt/iac-bootcamp/tf-100-fundamentals-lab/
        └── assets/
            ├── challenge-01/
            │   ├── main.tf
            │   └── README.md
            ├── challenge-02/
            │   ├── main.tf
            │   ├── variables.tf
            │   ├── locals.tf
            │   ├── outputs.tf
            │   ├── dev.tfvars
            │   └── README.md
            ├── challenge-03/
            │   ├── main.tf
            │   ├── network.tf
            │   ├── storage.tf
            │   ├── vms.tf
            │   ├── outputs.tf
            │   └── README.md
            ├── challenge-04/
            │   ├── main.tf
            │   └── README.md
            └── challenge-05/
                ├── main.tf
                ├── variables.tf
                ├── outputs.tf
                └── README.md

Instruqt VM
    └── /root/lab-assets/
        └── [cloned repository content]
```

## Setup Process

### 1. Track-Level Setup (track_scripts/setup-workstation)

The track-level setup script clones the repository once when the lab starts:

```bash
# Clone the lab assets repository
echo "Cloning lab assets from GitHub..."
REPO_URL="https://github.com/YOUR_USERNAME/iac-bootcamp.git"
ASSETS_DIR="/root/lab-assets"

if [ ! -d "$ASSETS_DIR" ]; then
    git clone "$REPO_URL" "$ASSETS_DIR"
    echo "✓ Lab assets cloned successfully"
else
    echo "✓ Lab assets already present"
fi
```

### 2. Challenge-Level Setup

Each challenge's setup script copies files from the cloned repository:

```bash
# Example: Challenge 1
mkdir -p /root/terraform-workspace/examples/challenge-01
cp -r /root/lab-assets/tf-100-fundamentals-lab/assets/challenge-01/* \
      /root/terraform-workspace/examples/challenge-01/
```

## Repository Requirements

### Must Be Public

The repository must be public because:
- No authentication is configured in the Instruqt VM
- Git clone needs to work without credentials
- Simplifies setup and maintenance

### Repository Structure

The repository must maintain this exact structure:
```
instruqt/iac-bootcamp/tf-100-fundamentals-lab/assets/challenge-XX/
```

This matches the path structure used in the setup scripts.

## Benefits

1. **Version Control**: All Terraform configurations are version controlled
2. **Easy Updates**: Update files in GitHub, changes propagate to new lab instances
3. **Maintainability**: Real Terraform files with IDE support, not heredocs
4. **Testability**: Can validate configurations before pushing
5. **Transparency**: Students can see the example solutions in GitHub

## Updating Assets

To update the lab assets:

1. Make changes to files in `instruqt/iac-bootcamp/tf-100-fundamentals-lab/assets/`
2. Test locally with `terraform validate`
3. Commit and push to GitHub
4. New lab instances will automatically get the updated files

## Troubleshooting

### Repository Not Found
- Verify the repository is public
- Check the REPO_URL in track_scripts/setup-workstation
- Ensure the repository name matches exactly

### Files Not Copied
- Verify the directory structure matches exactly
- Check file permissions in the repository
- Ensure the challenge number matches (challenge-01, challenge-02, etc.)

### Git Clone Fails
- Check internet connectivity in Instruqt VM
- Verify GitHub is accessible
- Check for typos in the repository URL

## Configuration Files

### Track-Level Setup
**File**: `track_scripts/setup-workstation`
**Purpose**: Clone repository once at track start
**Key Variables**:
- `REPO_URL`: GitHub repository URL (must be updated)
- `ASSETS_DIR`: Local directory for cloned repo (`/root/lab-assets`)

### Challenge Setup Scripts
**Files**: `XX-challenge-name/setup-workstation`
**Purpose**: Copy assets from cloned repo to working directories
**Source Path**: `/root/lab-assets/tf-100-fundamentals-lab/assets/challenge-XX/`
**Destination Paths**:
- Challenge 1: `/root/terraform-workspace/examples/challenge-01/`
- Challenges 2-5: `/root/terraform-lab-solutions/challenge-XX/`

## TODO Before Deployment

1. **Update Repository URL**: Change `YOUR_USERNAME` in track_scripts/setup-workstation
2. **Make Repository Public**: Ensure the repository is publicly accessible
3. **Test Clone**: Verify `git clone` works without authentication
4. **Verify Paths**: Ensure all paths match the repository structure
5. **Test on Instruqt**: Run `instruqt track test` to verify everything works

## Example: Complete Flow

1. **Track Starts**: 
   - `track_scripts/setup-workstation` runs
   - Clones repository to `/root/lab-assets/`

2. **Challenge 1 Starts**:
   - `01-intro-to-iac-and-terraform/setup-workstation` runs
   - Copies from `/root/lab-assets/tf-100-fundamentals-lab/assets/challenge-01/`
   - To `/root/terraform-workspace/examples/challenge-01/`

3. **Student Works**:
   - Works in `/root/terraform-workspace/`
   - Can reference example in `examples/challenge-01/`

4. **Challenge 2 Starts**:
   - `02-variables-loops-functions/setup-workstation` runs
   - Copies from `/root/lab-assets/tf-100-fundamentals-lab/assets/challenge-02/`
   - To `/root/terraform-lab-solutions/challenge-02/`

And so on for all challenges.

## Security Considerations

- Repository is public (no sensitive data)
- No authentication required (simplifies setup)
- Read-only access (students can't modify repository)
- Assets are copied, not symlinked (isolation between challenges)

---

**Last Updated**: Phase 20 - GitHub Assets Implementation
**Status**: Ready for deployment after updating REPO_URL