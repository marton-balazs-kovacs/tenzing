#' Generate human readable report of the funding information
#' 
#' The functions generates a human readable text about the funding
#' information of the contributors. The output is generated from an
#' infosheet validated with the \code{\link{validate_infosheet}} function.
#' The infosheet must be based on the \code{\link{infosheet_template}}.
#' 
#' @family output functions
#' 
#' @param infosheet validated infosheet
#' @param initials Logical. If true initials will be included instead of full
#'   names in the output
#'   
#' @return The function returns a string.
#' @export
print_funding <- function(infosheet, initials = FALSE) {
  # Validate input ---------------------------
  if (all(is.na(infosheet$Funding))) stop("There is no funding information provided for either of the contributors.")
  
  # Restructure dataframe ---------------------------
  if (initials) {
    funding_data <-
      infosheet %>% 
      dplyr::mutate_at(
        dplyr::vars(Firstname, `Middle name`, Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = abbrev_name)
    } else {
      funding_data <-
        infosheet %>% 
        abbreviate_middle_names_df() %>%
        dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                                            paste(Firstname, Surname),
                                            paste(Firstname, `Middle name`, Surname)))
    }
  
  funding_data <- 
    funding_data %>% 
    dplyr::select(Name, Funding) %>% 
    dplyr::filter(!is.na(Funding) & Funding != "") %>% 
    dplyr::group_by(Funding) %>% 
    dplyr::summarise(Names = glue_oxford_collapse(Name),
                     n_names = dplyr::n())
  
  # Format output string ---------------------------
  res <-
    funding_data %>% 
    dplyr::transmute(
      out = glue::glue("{Names} {dplyr::if_else(n_names > 1, 'were', 'was')} supported by the {Funding}")) %>% 
    dplyr::summarise(out = glue::glue_collapse(out, sep = "; ")) %>% 
    dplyr::mutate(out = stringr::str_c(out, "."))
  
  res %>% 
    dplyr::pull(out)
}
