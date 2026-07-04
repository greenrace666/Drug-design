from pathlib import Path

import pandas as pd

REPO_ROOT = Path(__file__).resolve().parents[2]
INPUT_DIR = REPO_ROOT / "predaf"
OUTPUT_FILE = REPO_ROOT / "data" / "processed" / "sorted_scoresaf2.csv"


def extract_first_score(csv_file: Path):
    try:
        df = pd.read_csv(csv_file)
        if not df.empty:
            return df.iloc[0, 2]
    except Exception as e:
        print(f"Error reading {csv_file}: {e}")
    return None


def main():
    if not INPUT_DIR.exists():
        print(f"Input directory not found: {INPUT_DIR}")
        return 1

    csv_files = sorted(INPUT_DIR.glob("*.csv"))
    data = []

    for file in csv_files:
        score = extract_first_score(file)
        if score is not None:
            data.append((file.name, score))

    data.sort(key=lambda x: x[1], reverse=True)

    with OUTPUT_FILE.open(mode="w", newline="") as f:
        import csv

        writer = csv.writer(f)
        writer.writerow(["Filename", "First Score", "Score Value"])
        writer.writerows(data)

    print(f"Sorted scores saved to {OUTPUT_FILE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
