#!/usr/bin/env bash
# smoke_test.sh - quick smoke test for smart_recon.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
REPORT="$DIR/reports/smart_recon_report.md"
# ensure clean report
rm -f "$REPORT"
env DRY_RUN=1 "$DIR/smart_recon.sh" --target example.com --categories 1 --tools dig,host
# Run the script in dry-run CLI mode and ask it to summarize the report
env DRY_RUN=1 "$DIR/smart_recon.sh" --target example.com --categories 1 --tools dig,host --dry-run --summarize
# Basic checks
if ! grep -q "\[DRY_RUN\] dig example.com" "$REPORT"; then
    echo "FAIL: dig entry missing"; exit 1
fi
if ! grep -q "\[DRY_RUN\] host example.com" "$REPORT"; then
    echo "FAIL: host entry missing"; exit 1
fi
ENHANCED="$DIR/reports/enhanced_$(basename "$REPORT")"
if ! grep -q "## Automated Summary and Insights" "$ENHANCED"; then
    echo "FAIL: enhanced report missing summary section"; exit 1
fi
echo "Smoke test passed: report + enhanced summary present"
