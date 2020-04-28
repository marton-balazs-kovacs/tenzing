
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tenzing

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Tenzing is an easy to use shiny app, that enables researchers to create
reports about the contribution of each team member on a project using
CRediT.

## Features

Currently tenzing enables contributors to:

  - read all the necesarry contributorship information from one file
    (.csv, .tsv or .xlsx)
  - create a report of the contributions
  - create the contributors affiliation page information for the
    manuscript
  - create a JATS XML containing the contributions

## Installation

tenzing is not available on CRAN. You can install the development
version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("marton-balazs-kovacs/tenzing")
```

## Usage

You can run the app locally from your own computer by running the
following code:

``` r
tenzing::run_app()
```

## Contribution

Please note that the ‘tenzing’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
