#!/bin/bash

# Base directories
AG8_DIR="/teamspace/studios/this_studio/ag8"
AG9_DIR="/teamspace/studios/this_studio/ag9"
OUTPUT_DIR="/teamspace/studios/this_studio/dockedtoppdb"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to process files from finalshout
process_files() {
    local input_file="$1"
    local base_dir="$2"
    
    while IFS= read -r line; do
        if [[ $line == *"_docking_output.txt" ]]; then
            # Get the base path without _docking_output.txt
            base_path="${line%.pdbqt_docking_output.txt}"
            
            # Source vina file
            vina_file="${base_dir}/${base_path}.pdbqt.vina"
            
            if [ -f "$vina_file" ]; then
                echo "Processing: $vina_file"
                python /teamspace/studios/this_studio/ag8/accessory_scripts/convert_vina_docked_pdbqt_to_pdbs.py \
                    --vina_docked_pdbqt_file "$vina_file" \
                    --output_folder "$OUTPUT_DIR" \
                    --max_num_of_poses 2
            else
                echo "Warning: Vina file not found: $vina_file"
            fi
        fi
    done < "$input_file"
}

# Process finalshout (from ag8)
echo "Processing finalshout files from ag8..."
process_files "/teamspace/studios/this_studio/finalshout" "$AG8_DIR"

# Process finalshout2 (from ag9)
echo "Processing finalshout2 files from ag9..."
process_files "/teamspace/studios/this_studio/finalshout2" "$AG9_DIR"

echo "All conversions complete. Files are in: $OUTPUT_DIR"