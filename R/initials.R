#' Add initials to the infosheet
#' 
#' This function adds the initials to the infosheet based on the Firstname,
#' Middle name and Surname. The function uses whitespaces and hypens to
#' detect the separate names. Also, the function is case sensitive.
#' 
#' @param infosheet the imported infosheet
#' 
#' @return The function returns the infosheet with the initials in
#'   an additional column
#' @export
add_initials <- function(infosheet) {
  infosheet %>% 
    # If first name contains -, abbreviate both, else, abbreviate all separate names
    dplyr::mutate(fir = abbreviate(Firstname, collapse = ""),
                  mid = abbreviate(`Middle name`, collapse = ""),
                  las = abbreviate(Surname, collapse = ""),
                  abbrev_name = stringr::str_glue("{fir}{mid}{las}", .na = "")) %>% 
    # Get duplicated abbreviations
    dplyr::add_count(abbrev_name, name = "dup_abr") %>% 
    # If abbreviation has multiple instances, add full surname
    dplyr::mutate(abbrev_name = dplyr::if_else(dup_abr > 1,
                                               stringr::str_glue("{fir}{mid} {Surname}", .na = ""),
                                               abbrev_name))
}

#' Abbreviate middle names
#'
#' Abbreviates multiple words to first letters
#'
#' @param string Character. A character vector with the names
#'
#' @return Returns a character vector with one element.
#'
#' @examples
#' tenzing:::abbreviate_middle_names("Franz Jude Wayne")
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

abbreviate_middle_names_df <- function(infosheet) {
  infosheet %>%
    dplyr::mutate_at(
      dplyr::vars(Firstname, `Middle name`, Surname),
      as.character) %>% 
    dplyr::rowwise() %>% 
    dplyr::mutate(
      `Middle name` = dplyr::if_else(
        is.na(`Middle name`),
        NA_character_,
        abbreviate(`Middle name`, collapse = " ")
      )
    ) %>%
    dplyr::ungroup()
}
