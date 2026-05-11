# Phase 19: Assets-Based Architecture Refactoring

## Summary

Successfully refactored Challenges 3, 4, and 5 to use an assets-based architecture, dramatically simplifying setup scripts and improving maintainability.

## Changes Made

### Challenge 3: Infrastructure Resources
**Assets Created:**
- `assets/challenge-03/main.tf` (14 lines) - Provider configuration
- `assets/challenge-03/network.tf` (18 lines) - Network resource with outputs
- `assets/challenge-03/storage.tf` (77 lines) - Base volume + 3 derived volumes
- `assets/challenge-03/vms.tf` (145 lines) - 3 VM definitions (web, app, db)
- `assets/challenge-03/outputs.tf` (42 lines) - Infrastructure outputs
- `assets/challenge-03/README.md` (29 lines) - Documentation

**Setup Script:**
- **Before:** 405 lines with embedded heredocs
- **After:** 44 lines (89% reduction)
- **Method:** Simple `cp -r /tmp/assets/challenge-03/*`

**Validation:** ✅ `terraform validate` passed

### Challenge 4: State Management & CLI
**Assets Created:**
- `assets/challenge-04/main.tf` (103 lines) - Workspace-aware VM configuration
- `assets/challenge-04/README.md` (58 lines) - Documentation

**Setup Script:**
- **Before:** 208 lines with embedded heredocs
- **After:** 56 lines (73% reduction)
- **Method:** Simple `cp -r /tmp/assets/challenge-04/*`

**Key Fix:** Moved console block inside devices block as array (libvirt 0.9+ requirement)

**Validation:** ✅ `terraform validate` passed

### Challenge 5: Skills Assessment
**Assets Created:**
- `assets/challenge-05/main.tf` (227 lines) - Complete multi-tier infrastructure
- `assets/challenge-05/variables.tf` (81 lines) - Environment-specific variables
- `assets/challenge-05/outputs.tf` (43 lines) - Comprehensive outputs
- `assets/challenge-05/README.md` (58 lines) - Documentation

**Setup Script:**
- **Before:** 572 lines with embedded heredocs
- **After:** 79 lines (86% reduction)
- **Method:** Simple `cp -r /tmp/assets/challenge-05/*`

**Key Fixes:**
- Base volume: `create.content.url` (not `source`)
- Derived volumes: `backing_store` (not `base_volume`)
- Console blocks: Inside devices as array

**Validation:** ✅ `terraform validate` passed

## Benefits

### 1. Maintainability
- Real Terraform files instead of heredocs in bash
- Easy to edit with IDE support
- Syntax highlighting and validation
- Version control friendly

### 2. Testability
- Can run `terraform validate` directly on assets
- Can test configurations independently
- Easier to catch syntax errors early

### 3. Simplicity
- Setup scripts reduced by 73-89%
- Single `cp` command instead of multiple heredocs
- Less error-prone
- Easier to understand

### 4. Consistency
- All challenges follow same pattern
- Assets folder structure is clear
- Predictable file locations

## Libvirt 0.9+ Syntax Requirements

### Volume Configuration
```hcl
# Base image from URL
resource "libvirt_volume" "base" {
  name = "base.qcow2"
  pool = "default"
  create = {
    content = {
      url = "https://..."
    }
  }
  target = {
    format = { type = "qcow2" }
  }
}

# Derived volume
resource "libvirt_volume" "derived" {
  name     = "derived.qcow2"
  pool     = "default"
  capacity = 21474836480
  target = {
    format = { type = "qcow2" }
  }
  backing_store = {
    path = libvirt_volume.base.id
    format = { type = "qcow2" }
  }
}
```

### VM Configuration
```hcl
resource "libvirt_domain" "vm" {
  name   = "vm"
  memory = 1024
  vcpu   = 1
  type   = "kvm"
  
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc"
  }
  
  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]
    
    interfaces = [{
      network = {
        network_name = "default"
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]
    
    console = [{  # MUST be inside devices as array
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}
```

## Next Steps

1. ✅ All assets created and validated
2. ✅ All setup scripts updated
3. ⏳ User to push changes to Instruqt
4. ⏳ Run `instruqt track test` to verify
5. ⏳ Fix any remaining issues
6. ⏳ Verify all challenges pass

## Files Modified

### Assets Created (New)
- `assets/challenge-03/` (6 files)
- `assets/challenge-04/` (2 files)
- `assets/challenge-05/` (4 files)

### Setup Scripts Updated
- `03-infrastructure-resources/setup-workstation` (already using assets)
- `04-state-management-cli/setup-workstation` (updated)
- `05-skills-assessment/setup-workstation` (updated)

## Total Impact

- **Lines of Code Reduced:** ~1,000+ lines across 3 setup scripts
- **Files Created:** 12 new asset files
- **Validation Status:** All configurations validated successfully
- **Maintainability:** Significantly improved
- **Testing:** Much easier with real files

---

## Phase 20: GitHub-Based Assets Distribution

### Problem Discovered
Instruqt's assets feature only supports markdown files for documentation, not arbitrary file distribution. The `/tmp/assets/` approach would not work for distributing Terraform configuration files.

### Solution Implemented
Switched to GitHub-based distribution:

1. **Track-Level Setup**: Clone public GitHub repository once at track start
2. **Challenge Setup**: Copy files from cloned repo to working directories
3. **Repository Structure**: Maintain assets in version control

### Changes Made

#### Track-Level Setup Script
**File**: `track_scripts/setup-workstation`

Added repository cloning:
```bash
# Clone the lab assets repository
REPO_URL="https://github.com/YOUR_USERNAME/iac-bootcamp.git"
ASSETS_DIR="/root/lab-assets"

if [ ! -d "$ASSETS_DIR" ]; then
    git clone "$REPO_URL" "$ASSETS_DIR"
    echo "✓ Lab assets cloned successfully"
fi
```

#### Challenge Setup Scripts Updated
All 5 challenge setup scripts updated to use GitHub repo path:

**Before**: `cp -r /tmp/assets/challenge-XX/*`
**After**: `cp -r /root/lab-assets/tf-100-fundamentals-lab/assets/challenge-XX/*`

**Files Modified**:
- `01-intro-to-iac-and-terraform/setup-workstation`
- `02-variables-loops-functions/setup-workstation`
- `03-infrastructure-resources/setup-workstation`
- `04-state-management-cli/setup-workstation`
- `05-skills-assessment/setup-workstation`

### Benefits

1. **Version Control**: All assets in Git
2. **Easy Updates**: Update GitHub, changes propagate automatically
3. **Maintainability**: Real files with IDE support
4. **Testability**: Validate before deployment
5. **Transparency**: Students can view solutions on GitHub

### Requirements

- Repository must be **public** (no authentication in Instruqt VM)
- Repository URL must be updated in `track_scripts/setup-workstation`
- Directory structure must match: `instruqt/iac-bootcamp/tf-100-fundamentals-lab/assets/challenge-XX/`

### Documentation Created

**New File**: `GITHUB_ASSETS_SETUP.md`
- Complete architecture documentation
- Setup process explanation
- Troubleshooting guide
- Security considerations
- Deployment checklist

### TODO Before Deployment

1. ✅ Update all setup scripts to use GitHub paths
2. ✅ Create comprehensive documentation
3. ⏳ Update REPO_URL in track_scripts/setup-workstation
4. ⏳ Make repository public on GitHub
5. ⏳ Test git clone without authentication
6. ⏳ Run `instruqt track test` to verify

---

**Completed:** Phase 20 - GitHub-Based Assets Distribution
**Status:** ✅ Ready for deployment (after updating REPO_URL and making repo public)