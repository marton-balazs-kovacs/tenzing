#' Generate title page
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
#' example_infosheet <- read_infosheet(infosheet = system.file("extdata", "infosheet_template_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_infosheet(infosheet = example_infosheet)
#' print_title_page(infosheet = example_infosheet)
print_title_page <- function(infosheet, text_format = "rmd") {
  # Validation ---------------------------
  ## Check if there are shared first authors
  shared_first <- nrow(infosheet[infosheet$`Order in publication` == 1, ]) > 1
  
  # Restructure dataframe for the contributors affiliation output ---------------------------
  clean_names_infosheet <-
    infosheet %>%
    abbreviate_middle_names_df() %>%
    dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                                         paste(Firstname, Surname),
                                         paste(Firstname, `Middle name`, Surname)))
  
  contrib_affil_data <-
    clean_names_infosheet %>% 
    dplyr::select(`Order in publication`, Name, `Primary affiliation`, `Secondary affiliation`, `Email address`, `Corresponding author?`) %>%
    tidyr::gather(key = "affiliation_type", value = "affiliation", -Name, -`Order in publication`, -`Email address`, -`Corresponding author?`) %>% 
    dplyr::arrange(`Order in publication`) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(!is.na(affiliation) ~ suppressWarnings(dplyr::group_indices(., factor(affiliation, levels = unique(affiliation)))),
                                                    is.na(affiliation) ~ NA_integer_))
  
  # Modify data for printing contributor information ---------------------------
  contrib_print <- 
    contrib_affil_data %>% 
    dplyr::select(-affiliation) %>% 
    dplyr::mutate(affiliation_no = as.character(affiliation_no)) %>%
    dplyr::group_by(`Order in publication`, Name) %>% 
    dplyr::summarise(affiliation_no = stringr::str_c(na.omit(affiliation_no), collapse = ",")) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(
      shared_first & `Order in publication` == 1 ~ paste0(affiliation_no, "*"),
      TRUE ~ affiliation_no)) %>% 
    # Format output string according to the text_format argument
    dplyr::transmute(contrib = switch(
      text_format,
      "rmd" = glue::glue("{Name}^{affiliation_no}^"),
      "html" = glue::glue("{Name}<sup>{affiliation_no}</sup>"),
      "raw" = glue::glue("{Name}{affiliation_no}"))) %>% 
    # Collapse contributor names to one string
    dplyr::pull(contrib) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for printing the affiliations ---------------------------
  affil_print <- 
    contrib_affil_data %>% 
    dplyr::select(affiliation_no, affiliation) %>% 
    tidyr::drop_na(affiliation) %>% 
    dplyr::distinct(affiliation, .keep_all = TRUE) %>% 
    # Format output string according to the text_format argument
    dplyr::transmute(affil = switch(
      text_format,
      "rmd" = glue::glue("^{affiliation_no}^{affiliation}"),
      "html" = glue::glue("<sup>{affiliation_no}</sup>{affiliation}"),
      "raw" = glue::glue("{affiliation_no}{affiliation}"))) %>% 
    # Collapse affiliations to one string
    dplyr::pull(affil) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for shared first authors ---------------------------
  if (shared_first) {
    annotation_print <-
      clean_names_infosheet %>% 
      dplyr::select(`Order in publication`, Name, `Email address`, `Corresponding author?`) %>% 
      dplyr::filter(`Order in publication` == 1) %>% 
      dplyr::mutate(shared_author_names = glue_oxford_collapse(Name)) %>% 
      dplyr::filter(`Corresponding author?`) %>% 
      glue::glue_data("*{shared_author_names} are shared first authors. The corresponding author is {Name}: {`Email address`}.")
  }
  
  # Bind contributor and affiliation information  ---------------------------
  res <- switch(
    text_format,
    "rmd" = glue::glue("{contrib_print}\n   \n{affil_print}\\
                       {ifelse(shared_first, paste0('\n   \n', annotation_print), '')}"),
    "html" = glue::glue("{contrib_print}<br><br>{affil_print}\\
                        {ifelse(shared_first, paste0('<br><br>', annotation_print), '')}"),
    "raw" = glue::glue("{contrib_print} {affil_print} {ifelse(shared_first, annotation_print, '')}")
  )
  
  return(res)
}
