# Wrapper around `rmarkdown::render`

A wrapper function around
[`rmarkdown::render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
in order to call it in a different process in the modules.

## Usage

``` r
render_report(input, output, format, params)
```

## Arguments

- input:

  path of the input RMD skeleton

- output:

  path of the rendered output file

- format:

  the extension of the output file

- params:

  list of parameters that will be passed to the RMD

## Source

The function is based on the suggestion of Hadley Wickham
<https://mastering-shiny.org/action-transfer.html>.

## See also

[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
