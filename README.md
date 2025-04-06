# Drug Design Project

This repository contains scripts and data for protein analysis and drug design workflows.

## Project Structure

### Core PDB Files
- `3uq9prot.pdb`, `8plaprot.pdb` - Primary protein structure files for analysis
- `Gen_3_Mutant_93_346897__1_pose_*.pdb`, `Gen_5_Mutant_19_881586__1_pose_*.pdb` - Generated mutant protein poses

### Analysis Scripts
- `check_forbidden_fragments.py` - Validates molecular fragments against forbidden patterns
- `sortcsvforaf.py` - Sorts AlphaFold-related CSV data
- `sortcsvforpdb.py` - Processes and sorts PDB-related data
- `sortp2rankiwthprob.py` - Ranks proteins with probability scores
- `sortp2rankprot.py` - General protein ranking script
- `outputtop.py` - Generates top-ranking outputs

### Shell Scripts
- `convert_top_docked.sh` - Converts top docked poses
- `copy_to_github.sh` - GitHub repository management
- `copy_top_pdbs.sh`, `copyoutputtop.sh` - PDB file management scripts
- `outputtop.sh`, `outputtop2.sh` - Output processing scripts
- `pdbdownlaod.sh` - Downloads PDB files
- `runag4.sh` - Main analysis pipeline script

### Data Files
- `p2rank_*.csv` - P2Rank scoring results for different protein sets
- `sorted_scores_af.csv`, `sorted_scores_af_widprob.csv` - Sorted AlphaFold scoring results
- `part_aa.csv` - Amino acid analysis data

### Results
- `resultfor3uq9.html`, `resultfor8palpdb.html`, `resultfor8pla.html` - Analysis result visualizations
- `tophits/` - Directory containing top-scoring results

### Documentation
- `rcppt.gslides`, `review1.gslides` - Project presentations and reviews

## Usage
Refer to individual script documentation for specific usage instructions. Main workflow typically starts with PDB processing, followed by analysis and ranking procedures.