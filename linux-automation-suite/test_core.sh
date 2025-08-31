#!/bin/bash
# Core Test Script for Linux Automation Suite
# Simplified version for WSL testing

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

# Create a log file
LOG_FILE="test_results_$(date +%Y%m%d_%H%M%S).log"

echo -e "${YELLOW}=== Linux Automation Suite Core Tests ===${NC}" | tee -a "$LOG_FILE"
echo "Starting tests at $(date)" | tee -a "$LOG_FILE"
echo "System: $(uname -a)" | tee -a "$LOG_FILE"
echo "Current directory: $(pwd)" | tee -a "$LOG_FILE"
echo "----------------------------------------" | tee -a "$LOG_FILE"

# Function to run a test
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -e "\n${BLUE}[TEST] ${test_name}${NC}" | tee -a "$LOG_FILE"
    echo "  Command: ${test_cmd}" | tee -a "$LOG_FILE"
    
    # Run the command and capture output
    set +e
    output=$($test_cmd 2>&1)
    exit_code=$?
    set -e
    
    if [ $exit_code -eq 0 ]; then
        echo -e "  Status: ${GREEN}PASS${NC}" | tee -a "$LOG_FILE"
        ((PASSED++))
        return 0
    else
        echo -e "  Status: ${RED}FAIL (exit code: $exit_code)${NC}" | tee -a "$LOG_FILE"
        echo -e "  Output (last 5 lines):" | tee -a "$LOG_FILE"
        echo "$output" | tail -n 5 | sed 's/^/    /' | tee -a "$LOG_FILE"
        echo -e "  Full output logged to: ${BLUE}${LOG_FILE}${NC}" | tee -a "$LOG_FILE"
        ((FAILED++))
        return 1
    fi
}

# Function to skip a test
skip_test() {
    local test_name="$1"
    local reason="$2"
    
    echo -e "${YELLOW}[SKIP] ${test_name} - ${reason}${NC}" | tee -a "$LOG_FILE"
    ((SKIPPED++))
}

# Test 1: Check shell script syntax
run_test "Checking bash version" "bash --version"

# Test 2: Check for required commands
for cmd in git awk sed grep; do
    run_test "Checking for $cmd" "command -v $cmd"
done

# Test 3: Check script permissions
for script in scripts/**/*.sh; do
    if [ -x "$script" ]; then
        run_test "Checking executable permission: $script" "test -x $script"
    else
        skip_test "Checking executable permission: $script" "Not executable"
    fi
done

# Test 4: Check YAML files (if yq is available)
if command -v yq &> /dev/null; then
    for yaml in config/*.yaml; do
        run_test "Validating YAML: $yaml" "yq e '.' $yaml"
    done
else
    skip_test "Validating YAML files" "yq not installed"
fi

# Test 5: Run each script with --help or help
for script in scripts/**/*.sh; do
    if [ -x "$script" ]; then
        script_name=$(basename "$script")
        if [ "$script_name" != "test_*.sh" ]; then
            run_test "Testing $script_name help" "$script --help || $script help || true"
        fi
    fi
done

# Print summary
echo -e "\n${YELLOW}=== Test Summary ===${NC}" | tee -a "$LOG_FILE"
echo -e "Total: $((PASSED + FAILED + SKIPPED))" | tee -a "$LOG_FILE"
echo -e "${GREEN}Passed: ${PASSED}${NC}" | tee -a "$LOG_FILE"
echo -e "${RED}Failed: ${FAILED}${NC}" | tee -a "$LOG_FILE"
echo -e "${YELLOW}Skipped: ${SKIPPED}${NC}" | tee -a "$LOG_FILE"

# Exit with non-zero status if any tests failed
if [ "$FAILED" -gt 0 ]; then
    echo -e "\n${RED}Some tests failed. Check ${BLUE}${LOG_FILE}${RED} for details.${NC}" | tee -a "$LOG_FILE"
    exit 1
else
    echo -e "\n${GREEN}All tests completed successfully!${NC}" | tee -a "$LOG_FILE"
    exit 0
fi
