# Format a single row identifier for display

Formats a row identifier using surname (or firstname as fallback) and
order in publication. Falls back gracefully when data is missing.

## Usage

``` r
format_row_identifier(row_data)
```

## Arguments

- row_data:

  A single-row dataframe containing contributor information.

## Value

A formatted string like "Smith (order 3)", "John (order 3)" (if surname
missing), "Smith", "(order 3)", or "row X".
