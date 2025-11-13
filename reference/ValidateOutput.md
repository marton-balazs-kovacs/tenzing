# ValidateOutput Class for Contributors Table Validation

ValidateOutput Class for Contributors Table Validation

ValidateOutput Class for Contributors Table Validation

## Details

The `ValidateOutput` class runs both **column-based validation**
(ensuring required columns exist) and **data-based validation**
(checking correctness of values) for a contributors table.

It integrates two validation classes:

- **[`ColumnValidator`](https://marton-balazs-kovacs.github.io/tenzing/reference/ColumnValidator.md)**:
  Ensures required columns are present.

- **[`Validator`](https://marton-balazs-kovacs.github.io/tenzing/reference/Validator.md)**:
  Runs content-based validation checks on contributor data.

This validation process is **configured via a YAML file**. The
`inst/config/` package directory contains predefined YAML configuration
files for each output type.

## Column Validation

The `ColumnValidator` ensures that required columns exist **before
running data-based checks**. If a required column is missing,
**validation stops immediately** with an error.

Example YAML Configuration (`inst/config/title_validation.yaml`):

    column_config:
      rules:
        minimal:
          operator: "AND"
          columns:
            - Firstname
            - Middle name
            - Surname
            - Order in publication
          severity: "error"

        affiliation:
          operator: "OR"
          columns:
            - Primary affiliation
            - Secondary affiliation
          regex: "^Affiliation [0-9]+$"
          severity: "error"

        title:
          operator: "AND"
          columns:
            - Corresponding author?
            - Email address
          severity: "warning"

## General Data Validation

The `Validator` runs content-based validation checks **after** column
validation passes.

Example Validation Configuration (`inst/config/title_validation.yaml`):

    validation_config:
      validations:
        - name: check_missing_order
        - name: check_duplicate_order
        - name: check_missing_surname
        - name: check_missing_firstname
        - name: check_duplicate_initials
        - name: check_missing_corresponding
          dependencies:
            - '"Corresponding author?" 
        - name: check_missing_email
          dependencies:
            - '"Corresponding author?" 
            - 'self$results[["check_missing_corresponding"]]$type == "success"'
            - '"Email address" 
        - name: check_duplicate_names
        - name: check_affiliation
        - name: check_affiliation_consistency

**Dependencies**:

- Some validation checks only run if other conditions are met.

- Example: `check_missing_email` only runs if:

  1.  `"Corresponding author?"` exists.

  2.  `check_missing_corresponding` has passed.

  3.  `"Email address"` is in the dataset.

## Integration

The class runs in the following order:

1.  **Column validation** (via `ColumnValidator`).

2.  **If columns are valid** → Run content validation (via `Validator`).

3.  **If column validation fails** → Stop and return column validation
    errors.

## Usage

    # Load a validation configuration file
    config_path <- system.file("config/title_validation.yaml", package = "tenzing")

    # Create a ValidateOutput instance
    validate_output <- ValidateOutput$new(config_path = config_path)

    # Run validation on the contributors table (no context)
    results <- validate_output$run_validations(contributors_table)

    # Or run with a context (e.g., UI presets for an output)
    ctx <- list(include = "author", order_by = "contributor", pub_order = "asc")
    results_ctx <- validate_output$run_validations(contributors_table, context = ctx)

## See also

[`ColumnValidator`](https://marton-balazs-kovacs.github.io/tenzing/reference/ColumnValidator.md),
[`Validator`](https://marton-balazs-kovacs.github.io/tenzing/reference/Validator.md)

## Public fields

- `validator`:

  Instance of the `Validator` class for data validation.

- `column_validator`:

  Instance of the `ColumnValidator` class for column validation.

- `config`:

  Stores the combined YAML validation configuration.

## Methods

### Public methods

- [`ValidateOutput$new()`](#method-ValidateOutput-new)

- [`ValidateOutput$run_validations()`](#method-ValidateOutput-run_validations)

- [`ValidateOutput$clone()`](#method-ValidateOutput-clone)

------------------------------------------------------------------------

### Method `new()`

Initializes the `ValidateOutput` class.

#### Usage

    ValidateOutput$new(config_path, use_base_config = TRUE, validate_schema = TRUE)

#### Arguments

- `config_path`:

  Path to the YAML configuration file.

- `use_base_config`:

  Whether to merge with base configuration (default: TRUE).

- `validate_schema`:

  Whether to validate the configuration schema (default: TRUE).

------------------------------------------------------------------------

### Method `run_validations()`

Runs both column and data validation on a contributors table.

#### Usage

    ValidateOutput$run_validations(contributors_table, context = NULL)

#### Arguments

- `contributors_table`:

  A dataframe containing contributor data.

- `context`:

  Optional named list providing contextual information for validations
  (e.g.,
  `list(include = "author", order_by = "role", pub_order = "asc")`).
  This is made available to validations via the `Validator` and can be
  used in YAML `dependencies` as `context$...`.

#### Returns

A named list of validation results. Each element is a list with:

- `type`: `"error"`, `"warning"`, or `"success"`.

- `message`: A descriptive validation message.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ValidateOutput$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
