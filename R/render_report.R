render_report <- function(input, output, format, params) {
  rmarkdown::render(input,
                    output_file = output,
                    output_format = format,
                    params = params,
                    envir = new.env(parent = globalenv())
  )
}