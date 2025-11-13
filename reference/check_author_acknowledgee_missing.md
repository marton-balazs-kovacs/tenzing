# Warn when 'Author/Acknowledgee' column is missing

Emits a single warning informing users that, when the column is absent,
the app treats all rows as authors and that adding the column enables a
separate acknowledgee statement.

## Usage

``` r
check_author_acknowledgee_missing(contributors_table, context = NULL)
```

## Arguments

- contributors_table:

  A dataframe of contributors.

- context:

  Optional named list (unused).

## Value

A standardized validation result list.
