#' Wrapper function around \code{shiny::callModule}
#' 
#' The function dodge the explicit usage of \code{callModule} on
#' the server side. This style will be the default for \code{shiny}
#' from version 1.5.0. To be deleted after update.
#' 
#' @param id Unique character id of the module
#' @param module Name of the module server function
#' 
#' @section Source:
#' \url{https://mastering-shiny.org/scaling-modules.html}
moduleServer <- function(id, module) {
  callModule(module, id)
}