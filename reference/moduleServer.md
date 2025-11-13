# Wrapper function around `shiny::callModule`

The function dodge the explicit usage of `callModule` on the server
side. This style will be the default for `shiny` from version 1.5.0. To
be deleted after update.

## Usage

``` r
moduleServer(id, module)
```

## Arguments

- id:

  Unique character id of the module

- module:

  Name of the module server function

## Source

<https://mastering-shiny.org/scaling-modules.html>
