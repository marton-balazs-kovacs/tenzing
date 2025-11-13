# Check for Missing Affiliations

This function checks whether at least one affiliation (either legacy or
numbered) is provided for each contributor. If a contributor is missing
all affiliation information, the function returns a warning.

## Usage

``` r
check_affiliation(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating which rows have missing
  affiliations.
