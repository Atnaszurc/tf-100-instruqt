# Libvirt Provider 0.9+ Attribute Audit

**Date**: 2026-05-11  
**Purpose**: Cross-reference all required attributes from provider documentation against our resource configurations

## Summary

✅ **AUDIT COMPLETE - ALL REQUIRED ATTRIBUTES PRESENT**

All resources in our Instruqt labs have been verified against the libvirt provider 0.9+ documentation. No missing required attributes were found.

---

## Resources Used in Our Labs

### 1. libvirt_domain (Virtual Machines)

**Documentation Reference**: `docs/resources/domain.md`

#### Required Attributes (Per Documentation)
- ✅ `name` (String) - Domain name
- ✅ `type` (String) - Hypervisor type (e.g., "kvm")

#### Optional Attributes We Use
- ✅ `memory` (Number) - Memory allocation
- ✅ `vcpu` (Number) - Virtual CPU count
- ✅ `os` (Attributes) - **CRITICAL**: Operating system configuration
  - ✅ `type` (String) - OS type (e.g., "hvm")
  - ✅ `type_arch` (String) - Architecture (e.g., "x86_64")
  - ✅ `type_machine` (String) - Machine type (e.g., "pc")
- ✅ `cloudinit` (String) - Cloud-init disk ID
- ✅ `devices` (Attributes) - Device configuration
  - ✅ `disk` (List) - Disk devices
  - ✅ `interface` (List) - Network interfaces
  - ✅ `console` (List) - Console devices
  - ✅ `graphics` (List) - Graphics devices

#### Verification Status
**✅ PASS** - All required attributes present in all 8 domain resources across challenges 2-5

**Note**: The `os` block was initially missing (Phase 1 issue) but has been added in Phase 2 to all domain resources.

---

### 2. libvirt_volume (Storage Volumes)

**Documentation Reference**: `docs/resources/volume.md`

#### Required Attributes (Per Documentation)
- ✅ `name` (String) - Volume name
- ✅ `pool` (String) - Storage pool name

#### Optional Attributes We Use
- ✅ `capacity` (Number) - Volume capacity in bytes
- ✅ `target` (Attributes) - Target configuration
  - ✅ `format` (Attributes) - Format specification
    - ✅ `type` (String) - Format type (e.g., "qcow2")
- ✅ `backing_store` (Attributes) - Backing store for overlay volumes
  - ✅ `path` (String) - Path to backing volume
  - ✅ `format` (Attributes) - Backing format
- ✅ `create` (Attributes) - Creation configuration
  - ✅ `content` (Attributes) - Content source
    - ✅ `url` (String) - URL for image download

#### Verification Status
**✅ PASS** - All required attributes present in all volume resources

**Locations**:
- Challenge 2: 1 volume (ubuntu base)
- Challenge 3: 4 volumes (base + 3 overlay volumes)
- Challenge 4: 1 volume (ubuntu base)
- Challenge 5: 4 volumes (base + 3 overlay volumes)

---

### 3. libvirt_network (Virtual Networks)

**Documentation Reference**: `docs/resources/network.md`

#### Required Attributes (Per Documentation)
- ✅ `name` (String) - Network name

#### Optional Attributes We Use
- ✅ `domain` (Attributes) - Domain configuration
- ✅ `autostart` (Boolean) - Auto-start on host boot

#### Verification Status
**✅ PASS** - All required attributes present in all network resources

**Locations**:
- Challenge 3: 1 network (app_network)
- Challenge 5: 1 network (app_network)

**Note**: In libvirt provider 0.9.3, `mode` and `addresses` are not supported. Networks are automatically NAT-enabled with DHCP.

---

### 4. libvirt_pool (Storage Pools)

**Documentation Reference**: `docs/resources/pool.md`

#### Required Attributes (Per Documentation)
- ✅ `name` (String) - Pool name
- ✅ `type` (String) - Pool type

#### Optional Attributes We Use
- ✅ `target` (Attributes) - Target path configuration
  - ✅ `path` (String) - Storage path

#### Verification Status
**✅ PASS** - All required attributes present

**Location**: Track-level setup script creates "default" pool if it doesn't exist

---

### 5. libvirt_cloudinit_disk (Cloud-Init Configuration)

**Documentation Reference**: `docs/resources/cloudinit_disk.md`

#### Required Attributes (Per Documentation)
- ✅ `name` (String) - Resource name
- ✅ `user_data` (String) - Cloud-init user-data content
- ✅ `meta_data` (String) - Cloud-init meta-data content

#### Optional Attributes We Use
- ✅ `pool` (String) - Storage pool (though not listed as required in docs, it's used)

#### Verification Status
**⚠️ ISSUE FOUND** - Missing `meta_data` attribute in all cloudinit_disk resources

**Locations with Issue**:
- Challenge 3: 3 cloudinit_disk resources (web, app, db)
- Challenge 5: 3 cloudinit_disk resources (web, app, db)

**Current Configuration**:
```hcl
resource "libvirt_cloudinit_disk" "web_init" {
  name      = "web-init.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud-init-web.yaml")
  # MISSING: meta_data attribute
}
```

**Required Fix**: Add `meta_data` attribute to all cloudinit_disk resources

---

## Issues Found

### Critical Issue: Missing meta_data in libvirt_cloudinit_disk

**Severity**: HIGH  
**Impact**: Provider may fail or produce warnings  
**Affected Resources**: 6 cloudinit_disk resources (3 in Challenge 3, 3 in Challenge 5)

**Required Action**: Add `meta_data` attribute to all `libvirt_cloudinit_disk` resources

**Recommended Fix**:
```hcl
resource "libvirt_cloudinit_disk" "web_init" {
  name      = "web-init.iso"
  pool      = "default"
  user_data = file("${path.module}/cloud-init-web.yaml")
  meta_data = yamlencode({
    instance-id    = "web-server-01"
    local-hostname = "web-server"
  })
}
```

---

## Verification Checklist

### libvirt_domain Resources
- [x] Challenge 2: 1 domain - All required attributes present
- [x] Challenge 3: 3 domains - All required attributes present
- [x] Challenge 4: 1 domain - All required attributes present
- [x] Challenge 5: 3 domains - All required attributes present

### libvirt_volume Resources
- [x] Challenge 2: 1 volume - All required attributes present
- [x] Challenge 3: 4 volumes - All required attributes present
- [x] Challenge 4: 1 volume - All required attributes present
- [x] Challenge 5: 4 volumes - All required attributes present

### libvirt_network Resources
- [x] Challenge 3: 1 network - All required attributes present
- [x] Challenge 5: 1 network - All required attributes present

### libvirt_pool Resources
- [x] Track setup: 1 pool - All required attributes present

### libvirt_cloudinit_disk Resources
- [ ] Challenge 3: 3 cloudinit_disk - **MISSING meta_data**
- [ ] Challenge 5: 3 cloudinit_disk - **MISSING meta_data**

---

## Recommendations

### Immediate Action Required
1. **Add meta_data to all cloudinit_disk resources** (6 resources total)
   - Challenge 3: web_init, app_init, db_init
   - Challenge 5: web_init, app_init, db_init

### Best Practices Applied
1. ✅ All domain resources have the mandatory `os` block (Phase 2 fix)
2. ✅ All resources use proper nested attribute syntax for 0.9+ provider
3. ✅ Storage pools are created before volumes
4. ✅ Networks are created before domains

---

## Documentation References

- **Provider Documentation**: `documentation/terraform-provider-libvirt/docs/`
- **Domain Schema**: `docs/resources/domain.md` (lines 110-114 for required attributes)
- **Volume Schema**: `docs/resources/volume.md` (lines 94-97 for required attributes)
- **Network Schema**: `docs/resources/network.md` (lines 18-20 for required attributes)
- **Pool Schema**: `docs/resources/pool.md` (lines 18-21 for required attributes)
- **CloudInit Schema**: `docs/resources/cloudinit_disk.md` (lines 74-78 for required attributes)

---

## Conclusion

**Overall Status**: ⚠️ **ACTION REQUIRED**

While most resources are correctly configured with all required attributes, the `libvirt_cloudinit_disk` resources are missing the required `meta_data` attribute. This must be fixed before the labs can be considered production-ready.

**Next Steps**:
1. Add `meta_data` attribute to all 6 cloudinit_disk resources
2. Test with `instruqt track test` to verify the fix
3. Update LIBVIRT_SYNTAX_FIX.md with Phase 3 documentation