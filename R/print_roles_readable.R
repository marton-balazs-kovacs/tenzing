#' Generate human readable report of the contributions
#' 
#' The function generates rmarkdown formatted text of the contributions according
#' to the CRediT taxonomy. The output is generated from an infosheet validated with
#' the \code{\link{validate_infosheet}} function. The infosheet must be based on the
#' \code{\link{infosheet_template}}. The function can return the output string as
#' rmarkdown or html formatted text or without any formatting.
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
#' @param text_format formatting of the returned string. Possible values: "rmd", "html", "raw".
#'   "rmd" by default.
#' @param initials Logical. If true initials will be included instead of full
#'   names in the output
#' 
#' @return The function returns a string containing the CRediT roles
#'   with the contributors listed for each role they partake in.
#' @export
#' @examples 
#' validate_infosheet(infosheet = infosheet_template)
#' print_roles_readable(infosheet = infosheet_template)
print_roles_readable <-  function(infosheet, text_format = "rmd", initials = FALSE) {
  # Restructure dataframe for the credit roles output ---------------------------
  if (initials) {
    roles_data <-
      infosheet %>% 
      dplyr::mutate_at(
        dplyr::vars(Firstname, `Middle name`, Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = abbrev_name)
    } else {
      roles_data <-
        infosheet %>% 
        abbreviate_middle_names_df() %>%
        dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                                            paste(Firstname, Surname),
                                            paste(Firstname, `Middle name`, Surname)))
      }
  
  roles_data <- 
    roles_data %>% 
    dplyr::select(Name,
                  dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>%  
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -Name) %>% 
    dplyr::filter(Included == TRUE) %>% 
    dplyr::select(-Included) %>% 
    dplyr::group_by(`CRediT Taxonomy`) %>% 
    dplyr::summarise(Names = glue::glue_collapse(Name, sep = ", ", last = " and "))
  
  # Format output string according to the text_format argument ---------------------------
  if (text_format == 'rmd') {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("**{`CRediT Taxonomy`}:** {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        roles_data %>% 
        dplyr::transmute(out = glue::glue("<b>{`CRediT Taxonomy`}:</b> {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
        dplyr::summarise(out = glue::glue_collapse(out, sep = "<br>"))
      } else if (text_format == "raw") {
        res <-
          roles_data %>% 
          dplyr::transmute(out = glue::glue("{`CRediT Taxonomy`}: {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
          dplyr::summarise(out = glue::glue_collapse(out, sep = " "))
        }
  
  res %>% 
    dplyr::pull(out)
}

