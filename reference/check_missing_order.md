# Check for Missing Values in the Order of Publication

This function checks for missing values in the `Order in publication`
column of the `contributors_table`. If there are missing order numbers,
it returns an error indicating which rows are affected.

## Usage

``` r
check_missing_order(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "error".

- message:

  An informative message indicating the row numbers with missing order
  values.
