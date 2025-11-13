# Delete empty rows of the contributors_table

The function deletes any additional rows where all of the name columns
are empty.

## Usage

``` r
clean_contributors_table(contributors_table)
```

## Arguments

- contributors_table:

  the imported contributors_table

## Value

The function returns the contributors_table without empty additional
rows.
