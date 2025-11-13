# Create a validation result for column requirements

Create a validation result for column requirements

## Usage

``` r
validation_missing_columns(
  missing_columns,
  required_columns,
  operator,
  severity = "error"
)
```

## Arguments

- missing_columns:

  Vector of missing column names.

- required_columns:

  Vector of all required column names.

- operator:

  The logical operator used ("AND", "OR", "NOT").

- severity:

  Severity level: "warning" or "error" (default: "error").

## Value

A standardized validation result for column requirements.
