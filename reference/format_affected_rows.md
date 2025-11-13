# Format affected rows for display

Takes a filtered dataframe and formats row identifiers for each row,
then collapses them with appropriate separators and capping.

## Usage

``` r
format_affected_rows(
  filtered_df,
  max_display = 10,
  collapse_sep = ", ",
  last_sep = " and "
)
```

## Arguments

- filtered_df:

  A dataframe containing the filtered rows to format.

- max_display:

  Maximum number of rows to display (default: 10).

- collapse_sep:

  Separator for collapsing multiple rows (default: ", ").

- last_sep:

  Separator for the last item (default: " and ").

## Value

Formatted string of affected rows.
