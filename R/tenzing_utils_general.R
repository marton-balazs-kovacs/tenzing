#' Return messages as unnamed vector for js handler
#'
#' The function filters the results of the validation of the infosheet template
#' by type. Then the message elements are pulled and collapsed into one element.
#'
#' @param x The result of the validation
#' @param y The type of validation message
#'
#' @return Returns a character vector with one element.
unnamed_message <- function(x, y) {
  x %>% 
    dplyr::filter(type == y) %>% 
    dplyr::pull(message) %>% 
    glue::glue_collapse(., sep = "<br>")
}