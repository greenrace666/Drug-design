import os
import csv
import pandas as pd

def extract_first_score(csv_file):
    try:
        df = pd.read_csv(csv_file)
        if not df.empty:
            first_score = df.iloc[0, 2]  # Assuming the first score is in the second column
            return first_score
    except Exception as e:
        print(f"Error reading {csv_file}: {e}")
    return None

def main():
    csv_files = [os.path.join('pred', f) for f in os.listdir('predaf') if f.endswith('.csv')]
    data = []
    
    for file in csv_files:
        score = extract_first_score(file)
        if score is not None:
            data.append((file, score))
    
    # Sorting by score in descending order
    data.sort(key=lambda x: x[1], reverse=True)
    
    # Writing to a new CSV file
    output_file = "sorted_scoresaf2.csv"
    with open(output_file, mode='w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Filename", "First Score", "Score Value"])
        writer.writerows(data)
    
    print(f"Sorted scores saved to {output_file}")

if __name__ == "__main__":
    main()
