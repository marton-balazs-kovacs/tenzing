# Generate title page

The function generates rmarkdown formatted contributors' affiliation
text from an contributors_table. The contributors_table must be based on
the
[`contributors_table_template()`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md).
The function can return the output string as rmarkdown or html formatted
text or without any formatting.

## Usage

``` r
print_title_page(
  contributors_table,
  text_format = "rmd",
  include_orcid = FALSE,
  orcid_style = c("badge", "text")
)
```

## Arguments

- contributors_table:

  validated contributors_table

- text_format:

  formatting of the returned string. Possible values: "rmd", "html",
  "raw". "rmd" by default.

- include_orcid:

  Logical. Whether to include ORCID iD information. Default is FALSE.

- orcid_style:

  Character. Style for displaying ORCID iD. Either "badge" or "text".
  Default is "badge".

## Value

The output is string containing the contributors' name and the
corresponding affiliations in the the order defined by the
`Order in publication` column of the contributors_table.

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
print_title_page(contributors_table = example_contributors_table)
#> John M. Smith ^1,2,3\*†^, Marton Kovacs ^1,4,5\*^, Lex W. Luthor ^2,6^, Alex O. Holcombe ^7^, Peter Pan ^8^
#>    
#> ^1^Institute of Psychology, ELTE Eotvos Lorand University, Budapest, Hungary, Doctoral School of Psychology, ^2^LexCorp, Smallville, Kansas, US, ^3^Institute for Interstellar Relations, Oxbridge University, UK, ^4^Department of Psychology, ^5^tenzing.club, ^6^Metropolis University, ^7^The University of Sydney, ^8^Neverland                       
#>    
#> *John M. Smith and Marton Kovacs are shared first authors. ^†^ Correspondence should be addressed to John M. Smith; E-mail: some@email.com.
```
