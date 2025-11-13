# Create a validation result for duplicate values

Create a validation result for duplicate values

## Usage

``` r
validation_duplicate_values(column_name, duplicate_rows, severity = "warning")
```

## Arguments

- column_name:

  Name of the column with duplicate values.

- duplicate_rows:

  List of vectors, each containing row numbers for a duplicate group.

- severity:

  Severity level: "warning" or "error" (default: "warning").

## Value

A standardized validation result for duplicate values.
