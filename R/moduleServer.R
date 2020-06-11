#' Wrapper function around \code{shiny::callModule}
#' 
#' The function dodge the explicit usage of \code{callModule} on
#' the server side. This style will be the default for \code{shiny}
#' from version 1.5.0. To be deleted after update.
#' 
#' @section Source:
#' \url{https://mastering-shiny.org/scaling-modules.html}
moduleServer <- function(id, module) {
  callModule(module, id)
}