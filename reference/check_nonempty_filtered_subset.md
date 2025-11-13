# Check Non-Empty Filtered Contributor Subset

This function verifies that the filtered contributors table is not empty
after applying inclusion/exclusion criteria (e.g., include = "Author",
excluding "Don't agree to be named").

## Usage

``` r
check_nonempty_filtered_subset(contributors_table, context = NULL)
```

## Arguments

- contributors_table:

  A dataframe of contributors after filtering.

- context:

  Optional named list providing contextual information such as `include`
  ("author" or "acknowledgee").

## Value

A list containing:

- type:

  Type of validation result: "success" or "error".

- message:

  A descriptive validation message.
