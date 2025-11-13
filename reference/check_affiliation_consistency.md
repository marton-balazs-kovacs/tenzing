# Check affiliation columns for consistency

This function checks if both legacy (`Primary affiliation` and
`Secondary affiliation`) and `Affiliation {n}` columns are present in
the contributors_table. If both are present, it raises a warning to
suggest using only one format to ensure consistent results. In the first
version of tenzing only two affiliation were allowed per contributor and
the required names for the columns were `Primary affiliation` and
`Secondary affiliation`. In the new version of the spreadsheet any
number of affiliation columns can be created as long as they follow the
`Affiliation {number}` naming convention.

## Usage

``` r
check_affiliation_consistency(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message regarding the validation result.
