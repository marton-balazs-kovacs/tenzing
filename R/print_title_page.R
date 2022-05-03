#' Generate title page
#' 
#' The function generates rmarkdown formatted contributors' affiliation text from
#' an contributors_table validated with the [validate_contributors_table()] function. The 
#' contributors_table must be based on the [contributors_table_template()]. The function can
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
#' @param contributors_table validated contributors_table
#' @param text_format formatting of the returned string. Possible values: "rmd", "html", "raw".
#'   "rmd" by default.
#' 
#' @return The output is string containing the contributors' name and
#'   the corresponding affiliations in the the order defined by the
#'   `Order in publication` column of the contributors_table.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_contributors_table(contributors_table = example_contributors_table)
#' print_title_page(contributors_table = example_contributors_table)
#' 
#' @importFrom rlang .data
#' @importFrom stats na.omit
print_title_page <- function(contributors_table, text_format = "rmd") {
  # Defining global variables
  . = NULL
  
  # Validation ---------------------------
  ## Check if there are shared first authors
  shared_first <- nrow(contributors_table[contributors_table$`Order in publication` == 1, ]) > 1
  
  # Restructure dataframe for the contributors affiliation output ---------------------------
  clean_names_contributors_table <-
    contributors_table %>%
    abbreviate_middle_names_df() %>%
    dplyr::mutate(Name = dplyr::if_else(is.na(.data$`Middle name`),
                                         paste(.data$Firstname, .data$Surname),
                                         paste(.data$Firstname, .data$`Middle name`, .data$Surname)))
  
  contrib_affil_data <-
    clean_names_contributors_table %>% 
    dplyr::select(
      .data$`Order in publication`,
      .data$Name,
      .data$`Primary affiliation`,
      .data$`Secondary affiliation`,
      .data$`Email address`,
      .data$`Corresponding author?`) %>%
    tidyr::gather(key = "affiliation_type", value = "affiliation",
                  -.data$Name,
                  -.data$`Order in publication`,
                  -.data$`Email address`,
                  -.data$`Corresponding author?`
                  ) %>% 
    dplyr::arrange(.data$`Order in publication`) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(
      !is.na(affiliation) ~ suppressWarnings(dplyr::group_indices(., factor(affiliation, levels = unique(affiliation)))),
      is.na(affiliation) ~ NA_integer_)
      )
  
  # Modify data for printing contributor information ---------------------------
  contrib_print <- 
    contrib_affil_data %>% 
    dplyr::select(-.data$affiliation) %>% 
    dplyr::mutate(affiliation_no = as.character(.data$affiliation_no)) %>%
    dplyr::group_by(.data$`Order in publication`, .data$Name, .data$`Corresponding author?`) %>% 
    dplyr::summarise(affiliation_no = stringr::str_c(na.omit(.data$affiliation_no), collapse = ",")) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(
      shared_first & .data$`Order in publication` == 1 ~ paste0(.data$affiliation_no, "*"),
      .data$`Corresponding author?` ~ paste0(.data$affiliation_no, "†"),
      TRUE ~ .data$affiliation_no)) %>% 
    # Format output string according to the text_format argument
    # dplyr::transmute(contrib = switch(
    #   text_format,
    #   "rmd" = glue::glue("{Name}^{affiliation_no}^"),
    #   "html" = glue::glue("{Name}<sup>{affiliation_no}</sup>"),
    #   "raw" = glue::glue("{Name}{affiliation_no}"))) %>% 
    dplyr::transmute(contrib = paste0(Name, superscript(affiliation_no, text_format))) %>% 
    # Collapse contributor names to one string
    dplyr::pull(.data$contrib) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for printing the affiliations ---------------------------
  affil_print <- 
    contrib_affil_data %>% 
    dplyr::select(.data$affiliation_no, .data$affiliation) %>% 
    tidyr::drop_na(.data$affiliation) %>% 
    dplyr::distinct(.data$affiliation, .keep_all = TRUE) %>% 
    # Format output string according to the text_format argument
    dplyr::transmute(affil = switch(
      text_format,
      "rmd" = glue::glue("^{affiliation_no}^{affiliation}"),
      "html" = glue::glue("<sup>{affiliation_no}</sup>{affiliation}"),
      "raw" = glue::glue("{affiliation_no}{affiliation}"))) %>% 
    # Collapse affiliations to one string
    dplyr::pull(.data$affil) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for shared first authors ---------------------------
  if (shared_first) {
    annotation_print <-
      clean_names_contributors_table %>% 
      dplyr::select(
        .data$`Order in publication`,
        .data$Name,
        .data$`Email address`,
        .data$`Corresponding author?`) %>% 
      dplyr::filter(.data$`Order in publication` == 1) %>% 
      dplyr::mutate(shared_author_names = glue_oxford_collapse(.data$Name)) %>% 
      dplyr::filter(.data$`Corresponding author?`) %>% 
      glue::glue_data("*{shared_author_names} are shared first authors. The corresponding author is {Name}: {`Email address`}.")
  } else if (any(clean_names_contributors_table$`Corresponding author?`) & !shared_first) {
    annotation_print <- 
      clean_names_contributors_table %>% 
      dplyr::select(
        .data$Name,
        .data$`Email address`,
        .data$`Corresponding author?`) %>% 
      dplyr::filter(.data$`Corresponding author?`) %>%
      glue::glue_data("{superscript('†', text_format)}Correspondence should be addressed to {Name}; E-mail: {`Email address`}")
  } else {
    annotation_print <- ""
  }
  
  # Bind contributor and affiliation information  ---------------------------
  res <- switch(
    text_format,
    "rmd" = glue::glue("{contrib_print}\n   \n{affil_print}\\
                       {paste0('\n   \n', annotation_print)}"),
    "html" = glue::glue("{contrib_print}<br><br>{affil_print}\\
                        {paste0('<br><br>', annotation_print)}"),
    "raw" = glue::glue("{contrib_print} {affil_print} {annotation_print}")
  )
  
  return(res)
}
