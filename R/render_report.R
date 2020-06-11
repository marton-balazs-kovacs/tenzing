#' Wrapper around \code{rmarkdown::render}
#' 
#' A wrapper function around \code{rmarkdown::render} in order
#' to call it in a different process in the modules.
#' 
#' @section Source:
#' The function is based on the suggestion of Hadley Wickham \url{https://mastering-shiny.org/action-transfer.html}.
#' 
#' @seealso \code{\link[rmarkdown]{render}}
#' 
#' @param input path of the input RMD skeleton
#' @param output path of the rendered output file
#' @param format the extension of the output file
#' @param params list of parameters that will be passed to the RMD
render_report <- function(input, output, format, params) {
  rmarkdown::render(input,
                    output_file = output,
                    output_format = format,
                    params = params,
                    envir = new.env(parent = globalenv())
  )
}