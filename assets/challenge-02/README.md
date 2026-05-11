# Challenge 2 Solution

This directory contains a complete working solution for Challenge 2.

## Files

- `variables.tf` - Variable definitions with validation
- `locals.tf` - Local values and computed configurations
- `main.tf` - Main infrastructure configuration
- `outputs.tf` - Output definitions
- `dev.tfvars` - Example variable file

## Usage

```bash
# Initialize
terraform init

# Plan with default values
terraform plan

# Apply with variable file
terraform apply -var-file="dev.tfvars"

# Experiment with different environments
terraform apply -var="environment=staging" -var="vm_count=3"

# Use terraform console to explore
terraform console
```

## Key Concepts Demonstrated

1. **Variables**: Input parameters with types and validation
2. **Locals**: Computed values and transformations
3. **for_each**: Creating multiple resources from a map
4. **for expressions**: List and map comprehensions
5. **Functions**: String formatting, merging, joining, etc.
6. **Outputs**: Exposing infrastructure information