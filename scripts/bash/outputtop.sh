#!/bin/bash

# Absolute path to the ag8 directory
ag8_dir="/teamspace/studios/this_studio/ag4vinahighlip"  # CHANGE THIS IF NECESSARY

# Check if the ag8 directory exists
if [[ ! -d "$ag8_dir" ]]; then
  echo "Error: Directory '$ag8_dir' not found." >&2
  exit 1
fi

# Array to store the last lines of output
last_lines=()

# Loop through .sh files in ag8
for script in "$ag8_dir"/*.sh; do
  if [[ -f "$script" ]]; then
    # Construct the full path to the naphthalene_smiles directory
    naphthalene_path="$ag8_dir/naphthalene_smiles"

    # Execute the script, capturing output and setting the search directory
    output=$(cd "$ag8_dir" && export search_dir="$naphthalene_path" && bash "$script" 2>&1)

    # Extract the last line of output
    last_line=$(echo "$output" | tail -n 1)

    # Add the last line to the array
    last_lines+=("$last_line")
  fi
done

# Sort the last lines numerically (assuming they are numbers)
sorted_last_lines=($(printf "%s\n" "${last_lines[@]}" | sort -n))

# Print the sorted last lines
for line in "${sorted_last_lines[@]}"; do
  echo "$line"
done
