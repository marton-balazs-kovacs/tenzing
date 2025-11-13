# Check for Duplicate Order Numbers

This function checks for duplicate order numbers in the
`Order in publication` column of the `contributors_table`. If duplicate
order numbers are detected and there are no shared first authors, the
function returns an error.

## Usage

``` r
check_duplicate_order(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "error".

- message:

  An informative message indicating the order numbers that are
  duplicated.
