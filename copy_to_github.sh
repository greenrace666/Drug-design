#!/bin/bash

# Base directory
AG8_DIR="/teamspace/studios/this_studio/ag8"
GITHUB_DIR="/teamspace/studios/this_studio/github_files"

# Create directory for GitHub files
mkdir -p "$GITHUB_DIR"

# Function to copy files from finalshout
copy_files() {
    local input_file="$1"
    
    while IFS= read -r line; do
        if [[ $line == *"_docking_output.txt" ]]; then
            # Get the base path without _docking_output.txt
            base_path="${line%_docking_output.txt}"
            
            # Source files
            docking_file="${AG8_DIR}/${line}"
            pdb_file="${AG8_DIR}/${base_path}.pdb"
            pdbqt_file="${AG8_DIR}/${base_path}.pdbqt"
            
            # Create target directory structure
            target_dir="${GITHUB_DIR}/$(dirname "$base_path")"
            mkdir -p "$target_dir"
            
            # Copy files if they exist
            [ -f "$docking_file" ] && cp "$docking_file" "${GITHUB_DIR}/${line}"
            [ -f "$pdb_file" ] && cp "$pdb_file" "${GITHUB_DIR}/${base_path}.pdb"
            [ -f "$pdbqt_file" ] && cp "$pdbqt_file" "${GITHUB_DIR}/${base_path}.pdbqt"
            
            echo "Copied files for: $base_path"
        fi
    done < "$input_file"
}

# Process both finalshout files
echo "Processing finalshout..."
copy_files "/teamspace/studios/this_studio/finalshout"

if [ -f "/teamspace/studios/this_studio/finalshout2" ]; then
    echo "Processing finalshout2..."
    copy_files "/teamspace/studios/this_studio/finalshout2"
fi

echo "Files are copied to: $GITHUB_DIR"
echo "You can now create a GitHub repository and push these files."

# Instructions for GitHub
cat << 'EOF'
To push these files to GitHub:

1. Create a new repository on GitHub
2. Initialize the github_files directory:
   cd /teamspace/studios/this_studio/github_files
   git init
   git add .
   git commit -m "Initial commit with docking results"
   git branch -M main
   git remote add origin YOUR_GITHUB_REPO_URL
   git push -u origin main

Replace YOUR_GITHUB_REPO_URL with your actual GitHub repository URL.
EOF