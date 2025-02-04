#' Return messages as unnamed vector for js handler
#'
#' The function filters the results of the validation of the contributors_table template
#' by type. Then the message elements are pulled and collapsed into one element.
#'
#' @param x The result of the validation
#' @param y The type of validation message
#'
#' @return Returns a character vector with one element.
#' 
#' @keywords internal
unnamed_message <- function(x, y) {
  x %>% 
    dplyr::filter(.data$type == y) %>% 
    dplyr::pull(message) %>% 
    glue::glue_collapse(., sep = "<br>")
}

#' Collapse a character vector with oxford comma
#' 
#' Collapses a character vector into a length 1 vector,
#' by using ", " as a separator and adding the oxford comma
#' if there original character vector length is longer than 3.
#' The function is from the cli package: https://github.com/jonocarroll/cli/blob/2d3fbc4b41327df82df1102cdfc0a5c99822809b/R/inline.R
#' 
#' @param x character, the vector to be collapsed
#' 
#' @return The function returns a vector of length 1.
#' 
#' @keywords internal
glue_oxford_collapse <- function(x) {
  if (length(x) >= 3) {
    glue::glue_collapse(x, sep = ", ", last = ", and ")
  } else {
    glue::glue_collapse(x, sep = ", ", last = " and ")
  }
}