#!/bin/bash

RESULT_SIGNATURE_EXTENSION="signature"
RESULT_MEM_DIR="result_test"
RESULT_FILE_EXTENSION="elf.mem"
REFERENCE_VMEM_DIR="standard_ref/reference_vmem"
SEARCHED_FILE_EXTENSION="elf.readelf"

# Check if any .readelf files exist in the current directory
shopt -s nullglob
readelf_files=(${REFERENCE_VMEM_DIR}/*.${SEARCHED_FILE_EXTENSION})

if [ ${#readelf_files[@]} -eq 0 ]; then
    echo "No .${SEARCHED_FILE_EXTENSION} files found in the directory: ${REFERENCE_VMEM_DIR}"
    exit 1
fi

# Loop through each .readelf file
for file in "${readelf_files[@]}"; do
    # Get the basename without extension
    base_name=$(basename "$file" .${SEARCHED_FILE_EXTENSION})
    echo "Processing file: $file"

    # Extract addresses
    begin_address=$(grep -E 'begin_signature' "$file" | awk '{print $2}')
    end_address=$(grep -E 'end_signature' "$file" | awk '{print $2}')

    # Chia giá trị signature cho 4
   begin_address=$((0x$begin_address/4))
   end_address=$((0x$end_address/4-1))

    # Check if addresses were found
    if [ -n "$begin_address" ]; then
        echo "Address of begin_signature: $begin_address"
    else
        echo "begin_signature not found in $file"
    fi

    if [ -n "$end_address" ]; then
        echo "Address of end_signature: $end_address"
    else
        echo "end_signature not found in $file"
    fi

    echo "" # Add a blank line for better readability




    START_ADDRESS=${begin_address}
    END_ADDRESS=${end_address}
    MEM_FILE="${RESULT_MEM_DIR}/${base_name}.${RESULT_FILE_EXTENSION}"
    # Check if any .mem files exist
    if [[ ! -e "$MEM_FILE" ]]; then
        echo "No file ${MEM_FILE} found in the directory: ${RESULT_MEM_DIR}"
        exit 1
    fi

    echo "Processing file: $MEM_FILE"
    header_line_count=$(grep -c '^//' "${MEM_FILE}")
    START_ADDRESS=$(($START_ADDRESS+$header_line_count+1))
    END_ADDRESS=$(($END_ADDRESS+$header_line_count+1))

    # Read the memory file and filter based on the address range
    (awk "NR>=$START_ADDRESS && NR<=$END_ADDRESS {print \$2}" "${MEM_FILE}") > ${RESULT_MEM_DIR}/${base_name}.${RESULT_SIGNATURE_EXTENSION}
    echo "Done extract ${MEM_FILE} from address: ${begin_address} to ${end_address}"

    echo ""
    echo ""
    echo ""
done

