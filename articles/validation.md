# Custom Validation in tenzing

This vignette provides a step-by-step guide on how to create and apply
custom validation rules in **tenzing**. The validation framework in
**tenzing** is based on R6 classes that allow for flexible and
configurable validation of contributor tables.

## Overview

The validation system in **tenzing** consists of three main components:

- `ColumnValidator` – Ensures that required columns exist in the
  contributors table.
- `Validator` – Runs logical checks on the contents of the table (e.g.,
  missing values, duplicate names).
- `ValidateOutput` – Combines column and data validation, allowing for
  customized validation pipelines using `YAML` configuration files.

By leveraging these components, you can create your own validation rules
to check for specific issues in your data.

## 1. Defining Custom Validation Rules

Validation rules are written as functions in **tenzing**. These
functions should take the `contributors_table` as input and return a
list with two elements:

- `type`: Can be “success”, “warning”, or “error”, indicating the result
  of the check.
- `message`: A user-friendly explanation of the check result.

## Example: Custom Validation Function

Let’s say you want to create a check that ensures every contributor has
a valid ORCID ID.

``` r
#' Check for valid ORCID IDs
#'
#' This function checks if the ORCID IDs in the `contributors_table` are formatted correctly.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success", "warning", or "error".}
#' \item{message}{An informative message indicating if any ORCID IDs are invalid.}
check_orcid <- function(contributors_table) {
  if (!"ORCID" %in% colnames(contributors_table)) {
    return(list(
      type = "warning",
      message = "No ORCID column found. ORCID validation skipped."
    ))
  }
  
  invalid_orcids <- contributors_table %>%
    dplyr::filter(!grepl("^\\d{4}-\\d{4}-\\d{4}-\\d{4}$", .data$ORCID) & !is.na(.data$ORCID))
  
  if (nrow(invalid_orcids) > 0) {
    return(list(
      type = "warning",
      message = glue::glue("Invalid ORCID format for the following rows: {paste(invalid_orcids$rowname, collapse = ', ')}")
    ))
  }
  
  return(list(type = "success", message = "All ORCID IDs are correctly formatted."))
}
```

## 2. Understanding the Configuration System

**tenzing** uses a clean, consistent configuration system where all
validation files follow the same structure:

- **General column validation**: `column_validation.yaml` for
  comprehensive column checking
- **Output-specific validation**: Files like `title_validation.yaml` for
  specific output types  
- **Consistent structure**: All configs use `column_config` and
  `validation_config` sections
- **Easy customization**: You can create custom configurations or extend
  existing ones

**tenzing** includes a set of predefined validation helpers in
`R/validate_helpers.R`. These include: - `check_missing_order` – Ensures
that all contributors have an order in the publication. -
`check_duplicate_order` – Ensures no duplicate order numbers unless
multiple first authors exist. - `check_missing_surname` – Ensures all
contributors have a surname. - `check_duplicate_names` – Ensures no
duplicate contributor names. - `check_affiliation_consistency` – Ensures
only one affiliation format is used. - Many more…

These functions are automatically available when setting up validation
in **tenzing**.

### Understanding General vs Output-Specific Validation

**tenzing** uses two types of validation:

1.  **General Column Validation** (`column_validation.yaml`):
    - Checks all possible columns that might be needed across different
      outputs
    - Runs before any output-specific validation
2.  **Output-Specific Validation** (e.g., `title_validation.yaml`):
    - Checks columns and data specific to a particular output type
    - Used by `ValidateOutput` class for detailed validation
    - Runs after general column validation passes

### Using Predefined Configuration Files

**tenzing** provides ready-to-use configuration files for common output
types:

``` r
# List available configuration files
config_dir <- system.file("config", package = "tenzing")
list.files(config_dir, pattern = "*_validation\\.yaml$")
#> [1] "base_validation.yaml"    "coi_validation.yaml"    
#> [3] "column_validation.yaml"  "credit_validation.yaml" 
#> [5] "funding_validation.yaml" "title_validation.yaml"  
#> [7] "xml_validation.yaml"     "yaml_validation.yaml"
```

Each configuration file specifies both: 1. **Column validation rules**:
Which columns are required 2. **Data validation functions**: Which
checks to perform

#### Example: Using the Title Page Configuration

The `title_validation.yaml` file includes validation for title page
outputs:

``` r
# Load the title validation configuration
title_config_path <- system.file("config/title_validation.yaml", package = "tenzing")
title_config <- yaml::read_yaml(title_config_path)

# View the column rules
title_config$column_config$rules

# View the validation functions
purrr::map_chr(title_config$validation_config$validations, "name")
```

### Creating Custom Configurations

You can create your own validation configuration file with custom rules
and validations.

#### Example: Creating a Custom Configuration with ORCID Validation

First, create a YAML configuration file (e.g.,
`my_custom_validation.yaml`):

    column_config:
      rules:
        minimal_rule:
          operator: "AND"
          columns:
            - Firstname
            - Middle name
            - Surname
            - Order in publication
          severity: "error"
        orcid_rule:
          operator: "AND"
          columns:
            - ORCID
          severity: "warning"

    validation_config:
      validations:
        - name: check_missing_order
        - name: check_duplicate_order
        - name: check_missing_surname
        - name: check_missing_firstname
        - name: check_duplicate_initials
        - name: check_duplicate_names
        - name: check_orcid
          dependencies:
            - '"ORCID" %in% colnames(contributors_table)'

#### Writing Custom Dependencies

Some validations should only run if other conditions are met. You can
define dependencies in the `YAML` configuration file.

In the example above: - The `check_orcid` validation will only run if
the column `"ORCID"` exists. - Dependencies can check for column
existence, previous validation results, or context variables.

## 3. Running Validations

You can run validations using **tenzing’s** validation pipeline in two
ways:

### Method 1: Using ValidateOutput (Recommended)

The `ValidateOutput` class is the easiest way to run validations, as it
handles both column and data validation automatically.

#### Step 1: Initialize ValidateOutput with a Configuration

``` r
# Use a predefined configuration
config_path <- system.file("config/title_validation.yaml", package = "tenzing")

validate_output <- ValidateOutput$new(config_path = config_path)
```

#### Step 2: Run Validations

``` r
validate_results <- validate_output$run_validations(my_contributors_table)
```

#### Step 3: Inspect the Validation Results

``` r
# View validation types
purrr::map_chr(validate_results, "type")
#>                  minimal_rule              affiliation_rule 
#>                     "success"                     "success" 
#>                    title_rule           check_missing_order 
#>                     "success"                     "success" 
#>         check_duplicate_order         check_missing_surname 
#>                     "success"                     "success" 
#>       check_missing_firstname      check_duplicate_initials 
#>                     "success"                     "success" 
#>         check_duplicate_names   check_missing_corresponding 
#>                     "success"                     "success" 
#>           check_missing_email             check_affiliation 
#>                     "success"                     "success" 
#> check_affiliation_consistency           check_missing_orcid 
#>                     "success"                     "warning"
```

``` r
# View validation messages
purrr::map_chr(validate_results, "message")
#>                                                                       minimal_rule 
#>                                               "All column requirements satisfied." 
#>                                                                   affiliation_rule 
#>                                               "All column requirements satisfied." 
#>                                                                         title_rule 
#>                                               "All column requirements satisfied." 
#>                                                                check_missing_order 
#>                         "There are no missing values in the order of publication." 
#>                                                              check_duplicate_order 
#>                 "There are no duplicated order numbers in the contributors_table." 
#>                                                              check_missing_surname 
#>                                                   "There are no missing surnames." 
#>                                                            check_missing_firstname 
#>                                                 "There are no missing firstnames." 
#>                                                           check_duplicate_initials 
#>                       "There are no duplicate initials in the contributors_table." 
#>                                                              check_duplicate_names 
#>                          "There are no duplicate names in the contributors_table." 
#>                                                        check_missing_corresponding 
#>                  "There is at least one author indicated as corresponding author." 
#>                                                                check_missing_email 
#>                "There are email addresses provided for all corresponding authors." 
#>                                                                  check_affiliation 
#>                     "There are no missing affiliations in the contributors_table." 
#>                                                      check_affiliation_consistency 
#>                                  "Affiliation column names are used consistently." 
#>                                                                check_missing_orcid 
#> "The ORCID iD is missing for: Smith (order 1), Luthor (order 2) and Pan (order 4)"
```

### Method 2: Using Validator Directly

For more control, you can use the `Validator` class directly.

#### Step 1: Load the Configuration

``` r
config_path <- system.file("config/title_validation.yaml", package = "tenzing")
config_file <- yaml::read_yaml(config_path)
```

#### Step 2: Initialize the `Validator` class

``` r
validator <- Validator$new()

validator$setup_validator(config_file$validation_config)
```

#### Step 3: Run Validations on Your Data

``` r
validate_results <- validator$run_validations(contributors_table = my_contributors_table)
```

#### Step 4: Inspect the Validation Results

``` r
purrr::map_chr(validate_results, "type")
#>           check_missing_order         check_duplicate_order 
#>                     "success"                     "success" 
#>         check_missing_surname       check_missing_firstname 
#>                     "success"                     "success" 
#>      check_duplicate_initials         check_duplicate_names 
#>                     "success"                     "success" 
#>   check_missing_corresponding           check_missing_email 
#>                     "success"                     "success" 
#>             check_affiliation check_affiliation_consistency 
#>                     "success"                     "success" 
#>           check_missing_orcid 
#>                     "warning"
```

``` r
purrr::map_chr(validate_results, "message")
#>                                                                check_missing_order 
#>                         "There are no missing values in the order of publication." 
#>                                                              check_duplicate_order 
#>                 "There are no duplicated order numbers in the contributors_table." 
#>                                                              check_missing_surname 
#>                                                   "There are no missing surnames." 
#>                                                            check_missing_firstname 
#>                                                 "There are no missing firstnames." 
#>                                                           check_duplicate_initials 
#>                       "There are no duplicate initials in the contributors_table." 
#>                                                              check_duplicate_names 
#>                          "There are no duplicate names in the contributors_table." 
#>                                                        check_missing_corresponding 
#>                  "There is at least one author indicated as corresponding author." 
#>                                                                check_missing_email 
#>                "There are email addresses provided for all corresponding authors." 
#>                                                                  check_affiliation 
#>                     "There are no missing affiliations in the contributors_table." 
#>                                                      check_affiliation_consistency 
#>                                  "Affiliation column names are used consistently." 
#>                                                                check_missing_orcid 
#> "The ORCID iD is missing for: Smith (order 1), Luthor (order 2) and Pan (order 4)"
```

## 4. Understanding the Validation Classes

### The `Validator` Class

The `Validator` class in **tenzing** is responsible for running all data
validation checks.

Key Features of `Validator`:

- It loads validation functions explicitly from `validate_helpers.R`,
  ensuring they work in all environments.
- It allows adding dependencies between validation rules.
- It executes only the specified validations from the configuration.
- It supports context-aware validation for dynamic UI states.

### The `ColumnValidator` Class

The `ColumnValidator` class ensures that all necessary columns are
present before running validations.

Key Features of `ColumnValidator`:

- Supports logical operators: `AND`, `OR`, `NOT` for column
  requirements.
- Supports regex patterns for dynamically named columns.
- Supports severity levels: `error` or `warning`.

### The `ValidateOutput` Class

The `ValidateOutput` class integrates both `ColumnValidator` and
`Validator` into a single, easy-to-use interface.

Key Features of `ValidateOutput`:

- Automatically runs column validation before data validation.
- Returns only column validation errors if critical columns are missing.
- Supports optional context parameters for dynamic validation.

## 5. Column Validation Examples

The `ColumnValidator` class ensures that all necessary columns are
present before running validations.

### Example: Understanding Column Validation Rules

Let’s examine the column validation rules in the title configuration:

``` r
config_path <- system.file("config/title_validation.yaml", package = "tenzing")
config <- yaml::read_yaml(config_path)

# View the column rules
config$column_config$rules
#> $minimal_rule
#> $minimal_rule$operator
#> [1] "AND"
#> 
#> $minimal_rule$columns
#> [1] "Firstname"            "Middle name"          "Surname"             
#> [4] "Order in publication"
#> 
#> $minimal_rule$severity
#> [1] "error"
#> 
#> 
#> $affiliation_rule
#> $affiliation_rule$operator
#> [1] "OR"
#> 
#> $affiliation_rule$columns
#> [1] "Primary affiliation"   "Secondary affiliation"
#> 
#> $affiliation_rule$regex
#> [1] "^Affiliation [0-9]+$"
#> 
#> $affiliation_rule$severity
#> [1] "error"
#> 
#> 
#> $title_rule
#> $title_rule$operator
#> [1] "AND"
#> 
#> $title_rule$columns
#> [1] "Corresponding author?" "Email address"        
#> 
#> $title_rule$severity
#> [1] "warning"
```

The configuration defines several rules:

1.  **`minimal_rule`**: Requires basic contributor information
    (Firstname, Middle name, Surname, Order in publication) with `AND`
    operator (all must be present).

2.  **`affiliation_rule`**: Requires at least one affiliation column
    (using `OR` operator) and supports both legacy columns
    (`Primary affiliation`, `Secondary affiliation`) and regex-based
    columns matching `^Affiliation [0-9]+$`.

3.  **`title_rule`**: Requires corresponding author information (Both
    `Corresponding author?` and `Email address` must be present).

### Using Regex to Validate Column Names

You can define **regex-based column validation** to match dynamically
named columns, which is useful for scenarios like multiple affiliation
columns.

#### Example: Regex for Affiliation Columns

The affiliation rule uses both legacy columns and regex:

``` yaml
affiliation_rule:
  operator: "OR"
  columns:
    - Primary affiliation
    - Secondary affiliation
  regex: "^Affiliation [0-9]+$"
  severity: "error"
```

This configuration: - Requires at least one affiliation column. -
Matches legacy columns (`Primary affiliation`,
`Secondary affiliation`). - Matches dynamic columns (e.g.,
`Affiliation 1`, `Affiliation 2`, etc.) using regex. - Fails validation
if no affiliation column exists.

### Running ColumnValidator Independently

You can run column validation independently to check column
requirements:

``` r
config_path <- system.file("config/title_validation.yaml", package = "tenzing")
config <- yaml::read_yaml(config_path)

column_validator <- ColumnValidator$new(config_input = config$column_config)

column_results <- column_validator$validate_columns(my_contributors_table)

# View results
purrr::map_chr(column_results, "type")
#>     minimal_rule affiliation_rule       title_rule 
#>        "success"        "success"        "success"
```

``` r
purrr::map_chr(column_results, "message")
#>                         minimal_rule                     affiliation_rule 
#> "All column requirements satisfied." "All column requirements satisfied." 
#>                           title_rule 
#> "All column requirements satisfied."
```

## 6. Using ValidateOutput for Complete Validation

The `ValidateOutput` class integrates both `ColumnValidator` and
`Validator` into a unified validation pipeline.

### How ValidateOutput Works

1.  Reads the configuration file (either from a path or with base config
    merging).

2.  Runs `ColumnValidator` to check required columns (stops early if
    critical columns are missing).

3.  Runs `Validator` to check data integrity (only if column validation
    passes).

4.  Returns the combined results from both validation stages.

### Example: Using Predefined Configurations

``` r
# Title page validation
title_config <- system.file("config/title_validation.yaml", package = "tenzing")
validate_output <- ValidateOutput$new(config_path = title_config)

validate_results <- validate_output$run_validations(my_contributors_table)

# Check for any errors
has_errors <- any(purrr::map_chr(validate_results, "type") == "error")
has_errors
#> [1] FALSE
```

### Example: Using Context-Aware Validation

Some validations can use context information (e.g., user selections in a
Shiny app):

``` r
# Create context for filtering
context <- list(include = "author", order_by = "contributor", pub_order = "asc")

# Run validation with context
validate_results <- validate_output$run_validations(
  my_contributors_table, 
  context = context
)
```

The context allows validations to react to dynamic UI states, such as: -
Filtering by author vs. acknowledgee - Different ordering preferences -
User-selected output options

## 7. Configuration Management

### Configuration Utilities

**tenzing** provides utility functions for configuration management:

``` r
# Clear configuration cache
clear_config_cache()

# Get cache statistics
get_cache_stats()

# Validate configuration schema
validate_config_schema(config)
```

### Best Practices

1.  **Start with predefined configurations**: Use
    `title_validation.yaml`, `credit_validation.yaml`, etc., as starting
    points.

2.  **Use the two-tier approach**: Run general column validation first,
    then output-specific validation.

3.  **Use dependencies wisely**: Only add dependencies when validations
    truly depend on each other or column presence.

4.  **Test your configurations**: Ensure your custom validations work
    correctly before using them in production.

## 8. Summary

- **Define custom validation functions** that return lists with `type`
  and `message`.
- **Use the two-tier validation approach**: General column validation
  first, then output-specific validation.
- **Use predefined configuration files** for common output types (title,
  credit, yaml, etc.).
- **Create custom YAML configurations** following the consistent
  `column_config` and `validation_config` structure.
- **Use `ColumnValidator`** to enforce required columns before data
  validation.
- **Use `Validator`** to run content-based validation checks.
- **Use `ValidateOutput`** for the easiest integration of column and
  data validation.
- **Leverage the clean configuration system** for consistency and
  maintainability.
