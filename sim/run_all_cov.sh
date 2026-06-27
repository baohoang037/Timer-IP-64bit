#!/bin/bash
# Run all testcases in coverage mode then generate report
# Usage: bash run_all_cov.sh
cd "$(dirname "$0")"
TESTS=$(cat pat.list)
for t in $TESTS; do
    echo "=== Running: $t ==="
    make TESTNAME=$t all_cov
done
make gen_cov
echo "=== Coverage report generated in coverage/ ==="
