# Warn about contributors left out because of an unclear Author/Acknowledgee value

Outputs that only list authors (title page, funding, conflict of
interest, YAML) exclude every row whose `Author/Acknowledgee` value is
not "Author". This check runs on the table *before* that filter and
tells the user which named contributors were excluded because their
value is blank or not one of the allowed values, so nobody disappears
silently. Tables without the `Author/Acknowledgee` column are fine: all
rows are treated as authors.

## Usage

``` r
check_excluded_unclear_author_status(contributors_table)
```

## Arguments

- contributors_table:

  The unfiltered contributors table.

## Value

A standardized validation result ("success" or "warning").
