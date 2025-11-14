# Package index

## Shiny App

Functions to use the shiny app

- [`run_app()`](https://marton-balazs-kovacs.github.io/tenzing/reference/run_app.md)
  : Run the Shiny Application

## Contributors table

Functions to load and test your contributors table

- [`contributors_table_template`](https://marton-balazs-kovacs.github.io/tenzing/reference/contributors_table_template.md)
  : Template for the contributors table
- [`read_contributors_table()`](https://marton-balazs-kovacs.github.io/tenzing/reference/read_contributors_table.md)
  : Read the filled out contributors_table
- [`validate_contributors_table()`](https://marton-balazs-kovacs.github.io/tenzing/reference/validate_contributors_table.md)
  : Validating the contributors table
- [`clean_contributors_table()`](https://marton-balazs-kovacs.github.io/tenzing/reference/clean_contributors_table.md)
  : Delete empty rows of the contributors_table

## Generate Output

Functions to generate outputs

- [`print_title_page()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_title_page.md)
  : Generate title page
- [`print_credit_roles()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_credit_roles.md)
  : Generate report of the contributions with CRedit
- [`print_xml()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_xml.md)
  : Generate an XML document of the contributions
- [`print_yaml()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_yaml.md)
  : Generate an YAML document of the contributions
- [`print_funding()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_funding.md)
  : Generate human readable report of the funding information
- [`print_conflict_statement()`](https://marton-balazs-kovacs.github.io/tenzing/reference/print_conflict_statement.md)
  : Generate human readable report of the conflict of interest
  statements

## Initials

Functions to turn full names into initials

- [`add_initials()`](https://marton-balazs-kovacs.github.io/tenzing/reference/add_initials.md)
  : Add initials to the contributors_table
- [`abbreviate()`](https://marton-balazs-kovacs.github.io/tenzing/reference/abbreviate.md)
  : Abbreviate names
- [`abbreviate_middle_names_df()`](https://marton-balazs-kovacs.github.io/tenzing/reference/abbreviate_middle_names_df.md)
  : Abbreviate middle names in a dataframe

## Validation Classes

Classes to manage table validation

- [`Validator`](https://marton-balazs-kovacs.github.io/tenzing/reference/Validator.md)
  : Validator Class for Contributors Table
- [`ColumnValidator`](https://marton-balazs-kovacs.github.io/tenzing/reference/ColumnValidator.md)
  : ColumnValidator Class for Contributors Table
- [`ValidateOutput`](https://marton-balazs-kovacs.github.io/tenzing/reference/ValidateOutput.md)
  : ValidateOutput Class for Contributors Table Validation

## Validation Helpers

Functions for custom validation checks

- [`check_affiliation()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_affiliation.md)
  : Check for Missing Affiliations
- [`check_affiliation_consistency()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_affiliation_consistency.md)
  : Check affiliation columns for consistency
- [`check_author_acknowledgee_missing()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_author_acknowledgee_missing.md)
  : Warn when 'Author/Acknowledgee' column is missing
- [`check_author_acknowledgee_values()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_author_acknowledgee_values.md)
  : Check allowed values in Author/Acknowledgee
- [`check_coi()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_coi.md)
  : Check for Missing Conflict of Interest Statements
- [`check_coi_column_rename()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_coi_column_rename.md)
  : Check for Old Conflict of Interest Column Name
- [`check_corresponding_non_author()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_corresponding_non_author.md)
  : Check that only Authors are marked as Corresponding
- [`check_credit()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_credit.md)
  : Check for Contributors with No CRediT Roles
- [`check_duplicate_initials()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_duplicate_initials.md)
  : Check for Duplicate Initials
- [`check_duplicate_names()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_duplicate_names.md)
  : Check for Duplicate Names
- [`check_duplicate_order()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_duplicate_order.md)
  : Check for Duplicate Order Numbers
- [`check_missing_author_acknowledgee()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_author_acknowledgee.md)
  : Check missing Author/Acknowledgee where names are present
- [`check_missing_corresponding()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_corresponding.md)
  : Check for Missing Corresponding Author
- [`check_missing_email()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_email.md)
  : Check for Missing Emails for Corresponding Authors
- [`check_missing_firstname()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_firstname.md)
  : Check for Missing First Names
- [`check_missing_orcid()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_orcid.md)
  : Check for Missing ORCID IDs
- [`check_missing_order()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_order.md)
  : Check for Missing Values in the Order of Publication
- [`check_missing_surname()`](https://marton-balazs-kovacs.github.io/tenzing/reference/check_missing_surname.md)
  : Check for Missing Surnames

## Configuration

Functions for managing validation configurations

- [`clear_config_cache()`](https://marton-balazs-kovacs.github.io/tenzing/reference/clear_config_cache.md)
  : Clear configuration cache
- [`get_cache_stats()`](https://marton-balazs-kovacs.github.io/tenzing/reference/get_cache_stats.md)
  : Get cache statistics
- [`validate_config_schema()`](https://marton-balazs-kovacs.github.io/tenzing/reference/validate_config_schema.md)
  : Validate YAML configuration structure

## Rename

Functions and datafiles that were renamed

- [`validate_infosheet()`](https://marton-balazs-kovacs.github.io/tenzing/reference/rename.md)
  [`read_infosheet()`](https://marton-balazs-kovacs.github.io/tenzing/reference/rename.md)
  [`clean_infosheet()`](https://marton-balazs-kovacs.github.io/tenzing/reference/rename.md)
  [`print_roles_readable()`](https://marton-balazs-kovacs.github.io/tenzing/reference/rename.md)
  [`print_contrib_affil()`](https://marton-balazs-kovacs.github.io/tenzing/reference/rename.md)
  **\[deprecated\]** : Functions renamed in tenzing 0.2.0
