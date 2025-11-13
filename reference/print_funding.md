# Generate human readable report of the funding information

The functions generates the funding information section of the
manuscript. The output is generated from an contributors_table based on
the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).

## Usage

``` r
print_funding(contributors_table, initials = FALSE)
```

## Arguments

- contributors_table:

  validated contributors_table

- initials:

  Logical. If true initials will be included instead of full names in
  the output

## Value

The function returns a string.

## See also

Other output functions:
[`print_conflict_statement()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_conflict_statement.md),
[`print_credit_roles()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_credit_roles.md),
[`print_title_page()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_title_page.md),
[`print_xml()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_xml.md),
[`print_yaml()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_yaml.md)

## Examples

``` r
example_contributors_table <- read_contributors_table(
contributors_table = system.file("extdata",
"contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#> Rows: 5 Columns: 28
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (11): Author/Acknowledgee, Firstname, Middle name, Surname, Affiliation ...
#> dbl  (1): Order in publication
#> lgl (16): Conceptualization, Data curation, Formal analysis, Funding acquisi...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
print_funding(contributors_table = example_contributors_table, initials = FALSE)
#> [1] "Alex O. Holcombe was supported by Australian Fund; John M. Smith and Lex W. Luthor were supported by Important Fund; Marton Kovacs was supported by National Funding Agency."
```
