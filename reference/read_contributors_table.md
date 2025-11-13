# Read the filled out contributors_table

This function reads the `contributors_table` given the path if the file
is a csv, tsv or an xlsx. The function can read googlesheets if share
url is provided or local files if path to the local folder is provided.

## Usage

``` r
read_contributors_table(contributors_table_path)
```

## Arguments

- contributors_table_path:

  the full path to the file with extension

## Value

The function returns the contributors table as a dataframe.

## Warning

If the file is an xlsx the function only reads the first sheet.
