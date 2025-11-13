# Check for Presence of Assigned CRediT Roles

This function verifies that at least one CRediT taxonomy role is checked
for any contributor in the filtered dataset.

## Usage

``` r
check_roles_present(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "error".

- message:

  A descriptive validation message.

## Details

This validation is equivalent to the internal check used in
[`print_credit_roles()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_credit_roles.md)
to ensure that contributors have at least one CRediT category marked as
TRUE.
