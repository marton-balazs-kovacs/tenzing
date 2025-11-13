# Generate report of the contributions with CRedit

The function generates rmarkdown formatted text of the contributions
according to the CRediT taxonomy. The output is generated from an
`contributors_table` validated with the
[`validate_contributors_table()`](https://marton-balazs-kovacs.github.io/tenzing/reference/validate_contributors_table.md)
function. The `contributors_table` must be based on the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).
The function can return the output string as rmarkdown or html formatted
text or without any formatting.

## Usage

``` r
print_credit_roles(
  contributors_table,
  text_format = "rmd",
  initials = FALSE,
  order_by = "role",
  include = c("author", "acknowledgment"),
  pub_order = c("asc", "desc"),
  include_orcid = FALSE,
  orcid_style = c("badge", "text")
)
```

## Arguments

- contributors_table:

  Tibble. Validated contributors_table

- text_format:

  Character. Formatting of the returned string. Possible values: "rmd",
  "html", "raw". "rmd" by default.

- initials:

  Logical. If true initials will be included instead of full names in
  the output

- order_by:

  Character. Whether the contributing authors listed for each role
  ("role"), or the roles are listed after the name of each contributor
  ("contributor").

- include:

  Character. Filter which people to include:

  - "author" (keep rows where `Author/Acknowledgee` == "Author")

  - "acknowledgment" (keep rows where `Author/Acknowledgee` ==
    "Acknowledgment only") Rows with "Don't agree to be named" are
    always excluded.

- pub_order:

  Character. "asc" (default) or "desc" for `Order in publication`.

- include_orcid:

  Logical. If `TRUE`, append ORCID information after contributor names
  (as badges for HTML/Rmd, or plain text for raw output). Defaults to
  `FALSE`.

- orcid_style:

  Character. When ORCID inclusion is enabled, choose `"badge"` (default)
  to render the ORCID icon with a link, or `"text"` to render the
  normalized ORCID URL in parentheses after the name.

## Value

The function returns a string containing the CRediT roles with the
contributors listed for each role they partake in.

## Warning

The function is primarily developed to be the part of a shiny app. As
the validation is handled inside of the app separately, the function can
break with non-informative errors if running locally without first
validating it.

## See also

Other output functions:
[`print_conflict_statement()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_conflict_statement.md),
[`print_funding()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_funding.md),
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
print_credit_roles(contributors_table = example_contributors_table)
#> **Conceptualization:** Marton Kovacs.  
#> **Data curation:** Lex W. Luthor.  
#> **Funding acquisition:** John M. Smith and Marton Kovacs.  
#> **Methodology:** Marton Kovacs.  
#> **Project administration:** Lex W. Luthor.  
#> **Resources:** John M. Smith and Lex W. Luthor.  
#> **Supervision:** Marton Kovacs.  
#> **Writing - original draft:** Lex W. Luthor.  
#> **Writing - review & editing:** Lex W. Luthor.
```
