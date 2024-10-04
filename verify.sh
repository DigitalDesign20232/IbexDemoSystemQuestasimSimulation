#!/bin/bash


test_dir="$1"
test_extension="$2"
ref_dir="$3"
ref_extension="$4"

# test_dir="result_test"
# test_extension="mem"
# ref_dir="result_ref"
# ref_extension="mem"

# test_dir="result_test"
# test_extension="signature"
# ref_dir="standard_ref/reference_output"
# ref_extension="reference_output"
# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print table header
printf "%-30s %-10s\n" "File Name" "Status"
echo "----------------------------------------"

for test_file in $test_dir/*.$test_extension; do
    # Get the corresponding reference file
    ref_file="$ref_dir/$(basename $test_file .$test_extension).$ref_extension"

    # Check if the reference file exists
    if [ ! -f "$ref_file" ]; then
        echo -e "${RED}Reference file $ref_file not found.${NC}"
        continue
    fi

    # Compare the test and reference files
    diff_output=$(diff $test_file $ref_file)

    if [ -z "$diff_output" ]; then
        printf "%-30s ${GREEN}%-10s${NC}\n" "$(basename $test_file)" "PASS"
    else
        diff_file="$test_dir/$(basename $test_file .mem).diff"
        echo "$diff_output" > $diff_file
        printf "%-30s ${RED}%-10s${NC}\n" "$(basename $test_file)" "FAIL"
    fi
done
