#!/bin/bash

# Base directories
AG8_DIR="/teamspace/studios/this_studio/ag8"
AG9_DIR="/teamspace/studios/this_studio/ag9"
TOP_PDB_DIR="/teamspace/studios/this_studio/toppdb"

# Create directory for top PDB files
mkdir -p "$TOP_PDB_DIR"

# Function to copy PDB files
copy_pdbs() {
    local input_file="$1"
    local base_dir="$2"
    
    while IFS= read -r line; do
        if [[ $line == *"_docking_output.txt" ]]; then
            # Get the base path without _docking_output.txt
            base_path="${line%.pdbqt_docking_output.txt}"
            
            # Source PDB file
            pdb_file="${base_dir}/${base_path}.pdb"
            
            # Get binding energy (first number in the line)
            energy=$(echo "$line" | grep -o -- "-[0-9.]*" | head -1)
            
            if [ -f "$pdb_file" ]; then
                # Create new filename with energy and source directory
                src_dir=$(basename "$base_dir")
                new_name="energy${energy}_${src_dir}_$(basename "$base_path").pdb"
                cp "$pdb_file" "${TOP_PDB_DIR}/${new_name}"
                echo "Copied: $pdb_file -> ${TOP_PDB_DIR}/${new_name}"
            else
                echo "Warning: PDB file not found: $pdb_file"
            fi
        fi
    done < "$input_file"
}

# Process finalshout (from ag8)
echo "Processing finalshout (ag8)..."
copy_pdbs "/teamspace/studios/this_studio/finalshout" "$AG8_DIR"

# Process finalshout2 (from ag9)
echo "Processing finalshout2 (ag9)..."
copy_pdbs "/teamspace/studios/this_studio/finalshout2" "$AG9_DIR"

echo "All PDB files have been copied to: $TOP_PDB_DIR"