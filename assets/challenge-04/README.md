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
> libvirt_domain.vm.name
> exit
```

### Debugging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform plan
```

## Practice Exercises

1. Inspect state with various commands
2. Use console to explore data
3. Practice state modification commands
4. Enable debug logging
5. Understand state file structure