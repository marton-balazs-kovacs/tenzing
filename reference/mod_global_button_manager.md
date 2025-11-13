# mod_global_button_manager_ui and mod_global_button_manager_server

Manages the enable/disable state of buttons across the application based
on upload and validation status from the read_spreadsheet module.

## Usage

``` r
mod_global_button_manager_ui(id)

mod_global_button_manager_server(id, upload, is_valid)
```

## Arguments

- id:

  shiny id

- upload:

  A reactive that triggers when upload occurs (e.g., upload button
  click)

- is_valid:

  A reactive that returns TRUE/FALSE indicating if data is valid
