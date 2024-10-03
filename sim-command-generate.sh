#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    exit 1
fi

# Set variables from command-line arguments
BUILD_DIR="$1"
TOP_MODULE="$2"
SIMULATION_TIME="$3"
VSIM_MEM_OBJ_PATH="$4"
RESULT_DIR="$5"

# Directory to search
DIRECTORY="$6"

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    exit 1
fi

# Assign the sorted list of .vmem files to a variable
vmem_files=$(ls "$DIRECTORY"/*.vmem 2>/dev/null | sort)

# Loop through the files and generate commands
echo "vsim -c ${BUILD_DIR}.${TOP_MODULE} -voptargs=+acc; \\"
for file in $vmem_files; do
    file=$(basename "$file" .vmem)
    # Append the commands to output_script.sh
    cat <<EOF
echo \"Running simulation: $DIRECTORY/$file.vmem...\"; \\
cp -rf $DIRECTORY/$file.vmem ram.vmem; \\
restart; \\
vcd file ${RESULT_DIR}/${file}.vcd; \\
vcd add -r /*; \\
run ${SIMULATION_TIME}; \\
vcd flush; \\
vcd off; \\
mem save -o ${RESULT_DIR}/$file.mem -f mti -data hex -addr decimal -wordsperline 1 ${VSIM_MEM_OBJ_PATH}; \\
EOF
done
