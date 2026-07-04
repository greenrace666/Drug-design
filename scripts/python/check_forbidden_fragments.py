from pathlib import Path
import glob

from rdkit import Chem
from rdkit.Chem import rdFMCS

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_FINALSHOUT = Path("/teamspace/studios/this_studio/finalshout2")
FORBIDDEN_DIR = Path("/teamspace/studios/this_studio/LigBuilderV3/forbidden.mdb")
FALLBACK_PDB_DIR = REPO_ROOT / "results" / "poses"


def read_smiles_from_pdb(pdb_file: Path):
    """Extract SMILES string from the REMARK line in a PDB file."""
    with pdb_file.open("r") as f:
        for line in f:
            if line.startswith("REMARK Final SMILES string:"):
                return line.split(":", 1)[1].strip()
    return None


def read_mol2_files(directory: Path):
    """Read all mol2 files in the given directory and return a list of RDKit molecules."""
    molecules = []

    for mol2_file in directory.glob("*.mol2"):
        mol_name = mol2_file.stem

        with mol2_file.open("r") as f:
            mol2_content = f.read()

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
        if target_mol.HasSubstructMatch(frag_mol):
            matches.append((frag_mol.GetProp("_Name"), "Direct substructure match"))
            continue

        mcs = rdFMCS.FindMCS([target_mol, frag_mol], completeRingsOnly=True)
        if mcs.numAtoms > 0 and mcs.numAtoms == frag_mol.GetNumAtoms():
            matches.append((frag_mol.GetProp("_Name"), f"MCS match with {mcs.numAtoms} atoms"))

    return matches


def get_files_from_finalshout():
    """Extract file paths from the finalshout file."""
    if DEFAULT_FINALSHOUT.exists():
        file_paths = []
        with DEFAULT_FINALSHOUT.open("r") as f:
            lines = f.readlines()

        for i in range(4, len(lines), 5):
            file_path = lines[i].strip()
            if file_path.endswith("_docking_output.txt"):
                pdb_path = file_path.replace(".pdbqt_docking_output.txt", ".pdb")
                full_path = Path("/teamspace/studios/this_studio/ag9") / pdb_path
                file_paths.append(full_path)
        return file_paths

    if FALLBACK_PDB_DIR.exists():
        return sorted(FALLBACK_PDB_DIR.glob("*.pdb"))

    return []


def main():
    if not FORBIDDEN_DIR.exists():
        print(f"Forbidden fragment directory not found: {FORBIDDEN_DIR}")
        return 1

    pdb_files = get_files_from_finalshout()

    if not pdb_files:
        print("No PDB files found to process.")
        return 1

    print(f"Found {len(pdb_files)} files to process:")
    for pdb_file in pdb_files:
        print(f"  - {pdb_file}")

    fragment_mols = read_mol2_files(FORBIDDEN_DIR)
    print(f"Loaded {len(fragment_mols)} forbidden fragments")

    for pdb_file in pdb_files:
        pdb_file = Path(pdb_file)
        print(f"\nProcessing: {pdb_file}")

        if not pdb_file.exists():
            print(f"Error: File does not exist: {pdb_file}")
            continue

        smiles = read_smiles_from_pdb(pdb_file)
        if not smiles:
            print(f"Error: Could not extract SMILES from {pdb_file}")
            continue

        print(f"Molecule SMILES: {smiles}")

        target_mol = Chem.MolFromSmiles(smiles)
        if target_mol is None:
            print(f"Error: Could not parse SMILES: {smiles}")
            continue

        matches = check_substructure_match(target_mol, fragment_mols)

        if matches:
            print("Forbidden fragments found in the molecule:")
            for name, match_type in matches:
                print(f"- {name}: {match_type}")
        else:
            print("No forbidden fragments found in the molecule.")


if __name__ == "__main__":
    raise SystemExit(main())
