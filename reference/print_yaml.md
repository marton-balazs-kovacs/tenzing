# Generate an YAML document of the contributions

The function generates a YAML document containing the contributors
information and contributions according to the CRediT taxonomy. The
output is generated from an `contributors_table` based on the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).

## Usage

``` r
print_yaml(contributors_table)
```

## Arguments

- contributors_table:

  validated contributors_table

## Value

The function returns a YAML document

## Warning

The function is primarily developed to be the part of a shiny app. As
the validation is handled inside of the app separately, the function can
break with non-informative errors if running locally without first
validating it.

## See also

Other output functions:
[`print_conflict_statement()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_conflict_statement.md),
[`print_credit_roles()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_credit_roles.md),
[`print_funding()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_funding.md),
[`print_title_page()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_title_page.md),
[`print_xml()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_xml.md)

## Examples

``` r
example_contributors_table <-
read_contributors_table(
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
print_yaml(contributors_table = example_contributors_table)
#> [1] "author:\n  John M. Smith:\n    name: John M. Smith\n    affiliation: '1,2,3'\n    role:\n      - Funding acquisition\n      - Visualization\n    corresponding: yes\n    email: some@email.com\n    address: Enter postal address here\n  Marton Kovacs:\n    name: Marton Kovacs\n    affiliation: '1,4,5'\n    role:\n      - Data curation\n      - Methodology\n      - .na.character\n    corresponding: no\n  Lex W. Luthor:\n    name: Lex W. Luthor\n    affiliation: '2,6'\n    role:\n      - Formal analysis\n      - Funding acquisition\n      - Software\n      - Supervision\n      - .na.character\n    corresponding: no\n  Alex O. Holcombe:\n    name: Alex O. Holcombe\n    affiliation: '7'\n    role:\n      - Conceptualization\n      - .na.character\n    corresponding: no\n  Peter Pan:\n    name: Peter Pan\n    affiliation: '8'\n    role: .na.character\n    corresponding: no\n\naffiliation:\n  - id: 1\n    institution: Institute of Psychology, ELTE Eotvos Lorand University, Budapest,\n      Hungary, Doctoral School of Psychology\n  - id: 2\n    institution: LexCorp, Smallville, Kansas, US\n  - id: 3\n    institution: Institute for Interstellar Relations, Oxbridge University, UK\n  - id: 4\n    institution: Department of Psychology\n  - id: 5\n    institution: tenzing.club\n  - id: 6\n    institution: Metropolis University\n  - id: 7\n    institution: The University of Sydney\n  - id: 8\n    institution: Neverland\n"
```
