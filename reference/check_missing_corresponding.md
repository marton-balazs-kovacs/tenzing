# Check for Missing Corresponding Author

This function checks if there is at least one corresponding author
indicated in the `contributors_table`. If none are found, it returns a
warning.

## Usage

``` r
check_missing_corresponding(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating whether a corresponding author is
  missing.
