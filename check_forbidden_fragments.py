#!/usr/bin/env python
import os
import glob
from rdkit import Chem
from rdkit.Chem import AllChem
from rdkit.Chem import rdFMCS

def read_smiles_from_pdb(pdb_file):
    """Extract SMILES string from the REMARK line in a PDB file."""
    with open(pdb_file, 'r') as f:
        for line in f:
            if line.startswith('REMARK Final SMILES string:'):
                return line.split(':', 1)[1].strip()
    return None

def read_mol2_files(directory):
    """Read all mol2 files in the given directory and return a list of RDKit molecules."""
    mol2_files = glob.glob(os.path.join(directory, '*.mol2'))
    molecules = []
    
    for mol2_file in mol2_files:
        # Extract molecule name from the file
        mol_name = os.path.basename(mol2_file).split('.')[0]
        
        # Read the mol2 file
        with open(mol2_file, 'r') as f:
            mol2_content = f.read()
        
        # Parse the mol2 content to get the molecule
        mol = Chem.MolFromMol2Block(mol2_content, sanitize=True, removeHs=False)
        
        if mol is not None:
            mol.SetProp("_Name", mol_name)
            molecules.append(mol)
        else:
            print(f"Warning: Could not parse {mol2_file}")
    
    return molecules

def check_substructure_match(target_mol, fragment_mols):
    """Check if any of the fragment molecules are substructures of the target molecule."""
    matches = []
    
    for frag_mol in fragment_mols:
        # Try direct substructure matching
        if target_mol.HasSubstructMatch(frag_mol):
            matches.append((frag_mol.GetProp("_Name"), "Direct substructure match"))
            continue
        
        # Try MCS (Maximum Common Substructure) matching
        mcs = rdFMCS.FindMCS([target_mol, frag_mol], completeRingsOnly=True)
        if mcs.numAtoms > 0 and mcs.numAtoms == frag_mol.GetNumAtoms():
            matches.append((frag_mol.GetProp("_Name"), f"MCS match with {mcs.numAtoms} atoms"))
    
    return matches

def get_files_from_finalshout():
    """Extract file paths from the finalshout file."""
    finalshout_path = "/teamspace/studios/this_studio/finalshout2"
    file_paths = []
    
    try:
        with open(finalshout_path, 'r') as f:
            lines = f.readlines()
            
        # The file format appears to have the path every 5th line
        for i in range(4, len(lines), 5):
            if i < len(lines):
                file_path = lines[i].strip()
                if file_path.endswith('_docking_output.txt'):
                    # Convert to PDB path
                    pdb_path = file_path.replace('.pdbqt_docking_output.txt', '.pdb')
                    # Add the base directory
                    full_path = os.path.join("/teamspace/studios/this_studio/ag9", pdb_path)
                    file_paths.append(full_path)
        
        return file_paths
    except Exception as e:
        print(f"Error reading finalshout file: {e}")
        return []

def main():
    # Path to forbidden fragments directory
    forbidden_dir = "/teamspace/studios/this_studio/LigBuilderV3/forbidden.mdb"
    
    # Get file paths from finalshout file
    pdb_files = get_files_from_finalshout()
    
    if not pdb_files:
        print("No files found in finalshout. Using default file.")
        pdb_files = ["/teamspace/studios/this_studio/ag8/PARPi/Run_0/generation_8/PDBs/Gen_8_Cross_44451__1.pdb"]
    else:
        print(f"Found {len(pdb_files)} files to process:")
        for pdb_file in pdb_files:
            print(f"  - {pdb_file}")
    
    # Read forbidden fragments
    fragment_mols = read_mol2_files(forbidden_dir)
    print(f"Loaded {len(fragment_mols)} forbidden fragments")
    
    # Process each PDB file
    for pdb_file in pdb_files:
        print(f"\nProcessing: {pdb_file}")
        
        # Check if file exists
        if not os.path.exists(pdb_file):
            print(f"Error: File does not exist: {pdb_file}")
            continue
        
        # Extract SMILES from PDB
        smiles = read_smiles_from_pdb(pdb_file)
        if not smiles:
            print(f"Error: Could not extract SMILES from {pdb_file}")
            continue
        
        print(f"Molecule SMILES: {smiles}")
        
        # Convert SMILES to RDKit molecule
        target_mol = Chem.MolFromSmiles(smiles)
        if target_mol is None:
            print(f"Error: Could not parse SMILES: {smiles}")
            continue
        
        # Check for matches
        matches = check_substructure_match(target_mol, fragment_mols)
        
        # Print results
        if matches:
            print("Forbidden fragments found in the molecule:")
            for name, match_type in matches:
                print(f"- {name}: {match_type}")
        else:
            print("No forbidden fragments found in the molecule.")

if __name__ == "__main__":
    main()