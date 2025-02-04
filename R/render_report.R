#' Wrapper around `rmarkdown::render`
#' 
#' A wrapper function around `rmarkdown::render` in order
#' to call it in a different process in the modules.
#' 
#' @section Source:
#' The function is based on the suggestion of Hadley Wickham <https://mastering-shiny.org/action-transfer.html>.
#' 
#' @seealso [rmarkdown::render()]
#' 
#' @param input path of the input RMD skeleton
#' @param output path of the rendered output file
#' @param format the extension of the output file
#' @param params list of parameters that will be passed to the RMD
#' 
#' @keywords internal
render_report <- function(input, output, format, params) {
  rmarkdown::render(input,
                    output_file = output,
                    output_format = format,
                    params = params,
                    envir = new.env(parent = globalenv()),
                    encoding = "UTF-8"
  )
}
