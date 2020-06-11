
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tenzing

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Tenzing is an easy to use shiny app, that enables researchers to create
reports about the contribution of each team member on a project using
CRediT.

CRediT (Contributor Roles Taxonomy) is high-level taxonomy, including 14
roles, that can be used to represent the roles typically played by
contributors to scientific scholarly output. The roles describe each
contributor’s specific contribution to the scholarly output.

The app is named after the Nepali-Indian sherpa Tenzing Norgay, who was
one of the two individuals who reached the summit of Mount Everest for
the first time. Despite his essential contribution, the achievement is
less credited to him than to his partner, the New Zealand mountaineer
Edmund Hillary.

[Find out more](https://www.casrai.org/credit.html) about CRediT

## Features

Currently tenzing enables contributors to:

  - read all the necessary contributorship information from one file
    (.csv, .tsv or .xlsx)
  - create a report of the contributions
  - create the contributors affiliation page information for the
    manuscript
  - create a JATS XML containing the contributions
  - create a YAML output that will automatically add the contributorship
    infomartion to `papaja`

## Usage

You can generate the same output by using the tenzing app or by using
the tenzing pacakge from R.

### Using the app

You can use the deployed app at
(<https://martonbalazskovacs.shinyapps.io/tenzing/>)\[<https://martonbalazskovacs.shinyapps.io/tenzing/>\].

Or you can run the app locally from your own computer by following these
instructions:

tenzing is not available on CRAN. You can install the development
version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("marton-balazs-kovacs/tenzing")
```

Running the app.

``` r
tenzing::run_app()
```

You can read more on how to use the tenzing app HERE.

### Using the pacakge

You can read more on how to use the tenzing package to create reports
from R HERE.

## Contribution

We would like tenzing to be a package that makes any contributorship
related task easy for researchers. Therefore, we are open to new ideas,
feature requests are the possibility of integration with already
existing platforms (such as `papaja`).

Please note that the ‘tenzing’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
