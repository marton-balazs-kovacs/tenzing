# Validator Class for Contributors Table

Validator Class for Contributors Table

Validator Class for Contributors Table

## Details

The `Validator` class runs a set of user-defined validation functions on
a contributors table. It allows for configuring which validations should
be executed, handling dependencies between validations, evaluating
context-aware conditions, and storing results.

This class is used in conjunction with the
[`ValidateOutput`](https://marton-balazs-kovacs.github.io/tenzing/reference/ValidateOutput.md)
class to apply both column-level and data-level validation.

## Configurable Validations

The class loads validation functions explicitly, ensuring they are
available in all environments. By default, the predefined functions in
`validate_helpers.R` are loaded.

## Dependencies

Some validations depend on the presence of specific columns or
successful execution of other validations. These dependencies are
defined in a YAML config file and evaluated dynamically during runtime.

## Context-Aware Validation

The validator supports an optional **context** parameter, which can hold
additional information about the environment in which validation is run.

This allows validation logic and dependency conditions to react to
dynamic UI states or user selections (e.g., `"include" = "author"`,
`"order" = "desc"`).

The `context` object is a named list accessible inside dependencies and
validation functions, enabling conditional validation rules.

Example use cases:

- Running separate validations for authors vs. acknowledgees.

- Changing which checks run depending on toggle inputs in a Shiny app.

- Adjusting severity or skipping certain checks dynamically.

## YAML Configuration

The validator reads a YAML configuration file (e.g.,
`inst/config/validator_example.yaml`), which specifies:

- The **validations to run**.

- Any **dependencies** between them.

Example:

    validation_config:
      validations:
        - name: check_missing_corresponding
          dependencies:
            - '"Corresponding author?" 
        - name: check_missing_email
          dependencies:
            - '"Corresponding author?" 
            - 'self$results[["check_missing_corresponding"]]$type == "success"'
            - '"Email address" 
        - name: check_subset_specific_rule
          dependencies:
            - 'context$include == "author"'

## Usage

    # Create a Validator instance
    validator <- Validator$new()

    # Configure which validations should run
    validator$setup_validator(validation_config)

    # Run the validations on a contributors table with optional context
    context <- list(include = "author", order_by = "desc")
    results <- validator$run_validations(contributors_table, context = context)

    # Access validation results
    print(results)

## Notes

- If no `context` is provided, all validations run as before
  (backward-compatible).

- Validation helpers can optionally define a `context` argument to
  access contextual data.

- Within YAML dependency conditions, the `context` object is
  automatically available.

## See also

- [`ValidateOutput`](https://marton-balazs-kovacs.github.io/tenzing/reference/ValidateOutput.md)
  — integrates the `Validator` and `ColumnValidator` classes.

- [`ColumnValidator`](https://marton-balazs-kovacs.github.io/tenzing/reference/ColumnValidator.md)
  — ensures required columns exist before data validations.

## Public fields

- `validations`:

  A list of validation functions explicitly loaded from
  `validate_helpers.R` or custom functions.

- `dependencies`:

  A list of validation dependencies.

- `results`:

  Stores the results of executed validations.

- `specified_validations`:

  The subset of validations to execute, defined in the YAML config.

- `context`:

  hold runtime context parameters (UI/state toggles etc.)

## Methods

### Public methods

- [`Validator$new()`](#method-Validator-new)

- [`Validator$load_validation_functions()`](#method-Validator-load_validation_functions)

- [`Validator$add_dependency()`](#method-Validator-add_dependency)

- [`Validator$setup_validator()`](#method-Validator-setup_validator)

- [`Validator$run_validations()`](#method-Validator-run_validations)

- [`Validator$should_run()`](#method-Validator-should_run)

- [`Validator$clone()`](#method-Validator-clone)

------------------------------------------------------------------------

### Method `new()`

Initializes the `Validator` class. Loads validation functions explicitly
from `validate_helpers.R` and allows for adding custom validations.

#### Usage

    Validator$new()

------------------------------------------------------------------------

### Method `load_validation_functions()`

Loads validation functions explicitly. This ensures all validation
functions are available in all environments.

#### Usage

    Validator$load_validation_functions()

#### Returns

A list of validation functions

------------------------------------------------------------------------

### Method `add_dependency()`

Adds dependencies for a validation.

#### Usage

    Validator$add_dependency(validation_name, conditions)

#### Arguments

- `validation_name`:

  The name of the validation.

- `conditions`:

  A list of conditions that must be met before running the validation.

------------------------------------------------------------------------

### Method `setup_validator()`

Configures the validator with the subset of validations to execute.

#### Usage

    Validator$setup_validator(validation_config)

#### Arguments

- `validation_config`:

  A list defining which validations to run and their dependencies.

------------------------------------------------------------------------

### Method `run_validations()`

Runs the specified validations on the provided contributors table.

#### Usage

    Validator$run_validations(contributors_table, context = NULL)

#### Arguments

- `contributors_table`:

  A dataframe containing contributor data.

- `context`:

  Optional context parameters for dynamic validation.

#### Returns

A list of validation results.

------------------------------------------------------------------------

### Method `should_run()`

Determines whether a validation should be executed based on
dependencies.

#### Usage

    Validator$should_run(validation_name, contributors_table)

#### Arguments

- `validation_name`:

  The validation function name.

- `contributors_table`:

  The dataframe containing contributor data.

#### Returns

TRUE if the validation should run, FALSE otherwise.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Validator$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
