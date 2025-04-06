import pandas as pd

# Step 1: Read the sorted_scorespdb.csv file
df = pd.read_csv('p2rank_2.5/sorted_scoreswidprob.csv')

# Step 2: Read the pdbcompresult file
result_df = pd.read_csv('foldseek/foldseek/bin/result', delim_whitespace=True, header=None)

# Step 3: Extract and store relevant data
new_data = []
for index, row in df.iterrows():
    filename = row[0]
    match = result_df[result_df[0] == filename]
    if not match.empty:
        hom = match.iloc[0, 11]  # 12th column (index 11)
        new_data.append([row[0], row[1], hom, row[2]])  # Include sorting score

# Step 4: Create a DataFrame and sort it by the third column of sorted_scorespdb.csv (descending order)
new_df = pd.DataFrame(new_data, columns=['affile', 'score', 'hom', 'prob'])
new_df = new_df.sort_values(by='hom', ascending=True)

# Step 5: Write the sorted DataFrame to yaypdb2.csv
#new_df.drop(columns=['Sorting Score'], inplace=True)  # Remove sorting column
new_df.to_csv('yayafbyhomaesall.csv', index=False)
