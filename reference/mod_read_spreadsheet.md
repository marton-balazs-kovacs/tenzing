# mod_read_spreadsheet_ui and mod_read_spreadsheet_server

A shiny Module.

## Usage

``` r
mod_read_spreadsheet_ui(id)

mod_read_spreadsheet_server(id)
```

## Arguments

- id:

  shiny id

## Details

The server function returns a list with the following reactive elements:

- data:

  The cleaned and filtered contributors table

- is_valid:

  Logical reactive indicating if the table passed validation

- upload:

  Reactive trigger that fires when the upload button is clicked

Note: The `is_valid` and `upload` reactives are exported primarily for
use by the global button manager module to control button states across
the application.
