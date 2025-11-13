# Check allowed values in Author/Acknowledgee

Verifies that all entries in `Author/Acknowledgee` belong to the allowed
set: "Author", "Acknowledgment only", "Don't agree to be named".

## Usage

``` r
check_author_acknowledgee_values(contributors_table)
```

## Arguments

- contributors_table:

  A dataframe of contributors.

## Value

list(type = "success"\|"warning", message = )
