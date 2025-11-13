# Check for Contributors with No CRediT Roles

This function checks whether each contributor has at least one CRediT
taxonomy role checked. It returns a warning if any contributor has no
roles assigned.

## Usage

``` r
check_credit(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating the rows with no CRediT roles
  assigned.
