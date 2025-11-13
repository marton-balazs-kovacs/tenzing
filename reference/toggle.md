# toggle

Generates a toggle switch row with a label, a shinyWidgets
materialSwitch, and an optional right label, with robust flexbox
alignment.

## Usage

``` r
toggle(
  ns,
  inputId,
  left_label,
  right_label = NULL,
  value = FALSE,
  title = NULL
)
```

## Arguments

- ns:

  namespacing/shiny ns function

- inputId:

  id of the switch

- left_label:

  Left hand label text

- right_label:

  Optional right hand label text

- value:

  Initial value of the switch. Default is FALSE.

- title:

  Optional heading displayed above the toggle controls.

## Value

A shiny tagList row
