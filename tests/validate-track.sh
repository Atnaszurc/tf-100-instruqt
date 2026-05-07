#!/bin/bash
# Local validation script for TF-100 track
# Run this before pushing changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACK_DIR="$(dirname "$SCRIPT_DIR")"

echo "==================================="
echo "TF-100 Track Validation"
echo "==================================="
echo ""

cd "$TRACK_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
ERRORS=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# 1. Check required files exist
echo "1. Checking required files..."
REQUIRED_FILES=(
    "track.yml"
    "config.yml"
    "README.md"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status 0 "Found $file"
    else
        print_status 1 "Missing $file"
    fi
done
echo ""

# 2. Validate YAML syntax
echo "2. Validating YAML files..."
if command -v yamllint &> /dev/null; then
    yamllint track.yml && print_status 0 "track.yml syntax valid" || print_status 1 "track.yml syntax invalid"
    yamllint config.yml && print_status 0 "config.yml syntax valid" || print_status 1 "config.yml syntax invalid"
else
    print_warning "yamllint not installed, skipping YAML validation"
fi
echo ""

# 3. Validate shell scripts
echo "3. Validating shell scripts..."
SCRIPT_COUNT=0
SCRIPT_ERRORS=0

for script in track_scripts/* */setup-* */check-*; do
    if [ -f "$script" ]; then
        SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
        if bash -n "$script" 2>/dev/null; then
            echo "  ✓ $script"
        else
            echo "  ✗ $script - syntax error"
            SCRIPT_ERRORS=$((SCRIPT_ERRORS + 1))
        fi
    fi
done

if [ $SCRIPT_ERRORS -eq 0 ]; then
    print_status 0 "All $SCRIPT_COUNT scripts have valid syntax"
else
    print_status 1 "$SCRIPT_ERRORS of $SCRIPT_COUNT scripts have syntax errors"
fi
echo ""

# 4. Check challenge structure
echo "4. Validating challenge structure..."
CHALLENGE_DIRS=($(find . -maxdepth 1 -type d -name "[0-9][0-9]-*" | sort))

if [ ${#CHALLENGE_DIRS[@]} -eq 0 ]; then
    print_status 1 "No challenge directories found"
else
    print_status 0 "Found ${#CHALLENGE_DIRS[@]} challenge directories"
    
    for challenge_dir in "${CHALLENGE_DIRS[@]}"; do
        challenge_name=$(basename "$challenge_dir")
        echo "  Checking $challenge_name..."
        
        # Check required files
        if [ -f "$challenge_dir/assignment.md" ]; then
            echo "    ✓ assignment.md"
        else
            echo "    ✗ assignment.md missing"
            ERRORS=$((ERRORS + 1))
        fi
        
        if [ -f "$challenge_dir/setup-workstation" ]; then
            echo "    ✓ setup-workstation"
        else
            echo "    ✗ setup-workstation missing"
            ERRORS=$((ERRORS + 1))
        fi
        
        if [ -f "$challenge_dir/check-workstation" ]; then
            echo "    ✓ check-workstation"
        else
            echo "    ✗ check-workstation missing"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi
echo ""

# 5. Validate markdown files
echo "5. Validating markdown files..."
if command -v markdownlint &> /dev/null; then
    MD_FILES=$(find . -name "*.md" -not -path "./node_modules/*")
    MD_COUNT=$(echo "$MD_FILES" | wc -l)
    
    if markdownlint $MD_FILES 2>/dev/null; then
        print_status 0 "All $MD_COUNT markdown files are valid"
    else
        print_warning "Some markdown files have style issues (non-critical)"
    fi
else
    print_warning "markdownlint not installed, skipping markdown validation"
fi
echo ""

# 6. Check for common issues
echo "6. Checking for common issues..."

# Check for fail-message in check scripts
FAIL_MESSAGE_COUNT=$(grep -r "fail-message" . --include="check-*" | wc -l)
if [ $FAIL_MESSAGE_COUNT -gt 0 ]; then
    print_status 0 "Found $FAIL_MESSAGE_COUNT fail-message calls in check scripts"
else
    print_warning "No fail-message calls found in check scripts"
fi

# Check for set -e in scripts
NO_SET_E=$(grep -L "set -e" track_scripts/* */setup-* */check-* 2>/dev/null | wc -l)
if [ $NO_SET_E -gt 0 ]; then
    print_warning "$NO_SET_E scripts missing 'set -e'"
fi

# Check for shebang in scripts
NO_SHEBANG=$(grep -L "^#!/bin/bash" track_scripts/* */setup-* */check-* 2>/dev/null | wc -l)
if [ $NO_SHEBANG -gt 0 ]; then
    print_warning "$NO_SHEBANG scripts missing shebang"
fi
echo ""

# 7. Validate with Instruqt CLI (if available)
echo "7. Validating with Instruqt CLI..."
if command -v instruqt &> /dev/null; then
    if instruqt track validate; then
        print_status 0 "Instruqt track validation passed"
    else
        print_status 1 "Instruqt track validation failed"
    fi
else
    print_warning "Instruqt CLI not installed, skipping track validation"
    echo "  Install: curl -L https://github.com/instruqt/cli/releases/latest/download/instruqt-linux -o /usr/local/bin/instruqt"
fi
echo ""

# Summary
echo "==================================="
echo "Validation Summary"
echo "==================================="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Track validation passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review any warnings above"
    echo "  2. Test locally: instruqt track test"
    echo "  3. Push changes: git push"
    exit 0
else
    echo -e "${RED}❌ Track validation failed with $ERRORS errors${NC}"
    echo ""
    echo "Please fix the errors above before pushing."
    exit 1
fi

# Made with Bob
