# Check for Duplicate Names

This function checks for duplicate names in the `contributors_table`. It
considers the combination of `Firstname`, `Middle name`, and `Surname`
to identify duplicates.

## Usage

``` r
check_duplicate_names(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message listing any duplicate names found.
