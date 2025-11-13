# Using tenzing as a package

If you do not want to use the **tenzing** app, you can use the package
from R to achieve the same outputs.

## Setup

First, you have to install the package.

``` r
# install.packages("devtools")
devtools::install_github("marton-balazs-kovacs/tenzing")
```

Second you have to load the package.

``` r
library(tenzing)
```

## Create your contributors table

The contributors table template is built in the package, as well as
uploaded to the
[net](https://docs.google.com/spreadsheets/d/1ay8pS-ftvfzWTrKCZr6Fa0cTLg3n8KxAOOleZmuE7Hs/edit?usp=sharing).
If you choose to fill out the template with your CRediT information
locally, you can write your contributors table as an xlsx file to your
working directory from the package with the following code:

``` r
# install.packages("writexl")
writexl::write_xlsx(contributors_table_template, "my_contributors_table.xlsx")
```

To get more information on the contributors table template use the
[`?tenzing::contributors_table_template`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md)
command.

*Note: This produces the same result as downloading the contributors
table template from the link provided before.*

*Note: The contributors table template was changed since the first
release, as some of the CRediT roles were not named properly in the
template columns.*

## Load your contributors table

You can load the contributors table into R with the
[`tenzing::read_contributors_table`](https://marton-balazs-kovacs.github.io/tenzing/reference/read_contributors_table.md)
function. This function accepts files with csv, tsv, xlsx extensions,
and the share URL of the Google spreadhseet. As an example we will use
the built in contributors table template.

``` r
file_path <- system.file("extdata", "contributors_table_example.csv", package = "tenzing", mustWork = TRUE)
my_contributors_table <- read_contributors_table(contributors_table_path = file_path)
#> Rows: 5 Columns: 28
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (11): Author/Acknowledgee, Firstname, Middle name, Surname, Affiliation ...
#> dbl  (1): Order in publication
#> lgl (16): Conceptualization, Data curation, Formal analysis, Funding acquisi...
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

If the read contributors table still contains empty rows you can clean
it with the `clean_contributors_table` function.

``` r
my_contributors_table <- clean_contributors_table(my_contributors_table)
```

## Validate your contributors table

Before generating outputs, you must check whether your
`contributors_table` is well-formatted. In **tenzing**, validation is
handled using two R6 classes:

- `ColumnValidator`: Ensures required columns exist.
- `Validator`: Runs logical and consistency checks on the data.

Both work based on **YAML configuration files**, allowing for flexible,
customizable validation pipelines. For a detailed explanation of
validation rules and configurations, please refer to the
`Validation Vignette`.

**tenzing** supports multiple output types, each requiring a properly
formatted `contributors_table.` You can use the `ValidateOutput` R6
class to check your table **against a specific configuration** for each
output.

For example, if you want to generate a **title page** for your
manuscript, you should first validate your table to ensure it meets the
required structure.

### 1. Load the Title Page Validation Configuration

``` r
config_path <- system.file("config/title_validation.yaml", package = "tenzing")
```

### 2. Initialize a Validation Instance

``` r
validate_output_instance <- ValidateOutput$new(config_path = config_path)
```

### 3. Run the Validation Checks

``` r
validate_results <- validate_output_instance$run_validations(contributors_table = my_contributors_table)
```

### 4. Review Validation Results

Each check returns one of three statuses:

- **success** – The check passed.
- **warning** – The table has issues that may affect output quality.
- **error** – The table is incorrectly formatted and must be fixed
  before generating output.

You can check the status of each validation:

``` r
purrr::map(validate_results, "type")
#> $minimal_rule
#> [1] "success"
#> 
#> $affiliation_rule
#> [1] "success"
#> 
#> $title_rule
#> [1] "success"
#> 
#> $check_missing_order
#> [1] "success"
#> 
#> $check_duplicate_order
#> [1] "success"
#> 
#> $check_missing_surname
#> [1] "success"
#> 
#> $check_missing_firstname
#> [1] "success"
#> 
#> $check_duplicate_initials
#> [1] "success"
#> 
#> $check_duplicate_names
#> [1] "success"
#> 
#> $check_missing_corresponding
#> [1] "success"
#> 
#> $check_missing_email
#> [1] "success"
#> 
#> $check_affiliation
#> [1] "success"
#> 
#> $check_affiliation_consistency
#> [1] "success"
#> 
#> $check_missing_orcid
#> [1] "warning"
```

And review the detailed messages for failed checks:

``` r
purrr::map(validate_results, "message")
#> $minimal_rule
#> [1] "All column requirements satisfied."
#> 
#> $affiliation_rule
#> [1] "All column requirements satisfied."
#> 
#> $title_rule
#> [1] "All column requirements satisfied."
#> 
#> $check_missing_order
#> [1] "There are no missing values in the order of publication."
#> 
#> $check_duplicate_order
#> [1] "There are no duplicated order numbers in the contributors_table."
#> 
#> $check_missing_surname
#> [1] "There are no missing surnames."
#> 
#> $check_missing_firstname
#> [1] "There are no missing firstnames."
#> 
#> $check_duplicate_initials
#> [1] "There are no duplicate initials in the contributors_table."
#> 
#> $check_duplicate_names
#> [1] "There are no duplicate names in the contributors_table."
#> 
#> $check_missing_corresponding
#> [1] "There is at least one author indicated as corresponding author."
#> 
#> $check_missing_email
#> [1] "There are email addresses provided for all corresponding authors."
#> 
#> $check_affiliation
#> [1] "There are no missing affiliations in the contributors_table."
#> 
#> $check_affiliation_consistency
#> [1] "Affiliation column names are used consistently."
#> 
#> $check_missing_orcid
#> [1] "The ORCID iD is missing for: Smith (order 1), Luthor (order 2) and Pan (order 4)"
```

## Generate output

If your contributors table is validated you can move on to output
generation. There are six different types of outputs that you can create
with the **tenzing** app.

For the human readable report and the contributors’ affiliation page the
output text will be rmarkdown formatted by default. However, by setting
the `text_format` argument to `"html"` the output can be HTML formatted
as well, or by setting the argument to `"raw"`, the output string will
not be formatted at all.

### create a human readable report of the contributions according to the CRediT taxonomy

For this section it is possible to use initials by setting the
`initials` argument `TRUE`. Also, if the `order_by` argument is set to
`contributor` the function will list the contributions after the name of
each researcher, instead of listing the appropriate names after each
CRediT role.

``` r
print_credit_roles(contributors_table = my_contributors_table, initials = TRUE, order_by = "contributor")
#> **M.K.:** Conceptualization, Funding acquisition, Methodology, and Supervision.  
#> **J.M.S.:** Funding acquisition and Resources.  
#> **L.W.L.:** Data curation, Project administration, Resources, Writing - original draft, and Writing - review & editing.
```

### Create the contributors’ affiliation page

``` r
print_title_page(contributors_table = my_contributors_table)
#> John M. Smith ^1,2,3\*†^, Marton Kovacs ^1,4,5\*^, Lex W. Luthor ^2,6^, Alex O. Holcombe ^7^, Peter Pan ^8^
#>    
#> ^1^Institute of Psychology, ELTE Eotvos Lorand University, Budapest, Hungary, Doctoral School of Psychology, ^2^LexCorp, Smallville, Kansas, US, ^3^Institute for Interstellar Relations, Oxbridge University, UK, ^4^Department of Psychology, ^5^tenzing.club, ^6^Metropolis University, ^7^The University of Sydney, ^8^Neverland                       
#>    
#> *John M. Smith and Marton Kovacs are shared first authors. ^†^ Correspondence should be addressed to John M. Smith; E-mail: some@email.com.
```

### Create a JATS formatted XML document containing the contributors information

``` r
print_xml(contributors_table = my_contributors_table)
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

### Create a YAML document containing the contributors informtation

This output can be incorporated into manuscript created with the
`papaja` package.

``` r
print_yaml(contributors_table = my_contributors_table)
#> [1] "author:\n  John M. Smith:\n    name: John M. Smith\n    affiliation: '1,2,3'\n    role:\n      - Funding acquisition\n      - Visualization\n    corresponding: yes\n    email: some@email.com\n    address: Enter postal address here\n  Marton Kovacs:\n    name: Marton Kovacs\n    affiliation: '1,4,5'\n    role:\n      - Data curation\n      - Methodology\n      - .na.character\n    corresponding: no\n  Lex W. Luthor:\n    name: Lex W. Luthor\n    affiliation: '2,6'\n    role:\n      - Formal analysis\n      - Funding acquisition\n      - Software\n      - Supervision\n      - .na.character\n    corresponding: no\n  Alex O. Holcombe:\n    name: Alex O. Holcombe\n    affiliation: '7'\n    role:\n      - Conceptualization\n      - .na.character\n    corresponding: no\n  Peter Pan:\n    name: Peter Pan\n    affiliation: '8'\n    role: .na.character\n    corresponding: no\n\naffiliation:\n  - id: 1\n    institution: Institute of Psychology, ELTE Eotvos Lorand University, Budapest,\n      Hungary, Doctoral School of Psychology\n  - id: 2\n    institution: LexCorp, Smallville, Kansas, US\n  - id: 3\n    institution: Institute for Interstellar Relations, Oxbridge University, UK\n  - id: 4\n    institution: Department of Psychology\n  - id: 5\n    institution: tenzing.club\n  - id: 6\n    institution: Metropolis University\n  - id: 7\n    institution: The University of Sydney\n  - id: 8\n    institution: Neverland\n"
```

### Create funding acknowledgements section

For this section it is possible to use initials by setting the
`initials` argument `TRUE`.

``` r
print_funding(contributors_table = my_contributors_table, initials = TRUE)
#> [1] "A.O.H. was supported by Australian Fund; J.M.S. and L.W.L. were supported by Important Fund; M.K. was supported by National Funding Agency."
```

### Create a conflict of interest statement

For this section it is possible to use the initials by setting the
`initials` argument `TRUE`.

``` r
print_conflict_statement(contributors_table = my_contributors_table, initials = FALSE)
#> [1] "John M. Smith, Marton Kovacs, Lex W. Luthor, Alex O. Holcombe, and Peter Pan declare no competing interest."
```
