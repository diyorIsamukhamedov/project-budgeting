import os              # Module for interacting with the operating system (files, directories, etc.)
import pandas as pd    # Pandas library for working with tabular data (DataFrames)
import re              # Regular expressions library for string processing

# Path to the folder containing raw CSV files
RAW_DIR = "data/row"

# Path to the folder where cleaned CSV files will be saved
CLEAN_DIR = "data/clean"

# Create the CLEAN_DIR folder if it doesn’t already exist.
# os.makedirs(path, exist_ok=True) creates the folder and ignores the error if it already exists.
os.makedirs(CLEAN_DIR, exist_ok=True)

# Function to standardize column names
def normalize_column_name(col: str):
    """
    Converts column names to snake_case:
        1. Remove leading and trailing whitespaces
        2. Replace spaces and hyphens with underscores "_"
        3. Remove all characters except letters, digits, and underscores
        4. Convert to lowercase
    """
    return re.sub(                              # Step 3: remove unwanted characters
        r"[^a-zA-Z0-9_]", "",                   # Keep only letters, numbers, and underscores
        re.sub(r"[\s\-]+", "_", col.strip())    # Step 1–2: strip spaces and replace whitespace/hyphens with "_"
    ).lower()                                   # Step 4: convert to lowercase

# Iterate through all files in the RAW_DIR folder
for filename in os.listdir(RAW_DIR):
    # Process only CSV files
    if filename.endswith(".csv"):
        # Full path to the current raw file
        file_path = os.path.join(RAW_DIR, filename)

        # Load the CSV file into a Pandas DataFrame
        df = pd.read_csv(file_path)

        # Normalize all column names using the function
        df.columns = [normalize_column_name(c) for c in df.columns]

        # Drop technical columns like "unnamed0", "unnamed1", etc.
        df = df.drop(columns=[c for c in df.columns if c.startswith("unnamed")])

        # Create the output filename with "_clean" suffix
        clean_filename = filename.replace(".csv", "_clean.csv")

        # Full path to the output cleaned file
        clean_path = os.path.join(CLEAN_DIR, clean_filename)

        # Save the cleaned DataFrame back to CSV without the index column
        df.to_csv(clean_path, index=False)

        # Log the success message with original and cleaned filenames
        print(f"[OK] {filename} → {clean_filename}")