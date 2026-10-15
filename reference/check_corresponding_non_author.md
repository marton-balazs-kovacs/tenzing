# Check that only Authors are marked as Corresponding

Warns if a contributor is marked `Corresponding author? == TRUE` but is
not an author (`Author/Acknowledgee` is not "Author"). Outputs that list
the corresponding author only consider authors, so such a contributor
would not appear as corresponding author. Run it on the table *before*
any author-only filtering. Tables without the `Author/Acknowledgee` or
`Corresponding author?` column give nothing to report.

## Usage

``` r
check_corresponding_non_author(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe of contributors.

## Value

list(type = "success"\|"warning", message = )
