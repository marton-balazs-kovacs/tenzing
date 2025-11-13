# Validating the contributors table

This function validates the `contributors_table` provided to it by
checking whether the provided `contributors_table` is compatible with
the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).
The function early escapes only if the provided `contributors_table` is
not a dataframe, the variable names that are present in the
`contributors_table_template` is missing, or if the `contributors_table`
is empty.

## Usage

``` r
validate_contributors_table(contributors_table, config_path)
```

## Arguments

- contributors_table:

  dataframe, filled out contributors_table

- config_path:

  character, file path to validation configuration file

## Value

The function returns a list for each checked statement. Each list
contains a `type` vector that stores whether the statement passed the
check "success" or failed "warning" or "error", and a `message` vector
that contains information about the nature of the check.

## The function checks the following statements

- error, the provided contributors_table is not a dataframe

- error, none of the outputs can be created based the provided
  contributors_table due to missing columns

- error, the provided contributors_table is empty
