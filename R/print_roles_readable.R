#' Generate human readable report of the contributions
#' 
#' The function generates rmarkdown formatted text of the contributions according
#' to the CRediT taxonomy. The output is generated from an infosheet validated with
#' the \code{\link{validate_infosheet}} function. The infosheet must be based on the
#' \code{\link{infosheet_template}}.
#' 
#' #' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family \code{\link{print_contrib_affil}}, \code{\link{print_roles_readable}},
#'   \code{\link{print_xml}}, \code{\link{print_yaml}}
#'
#' @param infosheet validated infosheet
#' 
#' #' @return The function returns a character vector of the CRediT roles
#'   with the contributors listed for each role they partake in. The returned
#'   text is rmarkdown formatted.
#' 
#' @examples 
#' validate_infosheet(infosheet = infosheet_template)
#' print_roles_readable(infosheet = infosheet_template)
print_roles_readable <-  function(infosheet) {
  infosheet %>% 
    dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                                        paste(Firstname, Surname),
                                        paste(Firstname, `Middle name`, Surname))) %>% 
    dplyr::select(Name,
                  dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>%  
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -Name) %>% 
    dplyr::filter(Included == TRUE) %>% 
    dplyr::select(-Included) %>%
    dplyr::group_by(`CRediT Taxonomy`) %>% 
    dplyr::summarise(Names = stringr::str_c(Name, collapse = ", ")) %>% 
    dplyr::transmute(out = glue::glue("**{`CRediT Taxonomy`}:** {Names}.")) %>% 
    dplyr::summarise(out = stringr::str_c(out, collapse = "  \n")) %>%
    dplyr::pull(out)
}