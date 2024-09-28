#!/bin/bash

# Directories
REF_DIR="result_ref"
TEST_DIR="result_test"

# Output table header
printf "%-30s %-10s\n" "Test File" "Status"
printf "%-30s %-10s\n" "----------" "------"

# Loop through each .vmem file in the reference directory
for ref_file in "$REF_DIR"/*.vmem; do
    # Get the base filename without the path
    base_name=$(basename "$ref_file")
    
    # Construct the corresponding test file path
    test_file="$TEST_DIR/$base_name"
    
    # Check if the test file exists
    if [[ -f "$test_file" ]]; then
        # Compare the files
        if diff -q "$ref_file" "$test_file" > /dev/null; then
            status="OK"
        else
            status="FAIL"
        fi
    else
        status="FAIL (missing test file)"
    fi
    
    # Print the result in a table format
    printf "%-30s %-10s\n" "$base_name" "$status"
done
