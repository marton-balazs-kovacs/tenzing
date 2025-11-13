# Check that only Authors are marked as Corresponding

Warns if any row is marked `Corresponding author? == TRUE` while
`Author/Acknowledgee` is not "Author".

## Usage

``` r
check_corresponding_non_author(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe of contributors.

## Value

list(type = "success"\|"warning", message = )
