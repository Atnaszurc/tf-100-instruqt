# Challenge 3 Solution: Infrastructure Resources

Complete 3-tier infrastructure with networks, storage, and VMs.

## Files

- `main.tf` - Provider configuration
- `network.tf` - Network resources and outputs
- `storage.tf` - Storage pools, volumes, and outputs
- `vms.tf` - Virtual machine definitions
- `outputs.tf` - Infrastructure outputs

## Usage

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Architecture

- **Network**: Custom NAT network with DHCP
- **Storage**: Base volume + 3 derived volumes (web, app, db)
- **VMs**: 3 virtual machines (web-server, app-server, db-server)

## Notes

- VMs use Ubuntu 22.04 cloud images
- VMs may not auto-start without cloud-init configuration
- All VMs are connected to the custom network
- Storage uses efficient base + derived volume pattern