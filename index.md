# tenzing

Tenzing, an easy-to-use web-based app, allows researchers to generate
reports about the contribution of each team member on a project using
CRediT, for insertion into their manuscripts and for publishers to
potentially incorporate into article metadata.

[CRediT](http://credit.niso.org/) (Contributor Roles Taxonomy) is a
taxonomy of 14 categories of contributions to scientific scholarly
output. Each researcher can indicate which category they contributed to
in a scholarly project.

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
- create a funding acknowledgment section
- create a conflict of interest statement

## Usage

Tenzing can be used either via the web app or via R.

### Using the web app

You can use the app at <https://tenzing.club/>.

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
[`vignette("app_use")`](https://marton-balazs-kovacs.github.io/tenzing/articles/app_use.md).

### Using the package

You can read more on how to use the `tenzing` package to create reports
from R in
[`vignette("local_use")`](https://marton-balazs-kovacs.github.io/tenzing/articles/local_use.md).

## Contribution

We are open to new ideas and feature requests. We think Tenzing has the
potential to make additional contributorship-related tasks easy for
researchers.

Please note that the ‘tenzing’ project is released with a [Contributor
Code of
Conduct](https://marton-balazs-kovacs.github.io/tenzing/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
