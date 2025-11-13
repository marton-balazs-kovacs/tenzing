# Check for Missing ORCID IDs

This function checks for missing values in the `ORCID iD` column of the
`contributors_table` and returns a warning if any ORCID IDs are missing.

## Usage

``` r
check_missing_orcid(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe containing the contributors' information.

## Value

A list containing:

- type:

  Type of validation result: "success" or "warning".

- message:

  An informative message indicating the row numbers with missing ORCID
  IDs, if any.

## Details

If the `ORCID iD` column does not exist, the function returns a success
message since ORCID IDs are optional.
