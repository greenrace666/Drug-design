#!/bin/bash

# Directory to save downloaded files
download_dir="/teamspace/studios/this_studio/downloaded_docking_files"
mkdir -p "$download_dir"

# Base directory where the files are located
base_dir="/teamspace/studios/this_studio/ag8"

# Run final.sh to get current output
echo "Running final.sh to get current results..."
final_output=$(/teamspace/studios/this_studio/final.sh)

# Process each line of the output
echo "Processing output and downloading files..."
while IFS= read -r line; do
  # Extract binding energy (first number in the line)
  energy=$(echo "$line" | grep -o -- "-[0-9.]*" | head -1)
  
  # Extract file path (everything after the energy)
  file_path=$(echo "$line" | sed "s|$energy ||" | sed "s|$base_dir/naphthalene_smiles/||")
  
  if [[ -n "$energy" && -n "$file_path" ]]; then
    # Source file path
    src_file="${base_dir}/naphthalene_smiles/${file_path}"
    
    # Create a descriptive filename with binding energy
    filename=$(basename "${file_path}")
    dest_file="${download_dir}/energy${energy}_${filename}"
    
    # Copy the file
    if [ -f "$src_file" ]; then
      cp "$src_file" "$dest_file"
      echo "Copied: $src_file -> $dest_file"
    else
      echo "File not found: $src_file"
    fi
    
    # Also try to find and copy the corresponding .pdbqt file (without _docking_output.txt)
    if [[ "$filename" == *_docking_output.txt ]]; then
      pdbqt_src="${src_file%_docking_output.txt}"
      pdbqt_dest="${dest_file%_docking_output.txt}.pdbqt"
      
      if [ -f "$pdbqt_src" ]; then
        cp "$pdbqt_src" "$pdbqt_dest"
        echo "Copied: $pdbqt_src -> $pdbqt_dest"
      else
        echo "PDBQT file not found: $pdbqt_src"
      fi
    fi
  else
    echo "Could not parse line: $line"
  fi
done <<< "$final_output"

echo "All files have been downloaded to $download_dir"