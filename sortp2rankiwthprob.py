import os
import csv
import pandas as pd

def extract_first_score_and_probability(csv_file):
    try:
        df = pd.read_csv(csv_file)
        if not df.empty:
            first_score = df.iloc[0, 2]  # Assuming the first score is in the third column
            first_probability = df.iloc[0, 3]  # Assuming the first probability is in the fourth column
            return first_score, first_probability
    except Exception as e:
        print(f"Error reading {csv_file}: {e}")
    return None, None

def main():
    csv_files = [os.path.join('../pdbpred', f) for f in os.listdir('../pdbpred') if f.endswith('.csv')]
    data = []
    
    for file in csv_files:
        score, probability = extract_first_score_and_probability(file)
        if score is not None and probability is not None and score > 30:
            data.append((os.path.basename(file), score, probability))
    
    # Sorting by score in descending order
    data.sort(key=lambda x: x[1], reverse=True)
    
    # Writing to a new CSV file
    output_file = "../sorted_scorespdb.csv"
    with open(output_file, mode='w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Filename", "First Score", "First Probability"])
        writer.writerows(data)
    
    print(f"Sorted scores saved to {output_file}")

if __name__ == "__main__":
    main()
