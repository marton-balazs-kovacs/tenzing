
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tenzing

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Tenzing, an easy-to-use web-based app, allows researchers to generate
reports about the contribution of each team member on a project using
CRediT, for insertion into their manuscripts and for publishers to
potentially incorporate into article metadata.

[CRediT](https://www.casrai.org/credit.html) (Contributor Roles
Taxonomy) is a high-level taxonomy of 14 roles designed to represent the
roles typically played by contributors to scientific scholarly output.
The roles indicate each contributor’s contributions to a scholarly
project.

The app is named after the Nepali-Indian Sherpa Tenzing Norgay, who was
one of the two individuals who reached the summit of Mount Everest for
the first time. Despite his essential contribution, he received less
credit than his partner, the New Zealand mountaineer Edmund Hillary.

## Features

Tenzing can:

  - read all the necessary contributorship information from one file
    (.csv, .tsv or .xlsx)
  - create a report of the contributions
  - create the contributors’ affiliation information, designed for
    inclusion in the first page of a manuscript
  - create JATS XML with the contributions, suitable for publishers to
    include in metadata
  - create a YAML output that will automatically add the contributorship
    information to the `papaja`package used by some researchers to write
    APA-formatted manuscripts

## Usage

Tenzing can be used either via the web app or via R.

### Using the web app

You can use the app at
<https://martonbalazskovacs.shinyapps.io/tenzing/>.

You can alternatively run the app locally on your own computer by
following these instructions:

Install the development version (tenzing is not available from CRAN)
from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("marton-balazs-kovacs/tenzing")
```

Running the app.

``` r
tenzing::run_app()
```

You can read more on how to use the `tenzing` app in
`vignette("app_use")`.

### Using the pacakge

You can read more on how to use the `tenzing` package to create reports
from R in `vignette("local_use")`.

## Contribution

We would like tenzing to be make any contributorship-related task easy
for researchers, so we are open to new ideas and feature requests.

Please note that the ‘tenzing’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
