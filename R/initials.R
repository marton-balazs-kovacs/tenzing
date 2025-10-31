#' Add initials to the contributors_table
#' 
#' This function adds the initials to the contributors_table based on the Firstname,
#' Middle name and Surname. The function uses whitespaces and hypens to
#' detect the separate names. Also, the function is case sensitive.
#' 
#' @param contributors_table the imported contributors_table
#' 
#' @return The function returns the contributors_table with the initials in
#'   an additional column
#' @export
#' 
#' @importFrom rlang .data
add_initials <- function(contributors_table) {
  contributors_table %>% 
    # If first name contains -, abbreviate both, else, abbreviate all separate names
    dplyr::mutate(fir = abbreviate(.data$Firstname, collapse = ""),
                  mid = abbreviate(.data$`Middle name`, collapse = ""),
                  las = abbreviate(.data$Surname, collapse = ""),
                  abbrev_name = stringr::str_glue("{fir}{mid}{las}", .na = "")) %>% 
    # Get duplicated abbreviations
    dplyr::add_count(.data$abbrev_name, name = "dup_abr") %>% 
    # If abbreviation has multiple instances, add full surname
    dplyr::mutate(abbrev_name = dplyr::if_else(.data$dup_abr > 1,
                                               stringr::str_glue("{fir}{mid} {Surname}", .na = ""),
                                               .data$abbrev_name))
}

#' Abbreviate names
#'
#' Abbreviates multiple words to first letters
#'
#' @param string Character. A character vector with the names
#' @param collapse Character. A string that will be used to separate names
#'
#' @return Returns a character vector with one element.
#' @export
#'
#' @examples
#' tenzing:::abbreviate("Franz Jude Wayne", collapse = "")
abbreviate <- function(string, collapse) {
  string <- string[string != ""]
  if(length(string) > 0) {
    res <- 
      string %>% 
      # Separate the strings by keeping the hyphen
      stringr::str_extract_all("\\w+|-")  %>% 
      # Keep only the first letter
      purrr::map(stringr::str_sub, 1, 1) %>% 
      # Add dots after only letters not the hyphen
      purrr::map(stringr::str_replace, "(?<=^\\w)", ".") %>% 
      # Collapse them to one string
      purrr::map_chr(stringr::str_c, collapse = collapse) %>% 
      # Drop spaces around hyphens
      stringr::str_replace_all("\\s+(?=\\p{Pd})|(?<=\\p{Pd})\\s+", "")
  } else {
    res <- NULL
  }
  res
}

#' Abbreviate middle names in a dataframe
#' 
#' The function calls the [abbreviate()] function to
#' abbreviate middle names in the `Middle name` variable in a
#' dataframe if they are present. The function requires a valid
#' `contributors_table` as an input to work.
#' 
#' @param contributors_table the imported contributors_table
#' 
#' @return The function returns a dataframe with abbreviated middle
#' names.
#' @export
#' 
#' @importFrom rlang .data
abbreviate_middle_names_df <- function(contributors_table) {
  contributors_table %>%
    dplyr::mutate_at(
      dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
      as.character) %>% 
    dplyr::rowwise() %>% 
    dplyr::mutate(
      `Middle name` = dplyr::if_else(
        is.na(.data$`Middle name`) | .data$`Middle name` == "",
        NA_character_,
        {
          abbrev_result <- abbreviate(.data$`Middle name`, collapse = " ")
          if (is.null(abbrev_result)) NA_character_ else abbrev_result
        }
      )
    ) %>%
    dplyr::ungroup()
}
