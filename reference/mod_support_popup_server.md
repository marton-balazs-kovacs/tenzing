# Support popup (server-only; no UI function) Uses insertUI/removeUI + later; styled via CSS (.support-toast)

Support popup (server-only; no UI function) Uses insertUI/removeUI +
later; styled via CSS (.support-toast)

## Usage

``` r
mod_support_popup_server(
  id,
  enable = TRUE,
  show_prob = 0.33,
  delay_ms = 1500,
  dismiss_ms = 60000,
  donation_url = "https://opencollective.com/tenzing"
)
```

## Arguments

- id:

  Module id (required by shiny module system)

- enable:

  Logical or reactive logical. If FALSE, popup is never shown. Default
  is TRUE.

- show_prob:

  Numeric between 0 and 1. Probability that popup will be shown. Default
  is 0.33.

- delay_ms:

  Integer. Delay in milliseconds before showing popup. Default is 1500.

- dismiss_ms:

  Integer. Delay in milliseconds before auto-dismissing popup. Default
  is 60000.

- donation_url:

  Character. URL for donation link. Default is
  "https://opencollective.com/tenzing"
