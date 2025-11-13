# Check for Missing Surnames

This function checks for missing values in the `Surname` column of the
`contributors_table` and returns a warning if any surnames are missing.

## Usage

``` r
check_missing_surname(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating the row numbers with missing
  surnames, if any.
