# Validation Result Helper Functions

This module provides standardized helper functions for creating
validation results with consistent formatting and structure. Create a
standardized validation result

## Usage

``` r
create_validation_result(
  type,
  message,
  details = NULL,
  affected_rows = NULL,
  timestamp = NULL
)
```

## Arguments

- type:

  Character string indicating the validation result type. Must be one
  of: "success", "warning", "error".

- message:

  Character string with the validation message.

- details:

  Optional list with additional details about the validation.

- affected_rows:

  Optional vector of row numbers or identifiers affected.

- timestamp:

  Optional POSIXct timestamp (defaults to current time).

## Value

A list with standardized validation result structure.

## Details

This function creates a standardized validation result with consistent
structure, formatting, and optional metadata.
