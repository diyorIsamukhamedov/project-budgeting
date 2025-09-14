import os                       # Module for interacting with the operating system (files, directories, etc.)
import psycopg2                 # PostgreSQL adapter for Python, used to connect and interact with PostgreSQL databases
from dotenv import load_dotenv  # Utility to load environment variables from a .env file

# Load environment variables from a .env file into the file
load_dotenv()

# Retrieve environment variables securely (instead of hardcoding credentials)
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

# Define the folder where cleaned CSV files are stored
DATA_DIR = "data/clean"

# Map each CSV file name to the corresponding table in PostgreSQL
mapping = {
    "departments_clean.csv": "project_budgeting.departments",
    "employees_clean.csv": "project_budgeting.employees",
    "projects_clean.csv": "project_budgeting.projects",
    "completed_projects_clean.csv": "project_budgeting.completed_projects",
    "upcoming_projects_clean.csv": "project_budgeting.upcoming_projects",
    "project_assignments_clean.csv": "project_budgeting.project_assignments",
    "Head_Shots_clean.csv": "project_budgeting.head_shots"
}

def connect_db ():
    """
    This function establishes a connection to the PostgreSQL database
    using credentials from environment variables.

    Returns:
        psycopg2.connection: A live connection object to interact with the PostgreSQL database.
    """
    return psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )

def load_csv_to_table (cursor, file_path, table_name):
    """
    Loads data from a CSV file into a PostgreSQL table.

    Args:
        cursor (psycopg2.cursor): Cursor object used to execute SQL commands.
        file_path (str): Path to the CSV file on disk.
        table_name (str): Name of the target table in PostgreSQL.

    Process:
        - Opens the CSV file in read mode.
        - Skips the header row (first line).
        - Uses PostgreSQL COPY command to import the data efficiently.
    """
    with open(file_path, "r", encoding="utf-8") as f:
        next(f) # Skip the first line (header row with column names)
        cursor.copy_expert( # Use PostgreSQL's COPY command for efficient bulk loading
            f"COPY {table_name} FROM STDIN WITH CSV DELIMITER ',' NULL ''",
            f
        )

def main ():
    """
    Main function to load multiple CSV files into their corresponding PostgreSQL tables.

    Process:
        - Connects to the database.
        - Iterates over the mapping dictionary (file -> table).
        - For each CSV file:
            - Checks if the file exists.
            - If it exists, loads it into the corresponding table.
            - If it doesn't exist, skips and prints a warning.
        - Commits all changes to the database.
        - Closes all the connection.
    """
    # Create connection to database
    conn = connect_db()
    # Create cursor to execute SQL commands
    cursor = conn.cursor()

    # Loop through each file-table mapping
    for file_name, table_name in mapping.items():
        file_path = os.path.join(DATA_DIR, file_name)   # Full path to the file

        # Check if file exists
        if os.path.exists(file_path):
            print(f"Loading {file_name} into {table_name}")
            # Load data into DB
            load_csv_to_table(cursor, file_path, table_name)
        else:
            print(f"File {file_name} not found, skipping")

    # Save changes permanently to DB
    conn.commit()
    # Close cursor
    cursor.close()
    # Close database connection
    conn.close()
    print("All data loaded successfully!")

# Entry point check (runs only if script executed directly)
if __name__ == "__main__":
    main()  # Execute main workflow
