# Generate contrib-group XML node

Generate contrib-group XML node

## Usage

``` r
generate_contrib_group(
  contrib_data,
  affiliation_data,
  authors_only,
  contrib_type = "author",
  include_orcid = TRUE
)
```

## Arguments

- contrib_data:

  preprocessed contributors table with affiliations

- affiliation_data:

  vector of unique affiliations

- authors_only:

  full authors table for metadata

- contrib_type:

  character. Either "author" (default) or "acknowledgee"

- include_orcid:

  Logical. If `TRUE` (default), includes ORCID IDs in the output.
