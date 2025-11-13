# Check for Duplicate Initials

This function checks for duplicate initials in the `contributors_table`,
taking into account the `Firstname`, `Middle name`, and `Surname`
columns. It issues a warning if duplicate initials are found, which may
indicate ambiguous contributor identification.

## Usage

``` r
check_duplicate_initials(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating the initials that are duplicated.
