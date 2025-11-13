# Collapse a character vector with oxford comma

Collapses a character vector into a length 1 vector, by using ", " as a
separator and adding the oxford comma if there original character vector
length is longer than 3. The function is from the cli package:
https://github.com/jonocarroll/cli/blob/2d3fbc4b41327df82df1102cdfc0a5c99822809b/R/inline.R

## Usage

``` r
glue_oxford_collapse(x)
```

## Arguments

- x:

  character, the vector to be collapsed

## Value

The function returns a vector of length 1.
