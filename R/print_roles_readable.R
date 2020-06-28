#' Generate human readable report of the contributions
#' 
#' The function generates rmarkdown formatted text of the contributions according
#' to the CRediT taxonomy. The output is generated from an infosheet validated with
#' the \code{\link{validate_infosheet}} function. The infosheet must be based on the
#' \code{\link{infosheet_template}}.
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param infosheet validated infosheet
#' 
#' @return The function returns a character vector of the CRediT roles
#'   with the contributors listed for each role they partake in. The returned
#'   text is rmarkdown formatted.
#' @export
#' @examples 
#' validate_infosheet(infosheet = infosheet_template)
#' print_roles_readable(infosheet = infosheet_template)
print_roles_readable <-  function(infosheet, output_format = "rmd") {
  res <-
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
    dplyr::summarise(Names = glue::glue_collapse(Name, sep = ", ", last = " and "))
  
  if (output_format == 'rmd') {
    res %>% 
      dplyr::transmute(out = glue::glue("**{`CRediT Taxonomy`}:** {Names}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "  \n")) %>% 
      dplyr::pull(out)
  } else if (output_format == "html") {
    res %>% 
      dplyr::transmute(out = glue::glue("<b>{`CRediT Taxonomy`}:</b> {Names}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "<br>")) %>% 
      dplyr::pull(out)
  } else if (output_format == "raw") {
    res %>% 
      dplyr::transmute(out = glue::glue("{`CRediT Taxonomy`}: {Names}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = " ")) %>% 
      dplyr::pull(out)
  }
}
