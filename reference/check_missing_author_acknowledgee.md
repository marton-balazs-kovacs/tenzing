# Check missing Author/Acknowledgee where names are present

Warns if `Author/Acknowledgee` is missing for rows that have a name
(Firstname or Surname present).

## Usage

``` r
check_missing_author_acknowledgee(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe of contributors.

## Value

list(type = "success"\|"warning", message = )
