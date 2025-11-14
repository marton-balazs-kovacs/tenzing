# Check for Old Conflict of Interest Column Name

This function checks if the old column name "Conflict of interest" is
present in the contributors table. If found, it returns a warning with
instructions to update the column name to "Declares".

## Usage

``` r
check_coi_column_rename(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating that the column name needs to be
  updated.
