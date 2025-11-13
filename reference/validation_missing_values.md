# Create a validation result for missing values

Create a validation result for missing values

## Usage

``` r
validation_missing_values(column_name, missing_rows_df, severity = "warning")
```

## Arguments

- column_name:

  Name of the column with missing values.

- missing_rows_df:

  A dataframe containing the rows with missing values.

- severity:

  Severity level: "warning" or "error" (default: "warning").

## Value

A standardized validation result for missing values.
