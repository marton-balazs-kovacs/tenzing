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
  
  # Combine legacy and numbered affiliation columns ---------------------------
  # Identify all columns matching `Affiliation {n}` format
  # Define valid affiliation columns
  legacy_affiliation_cols <- c("Primary affiliation", "Secondary affiliation")
  numbered_affiliation_cols <- grep("^Affiliation \\d+$", colnames(contributors_table), value = TRUE)
  
  # Combine columns that actually exist in the table
  affiliation_cols <- c(
    intersect(legacy_affiliation_cols, colnames(contributors_table)), # Keep only legacy columns that exist
    numbered_affiliation_cols # Add numbered affiliation columns
  )
  
  # Restructure dataframe for the contributors affiliation output ---------------------------
  clean_names_contributors_table <-
    contributors_table %>%
    abbreviate_middle_names_df() %>%
    dplyr::mutate(Name = dplyr::if_else(
      is.na(.data$`Middle name`),
      paste(.data$Firstname, .data$Surname),
      paste(.data$Firstname, .data$`Middle name`, .data$Surname)
    ))
  
  # Ensure missing "Corresponding author?" is handled gracefully
  if (!"Corresponding author?" %in% colnames(contributors_table)) {
    clean_names_contributors_table <- clean_names_contributors_table %>%
      dplyr::mutate(`Corresponding author?` = FALSE)
  }
  
  # Ensure missing "Email address" is handled gracefully
  if (!"Email address" %in% colnames(contributors_table)) {
    clean_names_contributors_table <- clean_names_contributors_table %>%
      dplyr::mutate(
        `Email address` = dplyr::if_else(
          text_format == "html",
          '<span style="background-color: #ffec9b; padding: 2px;">[Missing email for the corresponding author]</span>',
          NA_character_
        )
      )
  } else {
    clean_names_contributors_table <- clean_names_contributors_table %>%
      dplyr::mutate(
        `Email address` = dplyr::if_else(
          text_format == "html" &
            is.na(.data$`Email address`) &
            .data$`Corresponding author?`,
          '<span style="background-color: #ffec9b; padding: 2px;">[Missing email for the corresponding author]</span>',
          .data$`Email address`
        )
      )
  }
  
  contrib_affil_data <-
    clean_names_contributors_table %>%
    tidyr::pivot_longer(
      cols = all_of(affiliation_cols),
      names_to = "affiliation_type",
      values_to = "affiliation"
    ) %>%
    dplyr::arrange(.data$`Order in publication`) %>%
    dplyr::mutate(affiliation_no = dplyr::case_when(
      !is.na(affiliation) ~ suppressWarnings(dplyr::group_indices(., factor(affiliation, levels = unique(affiliation)))),
      is.na(affiliation) ~ NA_integer_
    ))
  
  # Modify data for printing contributor information ---------------------------
  contrib_print <- 
    contrib_affil_data %>% 
    dplyr::select(-.data$affiliation) %>% 
    dplyr::mutate(affiliation_no = as.character(.data$affiliation_no)) %>%
    dplyr::group_by(.data$`Order in publication`, .data$Name, .data$`Corresponding author?`) %>% 
    dplyr::summarise(affiliation_no = stringr::str_c(na.omit(.data$affiliation_no), collapse = ",")) %>% 
    dplyr::mutate(affiliation_no = dplyr::case_when(
      shared_first & .data$`Order in publication` == 1 & .data$`Corresponding author?` ~ paste0(.data$affiliation_no, "*†"),  # Shared first & corresponding
      shared_first & .data$`Order in publication` == 1 ~ paste0(.data$affiliation_no, "*"),  # Shared first only
      .data$`Corresponding author?` ~ paste0(.data$affiliation_no, "†"),  # Corresponding only
      TRUE ~ .data$affiliation_no
    )) %>% 
    # Format output string according to the text_format argument
    dplyr::transmute(contrib = dplyr::case_when(
      text_format == "rmd" ~ glue::glue("{Name}^{affiliation_no}^"), # R Markdown superscript
      TRUE ~ paste0(Name, superscript(affiliation_no, text_format))
    )) %>% 
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
    dplyr::transmute(affil = paste0(superscript(affiliation_no, text_format), affiliation)) %>% 
    # Collapse affiliations to one string
    dplyr::pull(.data$affil) %>% 
    glue::glue_collapse(., sep = ", ")
  
  # Modify data for shared first authors ---------------------------
  if (shared_first) {
    # Identify first authors
    first_authors_data <-
      clean_names_contributors_table %>%
      dplyr::filter(.data$`Order in publication` == 1) %>%
      dplyr::summarise(
        shared_author_names = glue_oxford_collapse(.data$Name),
        .groups = "drop"
      )
    
    first_author_text <- glue::glue_data(
      first_authors_data,
      "*{shared_author_names} are shared first authors."
    )
  } else {
    first_author_text <- ""
  }
  
  # Identify corresponding authors (can be first authors or not)
  if (any(clean_names_contributors_table$`Corresponding author?`, na.rm = TRUE)) {
    corresponding_authors_data <-
      clean_names_contributors_table %>%
      dplyr::filter(.data$`Corresponding author?`) %>%
      dplyr::summarise(
        corresponding_names = glue_oxford_collapse(.data$Name),
        corresponding_emails = glue_oxford_collapse(.data$`Email address`),
        .groups = "drop"
      )
    
    corresponding_text <- glue::glue_data(
      corresponding_authors_data,
      "{superscript('†', text_format)} Correspondence should be addressed to {corresponding_names}; E-mail: {corresponding_emails}."
    )
  } else if (text_format == "html") {
    corresponding_text <- '<span style="background-color: #ffec9b; padding: 2px;">[Missing corresponding author statement]</span>'
  } else {
    corresponding_text <- ""
  }
  
  # Combine first author and corresponding author statements
  annotation_print <- glue::glue("{first_author_text} {corresponding_text}")
  
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
