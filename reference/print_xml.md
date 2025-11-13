# Generate an XML document of the contributions

The function generates an XML document that contains the contributors'
name, affiliation, CRediT roles, funding information, and conflict of
interest statements with a structure outlined in the JATS DTD
specifications. The output is generated from a `contributors_table`
based on the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).

## Usage

``` r
print_xml(
  contributors_table,
  full_document = FALSE,
  include_acknowledgees = FALSE,
  include_orcid = TRUE
)
```

## Arguments

- contributors_table:

  validated contributors_table

- full_document:

  Logical. If `TRUE`, generates a complete valid JATS XML document with
  placeholder metadata. If `FALSE` (default), returns only the
  contributor-related XML fragments (`<contrib-group>`, `<aff>`,
  `<funding-group>`, `<author-notes>`) that can be embedded in an
  existing JATS document.

- include_acknowledgees:

  Logical. If `TRUE`, includes contributors with "Acknowledgment only"
  in the `Author/Acknowledgee` column as a separate
  `<contrib-group content-type="acknowledgees">` section. Defaults to
  `FALSE`.

- include_orcid:

  Logical. If `TRUE` (default), includes ORCID IDs in the XML output as
  `<contrib-id contrib-id-type="orcid">` elements. If `FALSE`, ORCID IDs
  are excluded from the output.

## Value

If `full_document = FALSE` (default), returns an xml nodeset containing
the contributor-related fragments. If `full_document = TRUE`, returns a
complete valid JATS XML document with XML declaration and DOCTYPE.

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
print_xml(contributors_table = example_contributors_table)
#> {xml_document}
#> <article-meta>
#> [1] <contrib-group>\n  <contrib contrib-type="author" corresp="yes">\n    <na ...
#> [2] <aff id="aff1">\n  <label>1</label>\n  <institution>Institute of Psycholo ...
#> [3] <aff id="aff2">\n  <label>2</label>\n  <institution>LexCorp</institution> ...
#> [4] <aff id="aff3">\n  <label>3</label>\n  <institution>Institute for Interst ...
#> [5] <aff id="aff4">\n  <label>4</label>\n  <institution>Department of Psychol ...
#> [6] <aff id="aff5">\n  <label>5</label>\n  <institution>tenzing.club</institu ...
#> [7] <aff id="aff6">\n  <label>6</label>\n  <institution>Metropolis University ...
#> [8] <author-notes>\n  <corresp id="cor1">Correspondence to: <email>some@email ...
#> [9] <funding-group>\n  <award-group>\n    <funding-source>\n      <institutio ...
print_xml(contributors_table = example_contributors_table, full_document = TRUE)
#> {xml_document}
#> <article dtd-version="1.3" article-type="research-article" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:ali="http://www.niso.org/schemas/ali/1.0/">
#> [1] <front>\n  <journal-meta>\n    <journal-id journal-id-type="publisher-id" ...
print_xml(contributors_table = example_contributors_table, include_orcid = FALSE)
#> {xml_document}
#> <article-meta>
#> [1] <contrib-group>\n  <contrib contrib-type="author" corresp="yes">\n    <na ...
#> [2] <aff id="aff1">\n  <label>1</label>\n  <institution>Institute of Psycholo ...
#> [3] <aff id="aff2">\n  <label>2</label>\n  <institution>LexCorp</institution> ...
#> [4] <aff id="aff3">\n  <label>3</label>\n  <institution>Institute for Interst ...
#> [5] <aff id="aff4">\n  <label>4</label>\n  <institution>Department of Psychol ...
#> [6] <aff id="aff5">\n  <label>5</label>\n  <institution>tenzing.club</institu ...
#> [7] <aff id="aff6">\n  <label>6</label>\n  <institution>Metropolis University ...
#> [8] <author-notes>\n  <corresp id="cor1">Correspondence to: <email>some@email ...
#> [9] <funding-group>\n  <award-group>\n    <funding-source>\n      <institutio ...
```
