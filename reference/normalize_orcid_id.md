# Normalize ORCID ID to full URI format

Converts ORCID IDs to the standard format:
https://orcid.org/0000-0002-1825-0097

## Usage

``` r
normalize_orcid_id(orcid_id)
```

## Arguments

- orcid_id:

  character. ORCID ID in any format.

## Value

character. Normalized ORCID ID(s) as full URI.

## Details

Handles various input formats:

- Just the ID: `"0000-0002-1825-0097"` -\>
  `"https://orcid.org/0000-0002-1825-0097"`

- Already full URL: `"https://orcid.org/0000-0002-1825-0097"` -\>
  unchanged

- HTTP instead of HTTPS: `"http://orcid.org/0000-0002-1825-0097"` -\>
  `"https://orcid.org/0000-0002-1825-0097"`
