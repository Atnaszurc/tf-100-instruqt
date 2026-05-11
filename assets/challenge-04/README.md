# Challenge 4 Solution: State Management & CLI

State management and CLI practice configuration.

## Key Commands

### State Inspection
```bash
terraform state list
terraform state show libvirt_domain.vm
terraform show
terraform show -json
```

### Workspaces
```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
terraform workspace show
```

### State Modification
```bash
# Always backup first!
terraform state pull > backup.tfstate

# Move resource
terraform state mv old new

# Remove resource
terraform state rm resource
```

### Console
```bash
terraform console
> terraform.workspace
> libvirt_domain.vm.name
> exit
```

### Debugging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan
```

## Workspace Behavior

The configuration uses `terraform.workspace` to:
- Name resources: `${terraform.workspace}-vm`
- Adjust specs: prod gets more memory/CPU

## Practice Exercises

1. Create and switch between workspaces
2. Inspect state in different workspaces
3. Use console to explore data
4. Practice state modification commands
5. Enable debug logging