# Abbreviate names

Abbreviates multiple words to first letters

## Usage

``` r
abbreviate(string, collapse)
```

## Arguments

- string:

  Character. A character vector with the names

- collapse:

  Character. A string that will be used to separate names

## Value

Returns a character vector with one element.

## Examples

``` r
tenzing:::abbreviate("Franz Jude Wayne", collapse = "")
#> [1] "F.J.W."
```
