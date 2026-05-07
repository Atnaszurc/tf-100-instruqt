# Instruqt Lab Testing Guide

This guide covers how to test Instruqt tracks locally and set up automated CI/CD testing.

---

## Table of Contents

1. [Instruqt CLI Testing](#instruqt-cli-testing)
2. [Local Testing Strategy](#local-testing-strategy)
3. [CI/CD Integration](#cicd-integration)
4. [Test Automation](#test-automation)
5. [Manual Testing Checklist](#manual-testing-checklist)

---

## Instruqt CLI Testing

### Installation

```bash
# Install Instruqt CLI
curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
chmod +x /usr/local/bin/instruqt

# Or on macOS
brew install instruqt/tap/instruqt

# Verify installation
instruqt version
```

### Authentication

```bash
# Login to Instruqt
instruqt auth login

# Or use API token
export INSTRUQT_TOKEN="your-api-token"
```

### Track Validation

```bash
# Validate track configuration
cd instruqt/iac-bootcamp/tf-100-fundamentals-lab
instruqt track validate

# This checks:
# - track.yml syntax
# - config.yml syntax
# - Challenge structure
# - Script syntax
# - File references
```

### Track Testing

```bash
# Test track locally (requires Docker)
instruqt track test

# Test specific challenge
instruqt track test --challenge 01-intro-to-iac-and-terraform

# Test with specific image
instruqt track test --image ubuntu2204
```

### Track Push and Deployment

```bash
# Push track to Instruqt
instruqt track push

# Push to specific organization
instruqt track push --organization your-org

# Push and tag version
instruqt track push --tag v1.0.0
```

---

## Local Testing Strategy

### Phase 1: Static Validation

**Test configuration files:**
```bash
#!/bin/bash
# test-static.sh

echo "=== Static Validation ==="

# Check YAML syntax
echo "Checking track.yml..."
yamllint track.yml || exit 1

echo "Checking config.yml..."
yamllint config.yml || exit 1

# Validate with Instruqt CLI
echo "Validating track structure..."
instruqt track validate || exit 1

echo "✅ Static validation passed"
```

### Phase 2: Script Validation

**Test all setup and check scripts:**
```bash
#!/bin/bash
# test-scripts.sh

echo "=== Script Validation ==="

# Check bash syntax for all scripts
for script in track_scripts/* */setup-* */check-*; do
    if [ -f "$script" ]; then
        echo "Checking $script..."
        bash -n "$script" || exit 1
    fi
done

# Check for common issues
echo "Checking for common script issues..."
grep -r "fail-message" . --include="check-*" > /dev/null || {
    echo "⚠️  Warning: No fail-message calls found in check scripts"
}

echo "✅ Script validation passed"
```

### Phase 3: Content Validation

**Test markdown and documentation:**
```bash
#!/bin/bash
# test-content.sh

echo "=== Content Validation ==="

# Check markdown syntax
for md in */assignment.md *.md; do
    if [ -f "$md" ]; then
        echo "Checking $md..."
        markdownlint "$md" || exit 1
    fi
done

# Check for broken links
echo "Checking for broken links..."
find . -name "*.md" -exec markdown-link-check {} \;

echo "✅ Content validation passed"
```

### Phase 4: Integration Testing

**Test complete track flow:**
```bash
#!/bin/bash
# test-integration.sh

echo "=== Integration Testing ==="

# This requires Instruqt CLI and Docker
instruqt track test --skip-fail-check

echo "✅ Integration testing passed"
```

---

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/instruqt-test.yml`:

```yaml
name: Instruqt Track Testing

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'instruqt/iac-bootcamp/tf-100-fundamentals-lab/**'
  pull_request:
    branches: [ main ]
    paths:
      - 'instruqt/iac-bootcamp/tf-100-fundamentals-lab/**'

jobs:
  validate:
    name: Validate Track
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install Instruqt CLI
        run: |
          curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
          chmod +x /usr/local/bin/instruqt
          instruqt version
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y yamllint shellcheck
          npm install -g markdownlint-cli markdown-link-check
      
      - name: Validate YAML files
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        run: |
          yamllint track.yml
          yamllint config.yml
      
      - name: Validate Markdown files
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        run: |
          markdownlint '**/*.md' --ignore node_modules
      
      - name: Validate shell scripts
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        run: |
          find . -name "setup-*" -o -name "check-*" | while read script; do
            echo "Checking $script"
            shellcheck "$script" || bash -n "$script"
          done
      
      - name: Validate track structure
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        env:
          INSTRUQT_TOKEN: ${{ secrets.INSTRUQT_TOKEN }}
        run: |
          instruqt track validate

  test:
    name: Test Track
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install Instruqt CLI
        run: |
          curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
          chmod +x /usr/local/bin/instruqt
      
      - name: Test track
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        env:
          INSTRUQT_TOKEN: ${{ secrets.INSTRUQT_TOKEN }}
        run: |
          # Test track (requires Docker)
          instruqt track test --skip-fail-check
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: instruqt/iac-bootcamp/tf-100-fundamentals-lab/test-results/

  deploy-dev:
    name: Deploy to Development
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/develop'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install Instruqt CLI
        run: |
          curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
          chmod +x /usr/local/bin/instruqt
      
      - name: Push to Instruqt (dev)
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        env:
          INSTRUQT_TOKEN: ${{ secrets.INSTRUQT_TOKEN }}
        run: |
          instruqt track push --tag dev-${{ github.sha }}

  deploy-prod:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install Instruqt CLI
        run: |
          curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
          chmod +x /usr/local/bin/instruqt
      
      - name: Push to Instruqt (prod)
        working-directory: instruqt/iac-bootcamp/tf-100-fundamentals-lab
        env:
          INSTRUQT_TOKEN: ${{ secrets.INSTRUQT_TOKEN }}
        run: |
          instruqt track push --tag v${{ github.run_number }}
      
      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: tf-100-v${{ github.run_number }}
          release_name: TF-100 Lab v${{ github.run_number }}
          body: |
            Automated release of TF-100 Fundamentals Lab
            
            Changes: ${{ github.event.head_commit.message }}
```

### GitLab CI/CD

Create `.gitlab-ci.yml`:

```yaml
stages:
  - validate
  - test
  - deploy

variables:
  TRACK_PATH: instruqt/iac-bootcamp/tf-100-fundamentals-lab

before_script:
  - curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt
  - chmod +x /usr/local/bin/instruqt

validate:
  stage: validate
  image: ubuntu:22.04
  script:
    - apt-get update && apt-get install -y yamllint shellcheck
    - cd $TRACK_PATH
    - yamllint track.yml config.yml
    - find . -name "setup-*" -o -name "check-*" | xargs shellcheck
    - instruqt track validate
  only:
    changes:
      - instruqt/iac-bootcamp/tf-100-fundamentals-lab/**/*

test:
  stage: test
  image: ubuntu:22.04
  services:
    - docker:dind
  script:
    - cd $TRACK_PATH
    - instruqt track test --skip-fail-check
  only:
    - merge_requests
  artifacts:
    paths:
      - $TRACK_PATH/test-results/
    expire_in: 1 week

deploy:dev:
  stage: deploy
  script:
    - cd $TRACK_PATH
    - instruqt track push --tag dev-$CI_COMMIT_SHORT_SHA
  only:
    - develop

deploy:prod:
  stage: deploy
  script:
    - cd $TRACK_PATH
    - instruqt track push --tag v$CI_PIPELINE_ID
  only:
    - main
```

---

## Test Automation

### Automated Challenge Testing

Create `tests/run-all-challenges.sh`:

```bash
#!/bin/bash
# Automated test runner for all challenges

set -e

TRACK_DIR="instruqt/iac-bootcamp/tf-100-fundamentals-lab"
RESULTS_DIR="test-results"

mkdir -p "$RESULTS_DIR"

echo "=== Starting Automated Challenge Testing ==="
echo "Track: $TRACK_DIR"
echo "Results: $RESULTS_DIR"
echo ""

# Test each challenge
for challenge_dir in "$TRACK_DIR"/[0-9]*; do
    challenge_name=$(basename "$challenge_dir")
    echo "Testing Challenge: $challenge_name"
    
    # Run setup script
    if [ -f "$challenge_dir/setup-workstation" ]; then
        echo "  Running setup..."
        bash "$challenge_dir/setup-workstation" > "$RESULTS_DIR/${challenge_name}-setup.log" 2>&1
        if [ $? -eq 0 ]; then
            echo "  ✅ Setup passed"
        else
            echo "  ❌ Setup failed"
            cat "$RESULTS_DIR/${challenge_name}-setup.log"
            exit 1
        fi
    fi
    
    # Run check script
    if [ -f "$challenge_dir/check-workstation" ]; then
        echo "  Running checks..."
        bash "$challenge_dir/check-workstation" > "$RESULTS_DIR/${challenge_name}-check.log" 2>&1
        if [ $? -eq 0 ]; then
            echo "  ✅ Checks passed"
        else
            echo "  ❌ Checks failed"
            cat "$RESULTS_DIR/${challenge_name}-check.log"
            exit 1
        fi
    fi
    
    echo ""
done

echo "=== All Challenges Passed ==="
```

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Pre-commit hook for Instruqt tracks

TRACK_DIR="instruqt/iac-bootcamp/tf-100-fundamentals-lab"

# Check if track files are being committed
if git diff --cached --name-only | grep -q "^$TRACK_DIR/"; then
    echo "Validating Instruqt track..."
    
    cd "$TRACK_DIR"
    
    # Validate track
    if ! instruqt track validate; then
        echo "❌ Track validation failed"
        exit 1
    fi
    
    # Check shell scripts
    for script in track_scripts/* */setup-* */check-*; do
        if [ -f "$script" ]; then
            if ! bash -n "$script"; then
                echo "❌ Script validation failed: $script"
                exit 1
            fi
        fi
    done
    
    echo "✅ Track validation passed"
fi
```

---

## Manual Testing Checklist

### Pre-Deployment Testing

**Track Configuration:**
- [ ] `track.yml` is valid YAML
- [ ] All challenges are listed in correct order
- [ ] Timeout and skip settings are appropriate
- [ ] Track slug is unique and descriptive

**Challenge Configuration:**
- [ ] Each challenge has `assignment.md`
- [ ] Each challenge has `setup-workstation` script
- [ ] Each challenge has `check-workstation` script
- [ ] Assignment markdown renders correctly
- [ ] All code blocks have proper syntax highlighting

**Scripts:**
- [ ] All scripts have proper shebang (`#!/bin/bash`)
- [ ] All scripts are executable
- [ ] Setup scripts create necessary files/directories
- [ ] Check scripts validate all requirements
- [ ] Error messages are clear and helpful
- [ ] Scripts handle edge cases

### Challenge-by-Challenge Testing

**For Each Challenge:**

1. **Setup Phase:**
   - [ ] Run setup script manually
   - [ ] Verify all files are created
   - [ ] Check file permissions
   - [ ] Verify example solutions work

2. **Learning Phase:**
   - [ ] Read through assignment
   - [ ] Follow instructions step-by-step
   - [ ] Test all commands provided
   - [ ] Verify all examples work

3. **Validation Phase:**
   - [ ] Run check script
   - [ ] Verify all checks pass
   - [ ] Test with intentional errors
   - [ ] Verify error messages are helpful

4. **Transition Phase:**
   - [ ] Move to next challenge
   - [ ] Verify state persists
   - [ ] Check no conflicts with previous work

### End-to-End Testing

**Complete Lab Flow:**
- [ ] Start from Challenge 1
- [ ] Complete all challenges in order
- [ ] Verify skip functionality works
- [ ] Test timeout behavior
- [ ] Verify final assessment scoring
- [ ] Check completion certificate

**Performance Testing:**
- [ ] Track loads within 2 minutes
- [ ] Challenges transition instantly
- [ ] VMs boot within 3 minutes
- [ ] No resource exhaustion
- [ ] Track completes within 9 hours

**User Experience:**
- [ ] Instructions are clear
- [ ] Examples are accurate
- [ ] Error messages are helpful
- [ ] Documentation is accessible
- [ ] Navigation is intuitive

---

## Continuous Testing Strategy

### Daily Automated Tests

```bash
# Cron job: Run daily at 2 AM
0 2 * * * /path/to/test-track.sh

# test-track.sh
#!/bin/bash
cd /path/to/repo
git pull
cd instruqt/iac-bootcamp/tf-100-fundamentals-lab
instruqt track validate
instruqt track test --skip-fail-check
```

### Weekly Full Tests

```bash
# Cron job: Run weekly on Sunday at 3 AM
0 3 * * 0 /path/to/full-test.sh

# full-test.sh
#!/bin/bash
cd /path/to/repo
git pull
./tests/run-all-challenges.sh
# Send results via email or Slack
```

### On-Demand Testing

```bash
# Manual test script
./test-track.sh [challenge-number]

# Examples:
./test-track.sh              # Test all
./test-track.sh 01           # Test challenge 1
./test-track.sh 01 02 03     # Test challenges 1-3
```

---

## Monitoring and Alerts

### Track Usage Monitoring

```bash
# Get track statistics
instruqt track stats --track tf-100-terraform-fundamentals

# Monitor completion rates
instruqt track analytics --track tf-100-terraform-fundamentals
```

### Alert Configuration

**Set up alerts for:**
- Track validation failures
- High failure rates on specific challenges
- Performance degradation
- User feedback/issues

---

## Best Practices

1. **Test Before Push**: Always validate locally before pushing
2. **Automate Everything**: Use CI/CD for all testing
3. **Version Control**: Tag releases for rollback capability
4. **Monitor Usage**: Track completion rates and user feedback
5. **Iterate Quickly**: Fix issues promptly based on data
6. **Document Changes**: Keep changelog updated
7. **Test Edge Cases**: Don't just test happy path
8. **User Testing**: Have real users test before release

---

## Troubleshooting

### Common Issues

**Track validation fails:**
```bash
# Check YAML syntax
yamllint track.yml config.yml

# Check for missing files
instruqt track validate --verbose
```

**Scripts fail in testing:**
```bash
# Test script syntax
bash -n script-name

# Run with debug output
bash -x script-name
```

**Track test hangs:**
```bash
# Check Docker resources
docker system df
docker system prune

# Increase timeout
instruqt track test --timeout 30m
```

---

## Resources

- [Instruqt CLI Documentation](https://docs.instruqt.com/reference/cli)
- [Instruqt API Reference](https://docs.instruqt.com/reference/api)
- [Track Development Guide](https://docs.instruqt.com/tracks)
- [Testing Best Practices](https://docs.instruqt.com/best-practices/testing)

---

**Remember: Good testing prevents bad user experiences!** 🧪