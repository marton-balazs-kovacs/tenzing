# ColumnValidator Class for Contributors Table

ColumnValidator Class for Contributors Table

ColumnValidator Class for Contributors Table

## Details

The `ColumnValidator` class performs column-level validation for a
contributors table. It ensures that required columns exist, applying
logical validation rules such as:

- **AND**: All listed columns must be present.

- **OR**: At least one of the listed columns must be present.

- **NOT**: None of the listed columns should be present.

This validation process is **configurable** via a YAML file.

## Regex Matching

Some columns may follow a dynamic naming pattern (e.g., "Affiliation 1",
"Affiliation 2"). The `regex` field in the YAML configuration allows
**pattern-based matching**.

## YAML Configuration

The validator reads a YAML file (e.g.,
`inst/config/column_validation.yaml`) that defines:

- **Rules** specifying required columns.

- **Operators** (`AND`, `OR`, `NOT`) for column validation.

- **Regex patterns** for dynamically named columns.

- **Severity levels** (`error` or `warning`).

Example:

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

## Integration with ValidateOutput

The `ValidateOutput` class initializes an instance of `ColumnValidator`
to perform column checks. If required columns are missing, the
validation process halts, returning **only column validation errors**.

## Usage

    # Load a column validation config
    config <- yaml::read_yaml("inst/config/column_validation.yaml")

    # Create a ColumnValidator instance
    column_validator <- ColumnValidator$new(config_input = config$column_config)

    # Validate a contributors table
    results <- column_validator$validate_columns(contributors_table)

## See also

[`ValidateOutput`](https://marton-balazs-kovacs.github.io/tenzing/reference/ValidateOutput.md)
which integrates this class for validation.

## Public fields

- `config`:

  Stores the column validation rules loaded from the YAML file.

## Methods

### Public methods

- [`ColumnValidator$new()`](#method-ColumnValidator-new)

- [`ColumnValidator$validate_columns()`](#method-ColumnValidator-validate_columns)

- [`ColumnValidator$check_rule()`](#method-ColumnValidator-check_rule)

- [`ColumnValidator$clone()`](#method-ColumnValidator-clone)

------------------------------------------------------------------------

### Method `new()`

Initializes the `ColumnValidator` class.

#### Usage

    ColumnValidator$new(config_input)

#### Arguments

- `config_input`:

  A parsed YAML configuration containing column validation rules.

------------------------------------------------------------------------

### Method `validate_columns()`

Validates columns in the provided contributors table.

#### Usage

    ColumnValidator$validate_columns(contributors_table)

#### Arguments

- `contributors_table`:

  A dataframe containing contributor data.

#### Returns

A list of validation results, each containing:

- `type`: `"error"`, `"warning"`, or `"success"`.

- `message`: A descriptive validation message.

------------------------------------------------------------------------

### Method `check_rule()`

Checks whether the contributors table satisfies a specific validation
rule.

#### Usage

    ColumnValidator$check_rule(contributors_table, rule, rule_name)

#### Arguments

- `contributors_table`:

  A dataframe containing contributor data.

- `rule`:

  A validation rule from the YAML configuration.

- `rule_name`:

  The name of the validation rule.

#### Returns

A validation result indicating whether the rule passed or failed.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ColumnValidator$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
