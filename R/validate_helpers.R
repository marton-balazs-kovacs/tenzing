#' Check affiliation columns for consistency
#'
#' This function checks if both legacy (`Primary affiliation` and `Secondary affiliation`) 
#' and `Affiliation {n}` columns are present in the contributors_table. If both are present,
#' it raises a warning to suggest using only one format to ensure consistent results. 
#' In the first version of tenzing only two affiliation were allowed per contributor
#' and the required names for the columns were `Primary affiliation` and `Secondary affiliation`. In the new version of the spreadsheet
#' any number of affiliation columns can be created as long as they follow the `Affiliation {number}` naming convention.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message regarding the validation result.}
check_affiliation_consistency <- function(contributors_table) {
  # Check for the presence of legacy columns
  has_primary_affiliation <- "Primary affiliation" %in% colnames(contributors_table)
  has_secondary_affiliation <- "Secondary affiliation" %in% colnames(contributors_table)
  has_legacy_affiliations <- has_primary_affiliation || has_secondary_affiliation
  
  # Check for the presence of `Affiliation {n}` columns
  has_affiliation_n <- any(grepl("^Affiliation \\d+$", colnames(contributors_table)))

  # If both systems are detected, raise an error
  if (has_legacy_affiliations && has_affiliation_n) {
    return(
      validation_warning(
        "Both legacy columns ('Primary affiliation' or 'Secondary affiliation') and 'Affiliation {n}' columns are present. Please use only one format for consistent results."
      )
    )
  }
  
  # If only one system is detected, return success
  return(
    validation_success("Affiliation column names are used consistently.")
  )
}

#' Check for Missing Surnames
#'
#' This function checks for missing values in the `Surname` column of the 
#' `contributors_table` and returns a warning if any surnames are missing.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the row numbers with missing surnames, if any.}
check_missing_surname <- function(contributors_table) {
  # Check for missing surname
  if (any(is.na(contributors_table[, "Surname"]))) {
    missing <-
      contributors_table %>%
      dplyr::filter(is.na(.data$Surname))
    
    validation_missing_values("Surname", missing, "warning")
  } else {
    validation_success("There are no missing surnames.")
  }
}

#' Check for Missing First Names
#'
#' This function checks for missing values in the `Firstname` column of the 
#' `contributors_table` and returns a warning if any first names are missing.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the row numbers with missing first names, if any.}
check_missing_firstname <- function(contributors_table) {
  if (any(is.na(contributors_table[, "Firstname"]))) {
    missing <-
      contributors_table %>%
      dplyr::filter(is.na(.data$Firstname))
    
    validation_missing_values("Firstname", missing, "warning")
  } else{
    validation_success("There are no missing firstnames.")
  }
}

#' Check for Duplicate Names
#'
#' This function checks for duplicate names in the `contributors_table`. 
#' It considers the combination of `Firstname`, `Middle name`, and `Surname` 
#' to identify duplicates.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message listing any duplicate names found.}
check_duplicate_names <- function(contributors_table) {
  duplicate <- 
    contributors_table %>% 
    dplyr::mutate_at(
      dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
      list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
    dplyr::mutate(Names = dplyr::if_else(is.na(.data$`Middle name`),
                                         paste(.data$Firstname, .data$Surname),
                                         paste(.data$Firstname, .data$`Middle name`, .data$Surname))) %>% 
    dplyr::count(.data$Names) %>% 
    dplyr::filter(.data$n > 1)
  
  if (nrow(duplicate) != 0) {
    validation_warning(
      glue::glue(
        "The contributors_table has the following duplicate names: ",
        glue::glue_collapse(stringr::str_to_title(duplicate$Names), sep = ", ", last = " and ")
      ),
      details = list(duplicate_names = duplicate$Names)
    )
  } else {
    validation_success("There are no duplicate names in the contributors_table.")
  }
}

#' Check for Missing Values in the Order of Publication
#'
#' This function checks for missing values in the `Order in publication` column
#' of the `contributors_table`. If there are missing order numbers, it returns 
#' an error indicating which rows are affected.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "error".}
#' \item{message}{An informative message indicating the row numbers with missing order values.}
check_missing_order <- function(contributors_table) {
  missing <-
    contributors_table %>% 
    dplyr::filter(is.na(.data$`Order in publication`))
  
  if (nrow(missing) != 0) {
    formatted_rows <- format_affected_rows(missing)
    validation_error(
      glue::glue(
        "The contributors_table has the following missing order numbers: {formatted_rows}"
      ),
      affected_rows = seq_len(nrow(missing))
    )
  } else {
    validation_success("There are no missing values in the order of publication.")
  }
}

#' Check for Duplicate Order Numbers
#'
#' This function checks for duplicate order numbers in the `Order in publication` 
#' column of the `contributors_table`. If duplicate order numbers are detected and
#' there are no shared first authors, the function returns an error.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "error".}
#' \item{message}{An informative message indicating the order numbers that are duplicated.}
check_duplicate_order <- function(contributors_table) {
  ## Check if there are shared first authors
  shared_first <- nrow(contributors_table[contributors_table$`Order in publication` == 1, ]) > 1
  
  duplicate <-
    contributors_table %>% 
    dplyr::count(.data$`Order in publication`) %>% 
    dplyr::filter(.data$n > 1)
  
  if (!shared_first & nrow(duplicate) != 0) {
    validation_error(
      glue::glue(
        "The order number is duplicated for the following: ", glue::glue_collapse(duplicate$`Order in publication`, sep = ", ", last = " and ")
      ),
      details = list(duplicated_orders = duplicate$`Order in publication`)
    )
  } else {
    validation_success("There are no duplicated order numbers in the contributors_table.")
  }
}

#' Check for Missing Affiliations
#'
#' This function checks whether at least one affiliation (either legacy 
#' or numbered) is provided for each contributor. If a contributor is missing 
#' all affiliation information, the function returns a warning.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating which rows have missing affiliations.}
check_affiliation <- function(contributors_table) {
  # Define global variables
  . = NULL
  
  # Identify legacy and numbered affiliation columns
  legacy_cols <- c("Primary affiliation", "Secondary affiliation")
  numbered_affiliation_cols <- colnames(contributors_table)[grepl("^Affiliation \\d+$", colnames(contributors_table))]
  
  # Combine all available affiliation columns
  cols_to_check <- c(
    intersect(legacy_cols, colnames(contributors_table)),
    numbered_affiliation_cols
  )
  
  # Get rows with missing affiliation values
  missing_rows <- 
    contributors_table %>%
    dplyr::mutate_at(
      dplyr::vars(dplyr::all_of(cols_to_check)),
      list(~ as.character(stringr::str_trim(tolower(.), side = "both")))
    ) %>%
    dplyr::filter_at(
      dplyr::vars(dplyr::all_of(cols_to_check)),
      dplyr::all_vars(is.na(.))
    )
  
  # Return warning if there are rows with missing affiliations
  if (nrow(missing_rows) > 0) {
    formatted_rows <- format_affected_rows(missing_rows)
    validation_warning(
      glue::glue(
        "There is no affiliation provided for: {formatted_rows}"
      ),
      affected_rows = seq_len(nrow(missing_rows))
    )
  } else {
    # Success if all rows have at least one affiliation
    validation_success("There are no missing affiliations in the contributors_table.")
  }
}

#' Check for Missing Corresponding Author
#'
#' This function checks if there is at least one corresponding author 
#' indicated in the `contributors_table`. If none are found, it returns a warning.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating whether a corresponding author is missing.}
check_missing_corresponding <- function(contributors_table) {
  if (any(contributors_table$`Corresponding author?`)) {
    validation_success("There is at least one author indicated as corresponding author.")
  } else {
    validation_warning("There is no indication of a corresponding author.")
  }
}

#' Check for Missing Emails for Corresponding Authors
#'
#' This function checks if email addresses are provided for all corresponding authors 
#' in the `contributors_table`. If any corresponding author is missing an email address, 
#' it returns a warning.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the row numbers of corresponding authors with missing emails.}
check_missing_email <- function(contributors_table) {
  corresponding <-
    contributors_table %>%
    dplyr::filter(!is.na(.data$`Corresponding author?`) & .data$`Corresponding author?` == TRUE)
  
  if (all(is.na(corresponding$`Email address`))) {
    formatted_rows <- format_affected_rows(corresponding)
    validation_warning(
      glue::glue("There is no email address provided for the corresponding author(s): {formatted_rows}"),
      affected_rows = seq_len(nrow(corresponding))
    )
  } else {
    validation_success("There are email addresses provided for all corresponding authors.")
  }
}

#' Check for Missing ORCID IDs
#'
#' This function checks for missing values in the `ORCID iD` column of the 
#' `contributors_table` and returns a warning if any ORCID IDs are missing.
#' 
#' If the `ORCID iD` column does not exist, the function returns a success message
#' since ORCID IDs are optional.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the row numbers with missing ORCID IDs, if any.}
check_missing_orcid <- function(contributors_table) {
  # Check if ORCID iD column exists
  if (!"ORCID iD" %in% colnames(contributors_table)) {
    return(validation_success("ORCID iD column is not present in the contributors_table."))
  }
  
  # Find rows with missing ORCID IDs (NA or empty string after trimming)
  missing <-
    contributors_table %>%
    dplyr::mutate(
      `ORCID iD` = stringr::str_trim(.data$`ORCID iD`, side = "both")
    ) %>%
    dplyr::filter(is.na(.data$`ORCID iD`) | .data$`ORCID iD` == "")
  
  if (nrow(missing) > 0) {
    return(validation_missing_values("ORCID iD", missing, "warning"))
  } else {
    return(validation_success("There are no missing ORCID IDs in the contributors_table."))
  }
}

#' Check for Contributors with No CRediT Roles
#'
#' This function checks whether each contributor has at least one CRediT taxonomy role 
#' checked. It returns a warning if any contributor has no roles assigned.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the rows with no CRediT roles assigned.}
check_credit <- function(contributors_table) {
  # Defining global variables
  . = NULL
  
  missing <-
    contributors_table %>% 
    dplyr::filter_at(dplyr::vars(dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)),
                     dplyr::all_vars(is.na(.) | . == FALSE))
  
  if (nrow(missing) != 0) {
    formatted_rows <- format_affected_rows(missing)
    validation_warning(
      glue::glue(
        "No CRediT roles are indicated for the following contributors, so they are not included in this output: {formatted_rows}"
      ),
      affected_rows = seq_len(nrow(missing))
    )
  } else {
    validation_success("All authors have at least one CRediT statement checked.")
  }
}

#' Check for Missing Conflict of Interest Statements
#'
#' This function checks if a conflict of interest statement is provided for each contributor.
#' It returns a warning if any contributor is missing this information.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the rows missing a conflict of interest statement.}
check_coi <- function(contributors_table) {
  if (any(is.na(contributors_table[, "Declares"]))) {
    missing <-
      contributors_table %>%
      dplyr::filter(is.na(.data[["Declares"]]))
    
    formatted_rows <- format_affected_rows(missing)
    validation_warning(
      glue::glue("The conflict of interest statement is missing for: {formatted_rows}"),
      affected_rows = seq_len(nrow(missing))
    )
  } else {
    validation_success("There are no missing conflict of interest statements.")
  }
}

#' Check for Duplicate Initials
#'
#' This function checks for duplicate initials in the `contributors_table`, taking into
#' account the `Firstname`, `Middle name`, and `Surname` columns. It issues a warning 
#' if duplicate initials are found, which may indicate ambiguous contributor identification.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "warning".}
#' \item{message}{An informative message indicating the initials that are duplicated.}
check_duplicate_initials <- function(contributors_table) {
  duplicate <-
    contributors_table %>% 
    dplyr::mutate_at(
      dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
      list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
    dplyr::mutate_at(dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
                     ~ dplyr::if_else(is.na(.),
                                      NA_character_,
                                      paste0(stringr::str_sub(., 1, 1), "."))) %>% 
    dplyr::mutate(Initials = dplyr::if_else(is.na(.data$`Middle name`),
                                            paste(.data$Firstname, .data$Surname),
                                            paste(.data$Firstname, .data$`Middle name`, .data$Surname))) %>% 
    dplyr::count(.data$Initials) %>% 
    dplyr::filter(.data$n > 1)
  
  if (nrow(duplicate) != 0) {
    validation_warning(
      glue::glue(
        "There are duplicate initials (full last names will be used to disambiguate them): ",
        glue::glue_collapse(toupper(duplicate$Initials), sep = ", ", last = " and ")
      ),
      details = list(duplicate_initials = duplicate$Initials)
    )
  } else {
    validation_success("There are no duplicate initials in the contributors_table.")
  }
}

#' Check allowed values in Author/Acknowledgee
#'
#' Verifies that all entries in `Author/Acknowledgee` belong to the allowed set:
#' "Author", "Acknowledgment only", "Don't agree to be named".
#'
#' @param contributors_table A dataframe of contributors.
#' @return list(type = "success"|"warning", message = <chr>)
check_author_acknowledgee_values <- function(contributors_table) {
  allowed <- c("Author", "Acknowledgment only", "Don't agree to be named")
  
  if (!"Author/Acknowledgee" %in% names(contributors_table)) {
    return(validation_warning("Column 'Author/Acknowledgee' is missing."))
  }
  
  invalid <-
    contributors_table %>%
    dplyr::mutate(`Author/Acknowledgee` = as.character(.data$`Author/Acknowledgee`)) %>%
    dplyr::filter(!is.na(.data$`Author/Acknowledgee`) & !(.data$`Author/Acknowledgee` %in% allowed))
  
  if (nrow(invalid) > 0) {
    bad_vals <- invalid %>% dplyr::distinct(.data$`Author/Acknowledgee`) %>% dplyr::pull()
    formatted_rows <- format_affected_rows(invalid)
    return(
      validation_warning(
        glue::glue(
          "Unrecognized values in 'Author/Acknowledgee': {glue::glue_collapse(bad_vals, sep = ', ', last = ' and ')}. ",
          "Affected: {formatted_rows}. ",
          "Allowed values are: {glue::glue_collapse(allowed, sep = ', ', last = ' and ')}."
        ),
        affected_rows = seq_len(nrow(invalid)),
        details = list(bad_values = bad_vals, allowed_values = allowed)
      )
    )
  }
  
  validation_success("All 'Author/Acknowledgee' values are valid.")
}

#' Check that only Authors are marked as Corresponding
#'
#' Warns if any row is marked `Corresponding author? == TRUE` while
#' `Author/Acknowledgee` is not "Author".
#'
#' @param contributors_table A dataframe of contributors.
#' @return list(type = "success"|"warning", message = <chr>)
check_corresponding_non_author <- function(contributors_table) {
  needed <- c("Author/Acknowledgee", "Corresponding author?")
  missing_cols <- setdiff(needed, names(contributors_table))
  if (length(missing_cols) > 0) {
    return(
      validation_warning(
        glue::glue(
          "Missing required column(s) for check: {glue::glue_collapse(missing_cols, sep = ', ', last = ' and ')}."
        ),
        details = list(missing_columns = missing_cols)
      )
    )
  }
  
  offenders <-
    contributors_table %>%
    # treat NA as FALSE
    dplyr::mutate(`Corresponding author?` = dplyr::coalesce(.data$`Corresponding author?`, FALSE)) %>%
    dplyr::filter(.data$`Corresponding author?` == TRUE,
                  .data$`Author/Acknowledgee` != "Author")
  
  if (nrow(offenders) > 0) {
    formatted_rows <- format_affected_rows(offenders)
    return(
      validation_warning(
        glue::glue(
          "Non-author rows are marked as corresponding author: {formatted_rows}."
        ),
        affected_rows = seq_len(nrow(offenders))
      )
    )
  }
  
  validation_success("Only authors are marked as corresponding.")
}

#' Check missing Author/Acknowledgee where names are present
#'
#' Warns if `Author/Acknowledgee` is missing for rows that have a name
#' (Firstname or Surname present).
#'
#' @param contributors_table A dataframe of contributors.
#' @return list(type = "success"|"warning", message = <chr>)
check_missing_author_acknowledgee <- function(contributors_table) {
  # Columns we rely on
  needed <- c("Author/Acknowledgee", "Firstname", "Surname")
  missing_cols <- setdiff(needed, names(contributors_table))
  if (length(missing_cols) > 0) {
    return(
      validation_warning(
        glue::glue(
          "Missing required column(s) for check: {glue::glue_collapse(missing_cols, sep = ', ', last = ' and ')}."
        ),
        details = list(missing_columns = missing_cols)
      )
    )
  }
  
  # helper to treat blanks as missing
  trim_na <- function(x) {
    y <- as.character(x)
    y <- stringr::str_trim(y, side = "both")
    y[y == ""] <- NA_character_
    y
  }
  
  df <-
    contributors_table %>%
    dplyr::mutate(
      Firstname = trim_na(.data$Firstname),
      Surname   = trim_na(.data$Surname),
      `Author/Acknowledgee` = trim_na(.data$`Author/Acknowledgee`)
    )
  
  missing_rows <-
    df %>%
    dplyr::filter(
      ( !is.na(.data$Firstname) | !is.na(.data$Surname) ) &
        is.na(.data$`Author/Acknowledgee`)
    )
  
  if (nrow(missing_rows) > 0) {
    formatted_rows <- format_affected_rows(missing_rows)
    return(
      validation_warning(
        glue::glue(
          "Missing 'Author/Acknowledgee' value for: {formatted_rows}."
        ),
        affected_rows = seq_len(nrow(missing_rows))
      )
    )
  }
  
  validation_success("All named rows have 'Author/Acknowledgee' filled.")
}

#' Check Non-Empty Filtered Contributor Subset
#'
#' This function verifies that the filtered contributors table is not empty
#' after applying inclusion/exclusion criteria (e.g., include = "Author",
#' excluding "Don't agree to be named").
#'
#' @param contributors_table A dataframe of contributors after filtering.
#' @param context Optional named list providing contextual information
#'   such as \code{include} ("author" or "acknowledgee").
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "error".}
#' \item{message}{A descriptive validation message.}
#'
#' @examples
#' check_nonempty_filtered_subset(filtered_tbl, context = list(include = "author"))
#'
check_nonempty_filtered_subset <- function(contributors_table, context = NULL) {
  if (nrow(contributors_table) == 0) {
    include <- context$include %||% "the selected group"
    validation_error(
      glue::glue(
        "No rows remain after filtering by '{include}' and excluding 'Don't agree to be named'."
      ),
      details = list(include = include)
    )
  } else {
    validation_success("Contributors subset is non-empty after filtering.")
  }
}

#' Check for Presence of Assigned CRediT Roles
#'
#' This function verifies that at least one CRediT taxonomy role
#' is checked for any contributor in the filtered dataset.
#'
#' @param contributors_table A dataframe containing the contributors' information.
#' @param context Optional named list providing contextual information.
#'
#' @return A list containing:
#' \item{type}{Type of validation result: "success" or "error".}
#' \item{message}{A descriptive validation message.}
#'
#' @details
#' This validation is equivalent to the internal check used in
#' \code{print_credit_roles()} to ensure that contributors have at least one
#' CRediT category marked as TRUE.
#'
#' @examples
#' check_roles_present(filtered_tbl)
#'
check_roles_present <- function(contributors_table) {
  # Identify role columns using credit_taxonomy
  role_cols <- intersect(
    dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`),
    colnames(contributors_table)
  )
  
  if (length(role_cols) == 0) {
    return(validation_error("No CRediT role columns were found in the contributors table."))
  }
  
  # Check if any role is TRUE (excluding NA values)
  has_any_role <- any(sapply(role_cols, function(col) {
    if (col %in% colnames(contributors_table)) {
      any(contributors_table[[col]] == TRUE, na.rm = TRUE)
    } else {
      FALSE
    }
  }))
  
  if (!has_any_role) {
    validation_error("There are no CRediT roles checked for any of the contributors.")
  } else {
    validation_success("At least one contributor has a CRediT role checked.")
  }
}

#' Warn when 'Author/Acknowledgee' column is missing
#'
#' Emits a single warning informing users that, when the column is absent,
#' the app treats all rows as authors and that adding the column enables
#' a separate acknowledgee statement.
#'
#' @param contributors_table A dataframe of contributors.
#' @param context Optional named list (unused).
#' @return A standardized validation result list.
check_author_acknowledgee_missing <- function(contributors_table, context = NULL) {
  if ("Author/Acknowledgee" %in% names(contributors_table)) {
    return(validation_success("'Author/Acknowledgee' column is present."))
  }
  validation_warning(
    "Column 'Author/Acknowledgee' is missing; all rows are treated as authors. Add this column to generate a separate acknowledgee statement."
  )
}

