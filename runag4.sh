#!/bin/bash

# 1. Install required packages
sudo uv pip install --system rdkit func_timeout
sudo apt install jq -y
# 2. Clone autogrow4 repository
#git clone -b 4.0.3 https://github.com/nikilkrishna/autogrow4.git ag7
git clone -b 4.0.3 https://github.com/durrantlab/autogrow4.git ag4vinahighlip
# 3. Change into autogrow4 directory
cd ag4vinahighlip

# 4. Download MGLTools
wget https://ccsb.scripps.edu/mgltools/download/495/

# 5. Rename downloaded file
mv index.html mgltools_x86_64Linux2_1.5.6p1.tar.gz

# 6. Extract MGLTools
tar -xvzf mgltools_x86_64Linux2_1.5.6p1.tar.gz

# 7. Change into MGLTools directory
cd mgltools_x86_64Linux2_1.5.6

# 8. Run install script
./install.sh

# 9. Change back to autogrow4 directory
cd ..

# 10. Copy sample submit script and create duplicates
cp sample_sub_scripts/sample_submit_autogrow.json .
for file in source_compounds/*.smi; do
  filename=$(basename "$file" ".smi")
  cp sample_sub_scripts/sample_submit_autogrow.json "$filename".json
done

# 11. Modify JSON files
for file in *.json; do
  filename=$(basename "$file" ".json")
  filepath="./source_compounds/$filename.smi"
  jq ".filename_of_receptor = \"/teamspace/studios/this_studio/8plaprot.pdb\"" "$file" > temp.json && mv temp.json "$file"
  jq ".center_x = 3.4" "$file" > temp.json && mv temp.json "$file"
  jq ".center_y = -3.4" "$file" > temp.json && mv temp.json "$file"
  jq ".center_z = 53.4" "$file" > temp.json && mv temp.json "$file"
  jq ".size_x = 30" "$file" > temp.json && mv temp.json "$file"
  jq ".size_y = 30" "$file" > temp.json && mv temp.json "$file"
  jq ".size_z = 30" "$file" > temp.json && mv temp.json "$file"
  jq ".source_compound_file = \"$filepath\"" "$file" > temp.json && mv temp.json "$file"
  jq ".root_output_folder = \"./$filename/\"" "$file" > temp.json && mv temp.json "$file"
  jq ".mgltools_directory = \"./mgltools_x86_64Linux2_1.5.6\"" "$file" > temp.json && mv temp.json "$file"
  jq ".number_of_mutants_first_generation = 10" "$file" > temp.json && mv temp.json "$file"
  jq ".number_of_crossovers_first_generation = 10" "$file" > temp.json && mv temp.json "$file"
  jq ".number_of_mutants = 10" "$file" > temp.json && mv temp.json "$file"
  jq ".number_of_crossovers = 10" "$file" > temp.json && mv temp.json "$file"
  jq ".number_elitism_advance_from_previous_gen = 5" "$file" > temp.json && mv temp.json "$file"
  jq ".top_mols_to_seed_next_generation = 5" "$file" > temp.json && mv temp.json "$file"
  jq ".diversity_mols_to_seed_first_generation = 5" "$file" > temp.json && mv temp.json "$file"
  jq ".diversity_seed_depreciation_per_gen = 0" "$file" > temp.json && mv temp.json "$file"
  jq ".num_generations = 10" "$file" > temp.json && mv temp.json "$file"
  jq ".number_of_processors = -1" "$file" > temp.json && mv temp.json "$file"
  jq ".selector_choice = \"Rank_Selector\"" "$file" > temp.json && mv temp.json "$file"
  jq ".max_variants_per_compound = 1" "$file" > temp.json && mv temp.json "$file"
  jq ".filter_source_compounds = false" "$file" > temp.json && mv temp.json "$file"
  jq ".use_docked_source_compounds = false" "$file" > temp.json && mv temp.json "$file"
  jq ".LipinskiStrictFilter = true" "$file" > temp.json && mv temp.json "$file"
  jq ".docking_exhaustiveness = 8" "$file" > temp.json && mv temp.json "$file"
  jq ".start_a_new_run = true" "$file" > temp.json && mv temp.json "$file"
  jq ".generate_plot = true" "$file" > temp.json && mv temp.json "$file"
  jq ".rescore_lig_efficiency = true" "$file" > temp.json && mv temp.json "$file"
  jq ".scoring_choice = \"VINA\"" "$file" > temp.json && mv temp.json "$file"
  jq ".dock_choice = \"VinaDocking\"" "$file" > temp.json && mv temp.json "$file"
  jq ".gypsum_timeout_limit = 1" "$file" > temp.json && mv temp.json "$file"
  jq ".debug_mode = false" "$file" > temp.json && mv temp.json "$file"
  jq ".rxn_library = \"all_rxns\"" "$file" > temp.json && mv temp.json "$file"
  jq ".conversion_choice = \"MGLToolsConversion\"" "$file" > temp.json && mv temp.json "$file"
done

# 12. Create.sh files with same filenames as.smi files
for file in source_compounds/*.smi; do
  filename=$(basename "$file" ".smi")
  cat > "$filename".sh << EOF
#!/bin/bash

# Directory to search
search_dir="$filename"

# Temporary file to store output
temp_file=\$(mktemp)

# Find all files ending with.pdbqt_docking_output.txt recursively in the specified directory
find "\$search_dir" -type f -name "*.pdbqt_docking_output.txt" | while read -r file
do
  # Check if the file has at least 40 lines
  if [ \$(wc -l < "\$file") -ge 40 ]; then
    # Get the 40th line
    line=\$(sed -n '40p' "\$file")
    # Output the file name and the 40th line to the temporary file
    echo "\$line \$file" >> "\$temp_file"
  else
    echo "\$file does not have 40 lines."
  fi
done

# Sort the temporary file in descending order of the first column (numeric sort) and print
sort -n "\$temp_file"

# Remove the temporary file
rm "\$temp_file"
EOF
  chmod +x "$filename".sh
done
#13 install gnome-terminal
#sudo apt install pv -y
# 14. Run Autogrow in separate terminal windows
for file in *.json; do
  python RunAutogrow.py -j "$file" &
done
# 15. Execute all the duplicate sh files and output just the last line of each output
"""outputs=()
for file in *.sh; do
  output=$("$file")
  outputs+=("${output##*$'\n'}")
done

# Sort the outputs in ascending order numerically
sorted_outputs=($(printf "%s\n" "${outputs[@]}" | sort -n))

# Print the sorted outputs
for output in "${sorted_outputs[@]}"; do
  echo "$output"
done"