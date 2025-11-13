# Send content to the browser clipboard

Wraps `session$sendCustomMessage()` to deliver both HTML and plain-text
representations for the rich clipboard handler defined in
`inst/app/www/clipboard.js`.

## Usage

``` r
copy_to_clipboard(session, html = NULL, text = NULL, status_input = NULL)
```

## Arguments

- session:

  Shiny session object.

- html:

  Optional HTML string to push to the clipboard. When provided, the
  browser attempts to write this as `text/html`.

- text:

  Optional plain-text fallback. If omitted but `html` is supplied, the
  helper will derive text by stripping tags on the client.

- status_input:

  Optional Shiny input id that will receive copy status updates
  (`success` or `error`) for reactive handling.

## Value

Invisibly returns `NULL`. Called for its side effects.
