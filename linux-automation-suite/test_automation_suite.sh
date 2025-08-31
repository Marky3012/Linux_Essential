#!/bin/bash
# Test Script for Linux Automation Suite
# Description: Verifies the functionality of all automation scripts
# Author: Linux Automation Suite
# Version: 1.1.0

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0
SKIPPED=0

# Create a temporary directory for test output
TEST_TEMP_DIR="/tmp/automation_test_$(date +%s)"
mkdir -p "$TEST_TEMP_DIR"

# Function to clean up temporary files
cleanup() {
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Register cleanup on exit
trap cleanup EXIT

echo -e "${YELLOW}=== Linux Automation Suite Test Runner ===${NC}"
echo "Starting tests at $(date)"
echo "System: $(uname -a)"
echo "Current directory: $(pwd)"
echo "----------------------------------------"

# Function to run a test with detailed output
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    local output_file="${TEST_TEMP_DIR}/${test_name// /_}.log"
    
    echo -e "\n${BLUE}[TEST] ${test_name}${NC}"
    echo "  Command: ${test_cmd}"
    
    set +e
    eval "$test_cmd" > "$output_file" 2>&1
    local exit_code=$?
    set -e
    
    if [ $exit_code -eq 0 ]; then
        echo -e "  Status: ${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "  Status: ${RED}FAIL (exit code: $exit_code)${NC}"
        echo -e "  Output (last 5 lines):"
        tail -n 5 "$output_file" | sed 's/^/    /'
        echo -e "  Full output: ${BLUE}${output_file}${NC}"
        ((FAILED++))
        return 1
    fi
}

# Function to skip a test
skip_test() {
    local test_name="$1"
    local reason="$2"
    
    echo -e "${YELLOW}[SKIP] ${test_name} - ${reason}${NC}"
    ((SKIPPED++))
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Warning: Some tests require root privileges${NC}"
fi

# Test 1: Check for required dependencies
run_test "Checking for bash" "bash --version"
run_test "Checking for git" "git --version"

# Test 2: Validate script syntax
run_test "Validating bootstrap.sh syntax" "bash -n scripts/core/bootstrap.sh"
run_test "Validating dev_setup.sh syntax" "bash -n scripts/core/dev_setup.sh"
run_test "Validating security_hardening.sh syntax" "bash -n scripts/core/security_hardening.sh"
run_test "Validating system_optimizer.sh syntax" "bash -n scripts/performance/system_optimizer.sh"
run_test "Validating service_manager.sh syntax" "bash -n scripts/performance/service_manager.sh"
run_test "Validating system_monitor.sh syntax" "bash -n scripts/monitoring/system_monitor.sh"
run_test "Validating dotfiles_manager.sh syntax" "bash -n scripts/user/dotfiles_manager.sh"

# Test 3: Check YAML configuration files
run_test "Validating bootstrap.yaml" "yq e '.version' config/bootstrap.yaml" || \
    skip_test "Validating bootstrap.yaml" "yq not installed"

# Test 4: Test dotfiles manager (safe mode)
run_test "Testing dotfiles manager help" "scripts/user/dotfiles_manager.sh help"

# Test 5: Test service manager help
run_test "Testing service manager help" "scripts/performance/service_manager.sh help"

# Test 6: Test system monitor help
run_test "Testing system monitor help" "scripts/monitoring/system_monitor.sh help"

# Print summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}"
echo -e "Total: $((PASSED + FAILED + SKIPPED))"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"
echo -e "${YELLOW}Skipped: ${SKIPPED}${NC}"

# Exit with non-zero status if any tests failed
if [ "$FAILED" -gt 0 ]; then
    echo -e "\n${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
else
    echo -e "\n${GREEN}All tests completed successfully!${NC}"
    exit 0
fi
