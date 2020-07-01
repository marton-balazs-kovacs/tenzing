#' Generate contributors' affiliations
#' 
#' The function generates rmarkdown formatted contributors' affiliation text from
#' an infosheet validated with the \code{\link{validate_infosheet}} function. The 
#' infosheet must be based on the \code{\link{infosheet_template}}. The function can
#' return the output string as rmarkdown or html formatted text or without any formatting.
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
#' 
#' @return The output is string containing the contributors' name and
#'   the corresponding affiliations in the the order defined by the
#'   \code{Order in publication} column of the infosheet.
#' @export
#' @examples 
#' validate_infosheet(infosheet = infosheet_template)
#' print_contrib_affil(infosheet = infosheet_template)
print_contrib_affil <- function(infosheet, text_format = "rmd") {
  # Restructure dataframe for the contributors affiliation output ---------------------------
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
  
  # Modify data for printing contributor information ---------------------------
  contrib_data <- 
    contrib_affil_data %>% 
    dplyr::select(-affiliation) %>% 
    tidyr::spread(key = affiliation_type, value = affiliation_no)
  
  ## Format output string according to the text_format argument
  if (text_format == "rmd") {
    contrib_print <-
      contrib_data %>% 
      dplyr::transmute(contrib = purrr::pmap_chr(list(Names, `Primary affiliation`, `Secondary affiliation`),
                                                 ~ dplyr::if_else(is.na(..3),
                                                                  glue::glue("{..1}^{..2}^"),
                                                                  glue::glue("{..1}^{..2},{..3}^"))))
  } else if (text_format == "html") {
    contrib_print <-
      contrib_data %>%
      dplyr::transmute(contrib = purrr::pmap_chr(list(Names, `Primary affiliation`, `Secondary affiliation`),
                                                 ~ dplyr::if_else(is.na(..3),
                                                                  glue::glue("{..1}<sup>{..2}</sup>"),
                                                                  glue::glue("{..1}<sup>{..2},{..3}</sup>"))))
  } else if (text_format == "raw") {
    contrib_print <-
      contrib_data %>% 
      dplyr::transmute(contrib = purrr::pmap_chr(list(Names, `Primary affiliation`, `Secondary affiliation`),
                                                 ~ dplyr::if_else(is.na(..3),
                                                                  glue::glue("{..1}{..2}"),
                                                                  glue::glue("{..1}{..2},{..3}"))))
  }
  
  ## Collapse contributor names to one string
  contrib_print <-
    contrib_print %>%
    dplyr::pull(contrib) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for printing the affiliations ---------------------------
  affil_data <- 
    contrib_affil_data %>% 
    dplyr::select(affiliation_no, affiliation) %>% 
    tidyr::drop_na(affiliation) %>% 
    dplyr::distinct(affiliation, .keep_all = TRUE)
  
  ## Format output string according to the text_format argument
  if (text_format == "rmd") {
    affil_print <-
      affil_data %>% 
      dplyr::transmute(affil = glue::glue("^{affiliation_no}^{affiliation}"))
  } else if (text_format == "html") {
    affil_print <-
      affil_data %>% 
      dplyr::transmute(affil = glue::glue("<sup>{affiliation_no}</sup>{affiliation}"))
  } else if (text_format == "raw") {
    affil_print <-
      affil_data %>% 
      dplyr::transmute(affil = glue::glue("{affiliation_no}{affiliation}"))
  }
  
  ## Collapse affiliations to one string
  affil_print <-
    affil_print %>%
    dplyr::pull(affil) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Bind contributor and affiliation information ---------------------------
  if (text_format == "rmd") {
    res <- paste0(contrib_print, "  \n   \n", affil_print)
  } else if (text_format == "html") {
    res <- paste0(contrib_print, "<br><br>", affil_print)
  } else if (text_format == "raw") {
    res <- paste(contrib_print, affil_print)
    }
  
  return(res)
}
