#' Generate contributors' affiliations
#' 
#' The function generates rmarkdown formatted contributors' affiliation text from
#' an infosheet validated with the \code{\link{validate_infosheet}} function. The 
#' infosheet must be based on the \code{\link{infosheet_template}}.
#' 
#' @section Warning:
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
#' @return The output is a list containing the contributors' name in the
#'   the order defined by the \code{Order in publication} column of the
#'   infosheet in the \code{contrib} character vector, and the adherent
#'   affiliations in the same order in the \code{affil} character vector.
#' 
#' @examples 
#' validate_infosheet(infosheet = infosheet_template)
#' print_contrib_affil(infosheet = infosheet_template)
print_contrib_affil <- function(infosheet) {
  # Restructure dataframe for the contributors affiliation output
  contrib_affil_data <-
    infosheet %>% 
    dplyr::mutate(`Middle name` = dplyr::if_else(is.na(`Middle name`),
                                                 NA_character_,
                                                 paste0(stringr::str_sub(`Middle name`, 1, 1), ".")),
                  Names = dplyr::if_else(is.na(`Middle name`),
                                         paste(Firstname, Surname),
                                         paste(Firstname, `Middle name`, Surname))) %>% 
    dplyr::select(`Order in publication`, Names, `Primary affiliation`, `Secondary affiliation`) %>%
    tidyr::gather(key = "affiliation_type", value = "affiliation", -Names, -`Order in publication`) %>% 
    dplyr::arrange(`Order in publication`) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(!is.na(affiliation) ~ suppressWarnings(dplyr::group_indices(., factor(affiliation, levels = unique(affiliation)))),
                                                    is.na(affiliation) ~ NA_integer_))
  
  # Modify data for printing contributor information
  contrib_print <- 
    contrib_affil_data %>% 
    dplyr::select(-affiliation) %>% 
    tidyr::spread(key = affiliation_type, value = affiliation_no) %>% 
    dplyr::transmute(contrib = purrr::pmap_chr(list(Names, `Primary affiliation`, `Secondary affiliation`),
                                               ~ dplyr::if_else(is.na(..3),
                                                                glue::glue("{..1}^{..2}^"),
                                                                glue::glue("{..1}^{..2},{..3}^")))) %>% 
    dplyr::pull(contrib) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for printing the affiliations
  affil_print <- 
    contrib_affil_data %>% 
    dplyr::select(affiliation_no, affiliation) %>% 
    tidyr::drop_na(affiliation) %>% 
    dplyr::distinct(affiliation, .keep_all = TRUE) %>% 
    dplyr::transmute(affil = glue::glue("^{affiliation_no}^{affiliation}")) %>% 
    dplyr::pull(affil) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Outputs
  return(
    list(
      contrib = contrib_print,
      affil = affil_print
    )
  )
}
