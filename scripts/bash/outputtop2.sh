#!/bin/bash

# Temporary file to store outputs
temp_file=$(mktemp)

# Get the current script name
current_script=$(basename "$0")

# Loop through all .sh files in the current directory
for script in ag8/*.sh; do
    if [ -f "$script" ] && [ "$script" != "$current_script" ]; then
        # Execute the script and capture the output
        output=$(bash "$script" 2>/dev/null)
        
        # Get the last line of the output
        last_line=$(echo "$output" | tail -n 1)
        
        # Append to temporary file if not empty
        if [ -n "$last_line" ]; then
            echo "$last_line" >> "$temp_file"
        fi
    fi
done

# Sort by second column (numeric order) and print
sort -nr -k2 "$temp_file"

# Remove temporary file
rm "$temp_file"
