#!/usr/bin/env python3

import pandas as pd
from pathlib import Path

import warnings

warnings.simplefilter("ignore")

SCRIPT_DIR = str(Path(__file__).parent.absolute()) + "/"
DATA_PATH = SCRIPT_DIR + "../../data/"


def load_datatable(filename: str | list[str], skiprows: [], skipcols: [], usecols: []):
    """Load a datatable from a file

    Args:
        filename: Filename(s) to load
        skiprows: List of rows to skip

    Returns: Dataframe of loaded datatable

    """

    # Offset skiprows by -1 to match pandas indexing
    skiprows = [x - 1 for x in skiprows]

    # Detect if skipcols contain alphabet column names or indices, and convert to indices
    if skipcols and isinstance(skipcols[0], str):
        new_skipcols = []
        for col in skipcols:
            # Handel columns with letters > 1. e.g., AA, AB, AC, AAG, AAH...
            if len(col) > 1:
                col = col.lower()
                col_num = 0
                for i in range(len(col)):
                    col_num += (ord(col[i]) - 96) * (26 ** (len(col) - i - 1))
                new_skipcols.append(col_num - 1)
            else:
                new_skipcols.append(ord(col.lower()) - 97)
        skipcols = new_skipcols

    # Detect if usecols contain alphabet column names or indices, and convert to indices
    if usecols and isinstance(usecols[0], str):
        new_usecols = []
        for col in usecols:
            # Handel columns with letters > 1. e.g., AA, AB, AC, AAG, AAH...
            if len(col) > 1:
                col = col.lower()
                col_num = 0
                for i in range(len(col)):
                    col_num += (ord(col[i]) - 96) * (26 ** (len(col) - i - 1))
                new_usecols.append(col_num - 1)
            else:
                new_usecols.append(ord(col.lower()) - 97)
        usecols = new_usecols

    # If usecols is provided, use it instead of skipcols and vice versa but not
    # both
    df = None
    source_files = filename
    if isinstance(filename, str):
        source_files = [filename]

    for file in source_files:
        df_temp = None
        if usecols:
            if ".xlsx" in file:
                df_temp = pd.read_excel(
                    DATA_PATH + file,
                    skiprows=skiprows,
                    header=None,  # ignore header so we can pick columns by index
                    usecols=usecols,
                    dtype=str,  # force all columns to be strings
                )
            elif ".csv" in file:
                df_temp = pd.read_csv(
                    DATA_PATH + file,
                    skiprows=skiprows,
                    header=None,  # ignore header so we can pick columns by index
                    usecols=usecols,
                    dtype=str,  # force all columns to be strings
                )

            # Since we ignored the header, a new row is added with the column indices
            # as values. We need to remove this row.
            df_temp = df_temp[1:]
        else:
            if ".xlsx" in file:
                df_temp = pd.read_excel(
                    DATA_PATH + file,
                    skiprows=skiprows,
                    dtype=str,  # force all columns to be strings
                )
            elif ".csv" in file:
                df_temp = pd.read_csv(
                    DATA_PATH + file,
                    skiprows=skiprows,
                    dtype=str,  # force all columns to be strings
                )

            # Get column names not being skipped, if any
            columns = [
                col for i, col in enumerate(df_temp.columns) if i not in skipcols
            ]
            # Temporarily convert header names to indices
            df_temp.columns = range(df_temp.shape[1])
            # Drop columns by index and restore header names, then reset header names
            df_temp = df_temp.drop(df_temp.columns[skipcols], axis=1)
            df_temp.columns = columns

        # Concatenate dataframes
        if df is None:
            df = df_temp
        else:
            df = pd.concat([df, df_temp], ignore_index=True)

    return df


def write_datatable_to_csv(df: pd.DataFrame, filename: str):
    """Write a dataframe to a csv file

    Args:
        df: Dataframe to write
        filename: Filename to write to
    """

    filepath = Path(DATA_PATH + filename)

    # Make sure the data directory exists
    filepath.parent.mkdir(parents=True, exist_ok=True)

    df.to_csv(DATA_PATH + filename, index=False)


def handle_edge_cases(df: pd.DataFrame, drop_empty_columns: bool = True):
    """Handle edge cases in a dataframe

    Args:
        df: Dataframe to handle edge cases in

    Returns: Dataframe with edge cases handled

    """
    # Remove empty columns
    if drop_empty_columns:
        df = df.dropna(axis=1, how="all")

    # Remove empty rows
    df = df.dropna(how="all")

    # Round floats to 2 decimal places
    df = df.round(2)

    # Remove trailing spaces
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

    # Remove leading spaces
    df = df.applymap(lambda x: x.lstrip() if isinstance(x, str) else x)

    # Remove duplicates
    df = df.drop_duplicates()

    return df


def drop_rows_with_empty_cells(df: pd.DataFrame, columns: list[str]):
    """Drop rows with empty cells in a dataframe

    Args:
        df: Dataframe to drop rows from
        columns: List of columns to check for empty cells

    Returns: Dataframe with empty rows dropped

    """
    # Return dropped rows as well
    df_dropped = pd.DataFrame()
    for column in columns:
        df_dropped = pd.concat([df_dropped, df[df[column].isnull()]])
        df = df.dropna(subset=[column])

    return df, df_dropped


def drop_rows_containing(df: pd.DataFrame, column: str, values: str | list[str]):
    """Drop rows containing a value in a dataframe

    Args:
        df: Dataframe to drop rows from
        column: Column to check for value
        values: Values to check for. Regex is supported.

    Returns: Dataframe with rows containing value dropped

    """
    patterns = values
    if isinstance(values, str):
        patterns = [values]

    # Return dropped rows as well
    df_dropped = df[df[column].str.contains("|".join(patterns), na=False, regex=True)]
    df = df[~df[column].str.contains("|".join(patterns), na=False, regex=True)]

    return df, df_dropped


def drop_rows_not_containing(df: pd.DataFrame, column: str, values: str | list[str]):
    """Drop rows not containing a value in a dataframe

    Args:
        df: Dataframe to drop rows from
        column: Column to check for value
        values: Values to check for. Regex is supported.

    Returns: Dataframe with rows not containing value dropped

    """
    patterns = values
    if isinstance(values, str):
        patterns = [values]

    # Return dropped rows as well.
    df_dropped = df[~df[column].str.contains("|".join(patterns), na=False, regex=True)]
    df = df[df[column].str.contains("|".join(patterns), na=False, regex=True)]

    return df, df_dropped


def fill_empty_cells(df: pd.DataFrame, column: list[str], value: str):
    """Fill empty cells in a dataframe with a value

    Args:
        df: Dataframe to fill
        column: Column to fill
        value: Value to fill with

    Returns: Dataframe with empty cells filled

    """
    df[column] = df[column].fillna(value)

    return df


def substitute_column_cell_values(
    df: pd.DataFrame, column: str, pattern: str, replace: str
):
    """Substitute cells in a column with a value using a regex pattern.

    Args:
        df: Dataframe to substitute cells in
        column: Column to substitute cells in
        pattern: Regex pattern to match
        replace: Value to replace the matching pattern

    Returns: Dataframe with cells substituted

    """
    df[column] = df[column].str.replace(pattern, replace, regex=True)

    return df
