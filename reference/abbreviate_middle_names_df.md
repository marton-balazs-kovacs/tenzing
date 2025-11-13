# Abbreviate middle names in a dataframe

The function calls the
[`abbreviate()`](https://marton-balazs-kovacs.github.io/tenzing/reference/abbreviate.md)
function to abbreviate middle names in the `Middle name` variable in a
dataframe if they are present. The function requires a valid
`contributors_table` as an input to work.

## Usage

``` r
abbreviate_middle_names_df(contributors_table)
```

## Arguments

- contributors_table:

  the imported contributors_table

## Value

The function returns a dataframe with abbreviated middle names.
