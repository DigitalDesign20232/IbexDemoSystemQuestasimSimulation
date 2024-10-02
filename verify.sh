#!/bin/bash

test_dir="result_test"
ref_dir="result_ref"

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print table header
printf "%-20s %-10s\n" "File Name" "Status"
echo "----------------------------------------"

for test_file in $test_dir/*.mem; do
    # Get the corresponding reference file
    ref_file="$ref_dir/$(basename $test_file)"

    # Check if the reference file exists
    if [ ! -f "$ref_file" ]; then
        echo -e "${RED}Reference file $ref_file not found.${NC}"
        continue
    fi

    # Compare the test and reference files
    diff_output=$(diff $test_file $ref_file)

    if [ -z "$diff_output" ]; then
        printf "%-20s ${GREEN}%-10s${NC}\n" "$(basename $test_file)" "PASS"
    else
        diff_file="$test_dir/$(basename $test_file .mem).diff"
        echo "$diff_output" > $diff_file
        printf "%-20s ${RED}%-10s${NC}\n" "$(basename $test_file)" "FAIL"
    fi
done
