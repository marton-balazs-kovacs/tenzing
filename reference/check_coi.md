# Check for Missing Conflict of Interest Statements

This function checks if a conflict of interest statement is provided for
each contributor. It returns a warning if any contributor is missing
this information.

## Usage

``` r
check_coi(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating the rows missing a conflict of
  interest statement.
