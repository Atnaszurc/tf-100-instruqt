#!/bin/bash
# Test a specific challenge locally
# Usage: ./test-challenge.sh [challenge-number]
# Example: ./test-challenge.sh 01

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACK_DIR="$(dirname "$SCRIPT_DIR")"
CHALLENGE_NUM="$1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$CHALLENGE_NUM" ]; then
    echo "Usage: $0 <challenge-number>"
    echo "Example: $0 01"
    echo ""
    echo "Available challenges:"
    cd "$TRACK_DIR"
    find . -maxdepth 1 -type d -name "[0-9][0-9]-*" | sort | sed 's|./||'
    exit 1
fi

cd "$TRACK_DIR"

# Find challenge directory
CHALLENGE_DIR=$(find . -maxdepth 1 -type d -name "${CHALLENGE_NUM}-*" | head -1)

if [ -z "$CHALLENGE_DIR" ]; then
    echo -e "${RED}❌ Challenge $CHALLENGE_NUM not found${NC}"
    exit 1
fi

CHALLENGE_NAME=$(basename "$CHALLENGE_DIR")

echo "==================================="
echo "Testing Challenge: $CHALLENGE_NAME"
echo "==================================="
echo ""

echo -e "${BLUE}📝 Challenge: $CHALLENGE_NAME${NC}"
echo ""

# 1. Validate scripts
echo "1. Validating scripts..."
if [ -f "$CHALLENGE_DIR/setup-workstation" ]; then
    if bash -n "$CHALLENGE_DIR/setup-workstation"; then
        echo -e "${GREEN}✅ setup-workstation syntax valid${NC}"
    else
        echo -e "${RED}❌ setup-workstation syntax invalid${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  No setup-workstation script${NC}"
fi

if [ -f "$CHALLENGE_DIR/check-workstation" ]; then
    if bash -n "$CHALLENGE_DIR/check-workstation"; then
        echo -e "${GREEN}✅ check-workstation syntax valid${NC}"
    else
        echo -e "${RED}❌ check-workstation syntax invalid${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ No check-workstation script${NC}"
    exit 1
fi

if [ -f "$CHALLENGE_DIR/assignment.md" ]; then
    echo -e "${GREEN}✅ assignment.md exists${NC}"
else
    echo -e "${RED}❌ assignment.md missing${NC}"
    exit 1
fi
echo ""

echo -e "${GREEN}✅ Challenge $CHALLENGE_NAME validation passed${NC}"
