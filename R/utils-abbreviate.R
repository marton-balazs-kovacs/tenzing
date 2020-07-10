#' Abbreviate middle names
#'
#' Abbreviates multiple words to first letters
#'
#' @param x Character. A character vector with one element.
#'
#' @return Returns a character vector with one element.
#'
#' @examples
#' abbreviate_middle_names("Franz Jude Wayne")

abbreviate <- function(x) {
    x <- x[x != ""]
    if(length(x) > 0) {
        res <- gsub(x,  pattern = "^(.).*", replace = "\\1.")
        paste(res, collapse = " ")
    } else {
        res <- NULL
    }
}

abbreviate_middle_names <- function(x) {
    split_names <- strsplit(x, split = " |\\.")
    initials <- unlist(lapply(split_names, abbreviate))
    paste(initials, collapse = " ")
}

abbreviate_middle_names_df <- function(x) {
    x %>%
    dplyr::rowwise() %>% 
    dplyr::mutate(
        `Middle name` = dplyr::if_else(
            is.na(`Middle name`),
            NA_character_,
            abbreviate_middle_names(`Middle name`)
        )
    ) %>%
    dplyr::ungroup()
}
