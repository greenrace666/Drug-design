from pathlib import Path

import pandas as pd

REPO_ROOT = Path(__file__).resolve().parents[2]
SCORES_FILE = REPO_ROOT / "data" / "processed" / "sorted_scores_af_widprob.csv"
RESULT_FILE = REPO_ROOT / "pdbcompresult" / "pdbcompres2"
OUTPUT_FILE = REPO_ROOT / "data" / "processed" / "yaypdbbyhomaesall.csv"


def main():
    if not SCORES_FILE.exists():
        print(f"Scores file not found: {SCORES_FILE}")
        return 1
    if not RESULT_FILE.exists():
        print(f"Comparison file not found: {RESULT_FILE}")
        return 1

    df = pd.read_csv(SCORES_FILE)
    result_df = pd.read_csv(RESULT_FILE, delim_whitespace=True, header=None)

    new_data = []
    for _, row in df.iterrows():
        filename = row[0]
        prob = row[2] if len(row) > 2 else None
        match = result_df[result_df[0] == filename]
        if not match.empty:
            hom = match.iloc[0, 11]
            new_data.append([row[0], row[1], hom, prob])

    new_df = pd.DataFrame(new_data, columns=["File", "Second Column", "Hom", "Prob"])
    new_df = new_df.sort_values(by="Hom", ascending=True)
    new_df.to_csv(OUTPUT_FILE, index=False)
    print(f"Sorted output saved to {OUTPUT_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
