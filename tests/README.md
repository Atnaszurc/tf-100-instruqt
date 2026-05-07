# TF-100 Lab Testing Scripts

This directory contains local testing scripts for the TF-100 Fundamentals Lab.

## Available Scripts

### validate-track.sh
Comprehensive validation script that checks:
- Required files exist
- YAML syntax is valid
- Shell scripts have valid syntax
- Challenge structure is correct
- Markdown files are valid
- Common issues (fail-message calls, set -e, shebangs)
- Instruqt CLI validation (if available)

**Usage:**
```bash
./validate-track.sh
```

**Run before:**
- Committing changes
- Pushing to repository
- Creating pull requests

### test-challenge.sh
Test a specific challenge's scripts and structure.

**Usage:**
```bash
./test-challenge.sh <challenge-number>

# Examples:
./test-challenge.sh 01  # Test challenge 1
./test-challenge.sh 05  # Test challenge 5
```

**What it checks:**
- Script syntax validation
- Required files exist (assignment.md, setup-workstation, check-workstation)
- Scripts are executable

## Prerequisites

### Required Tools
- `bash` - Shell interpreter
- `find` - File search utility

### Optional Tools (for enhanced validation)
- `yamllint` - YAML syntax validation
  ```bash
  pip install yamllint
  ```

- `shellcheck` - Shell script linting
  ```bash
  # Ubuntu/Debian
  sudo apt-get install shellcheck
  
  # macOS
  brew install shellcheck
  ```

- `markdownlint` - Markdown linting
  ```bash
  npm install -g markdownlint-cli
  ```

- `instruqt` - Instruqt CLI
  ```bash
  curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
  chmod +x /usr/local/bin/instruqt
  ```

## CI/CD Integration

These scripts are also used in the GitHub Actions workflow (`.github/workflows/tf-100-test.yml`) for automated testing on:
- Push to main/develop branches
- Pull requests
- Manual workflow dispatch

## Testing Workflow

### Before Committing
```bash
# 1. Validate track
./tests/validate-track.sh

# 2. Test specific challenges you modified
./tests/test-challenge.sh 01
./tests/test-challenge.sh 02

# 3. If all pass, commit
git add .
git commit -m "Your commit message"
```

### Before Pushing
```bash
# Run full validation
./tests/validate-track.sh

# If using Instruqt CLI, test the track
cd ..
instruqt track test
```

### In CI/CD
The GitHub Actions workflow automatically:
1. Validates all YAML and scripts
2. Tests each challenge in parallel
3. Runs integration tests (on PRs)
4. Deploys to dev/prod (on branch push)

## Exit Codes

All scripts follow standard exit code conventions:
- `0` - Success, all tests passed
- `1` - Failure, one or more tests failed

## Output Format

Scripts use color-coded output:
- 🟢 Green ✅ - Success
- 🔴 Red ❌ - Error
- 🟡 Yellow ⚠️  - Warning
- 🔵 Blue 📝 - Information

## Troubleshooting

### "Command not found" errors
Install the missing tool (see Prerequisites above).

### "Permission denied" errors
Make scripts executable:
```bash
chmod +x tests/*.sh
```

### Validation fails but scripts look correct
- Check for hidden characters or encoding issues
- Ensure line endings are Unix-style (LF, not CRLF)
- Run `dos2unix` if needed

## Contributing

When adding new tests:
1. Follow existing script patterns
2. Use color-coded output
3. Provide clear error messages
4. Update this README
5. Test locally before committing

## Resources

- [Instruqt CLI Documentation](https://docs.instruqt.com/reference/cli)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [YAML Lint](https://yamllint.readthedocs.io/)
- [Markdown Lint](https://github.com/DavidAnson/markdownlint)