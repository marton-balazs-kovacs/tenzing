#' Check affiliation columns for consistency
#'
#' This function checks if both legacy (`Primary affiliation` and `Secondary affiliation`) 
#' and `Affiliation {n}` columns are present in the contributors_table. If both are present,
#' it raises a warning to suggest using only one format to ensure consistent results. 
#' In the first version of tenzing only two affiliation were allowed per contributor
#' and the required names for the columns were `Primary affiliation` and `Secondary affiliation`. In the new version of the spreadsheet
#' any number of affiliation columns can be created as long as they follow the `Affiliation {number}` naming convention.
#'
#' @param contributors_table A dataframe containing the contributors' table.
#'
#' @return A list containing `valid` (TRUE/FALSE) and a `message` (if applicable).
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
      list(type = "warning",
           message = "Both legacy columns ('Primary affiliation' or 'Secondary affiliation') and 'Affiliation {n}' columns are present. Please use only one format for consistent results.")
    )
  }
  
  # If only one system is detected, return success
  return(list(
    type = "success",
    message = "Affiliation column names are used consistently."
  ))
}

#' Check missing surnames
check_missing_surname <- function(contributors_table) {
  # Check for missing surname
  if (any(is.na(contributors_table[, "Surname"]))) {
    missing <-
      contributors_table %>%
      tibble::rownames_to_column(var = "rowname") %>%
      dplyr::filter(is.na(.data$Surname))
    
    list(
      type = "warning",
      message = glue::glue(
        "The Surname is missing for row numbers: ",
        glue::glue_collapse(missing$rowname, sep = ", ", last = " and ")
      )
    )
  } else {
    list(type = "success",
         message = "There are no missing surnames.")
  }
}

#' Check missing firstnames
check_missing_firstname <- function(contributors_table) {
  if (any(is.na(contributors_table[, "Firstname"]))) {
    missing <-
      contributors_table %>%
      tibble::rownames_to_column(var = "rowname") %>% 
      dplyr::filter(is.na(.data$Firstname))
    
    list(
      type = "warning",
      message = glue::glue("The firstname is missing for row number: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
    )
  } else{
    list(
      type = "success",
      message = "There are no missing firstnames."
    )
  }
}

#' Check for duplicate names
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
    list(
      type = "warning",
      message = glue::glue("The contributors_table has the following duplicate names: ", glue::glue_collapse(stringr::str_to_title(duplicate$Names), sep = ", ", last = " and "))
    )
  } else {
    list(
      type = "success",
      message = "There are no duplicate names in the contributors_table."
    )
  }
}

#' Check for missing values in the `Order in publication` column
check_missing_order <- function(contributors_table) {
  missing <-
    contributors_table %>% 
    tibble::rownames_to_column(var = "rowname") %>%
    dplyr::filter(is.na(.data$`Order in publication`))
  
  if (nrow(missing) != 0) {
    list(
      type = "error",
      message = glue::glue("The contributors_table has the following missing order numbers: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
    )
  } else {
    list(
      type = "success",
      message = "There are no missing values in the order of publication."
    )
  }
}

#' Check for duplicate order
check_duplicate_order <- function(contributors_table) {
  ## Check if there are shared first authors
  shared_first <- nrow(contributors_table[contributors_table$`Order in publication` == 1, ]) > 1
  
  duplicate <-
    contributors_table %>% 
    dplyr::count(.data$`Order in publication`) %>% 
    dplyr::filter(.data$n > 1)
  
  if (!shared_first & nrow(duplicate) != 0) {
    list(
      type = "error",
      message = glue::glue("The order number is duplicated for the following: ", glue::glue_collapse(duplicate$`Order in publication`, sep = ", ", last = " and "))
    )
  } else {
    list(
      type = "success",
      message = "There are no duplicated order numbers in the contributors_table."
    )
  }
}

#' Check if at least one affiliation is provided for each contributor
#' Check if at least one affiliation is provided for each contributor
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
    tibble::rownames_to_column(var = "rowname") %>%
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
    list(
      type = "warning",
      message = glue::glue(
        "There is no affiliation provided for the following row number(s): ",
        glue::glue_collapse(missing_rows$rowname, sep = ", ", last = " and ")
      )
    )
  } else {
    # Success if all rows have at least one affiliation
    list(
      type = "success",
      message = "There are no missing affiliations in the contributors_table."
    )
  }
}

#' Check if the corresponding author is missing
check_missing_corresponding <- function(contributors_table) {
  if (any(contributors_table$`Corresponding author?`)) {
    list(
      type = "success",
      message = "There is at least one author indicated as corresponding author.")
  } else {
    list(
      type = "warning",
      message = "There is no indication of a corresponding author.")
  }
}

#' Check if email is provided for the corresponding author
check_missing_email <- function(contributors_table) {
  corresponding <-
    contributors_table %>%
    tibble::rownames_to_column(var = "rowname") %>% 
    dplyr::filter(.data$`Corresponding author?` == TRUE)
  
  if (all(is.na(corresponding$`Email address`))) {
    list(
      type = "warning",
      message = glue::glue("There is no email address provided for the corresponding author(s): ", glue::glue_collapse(corresponding$rowname, sep = ", ", last = " and ")))
  } else {
    list(
      type = "success",
      message = "There are email addresses provided for all corresponding authors.")
  }
}

#' Check for contributors with no CRediT roles
check_credit <- function(contributors_table) {
  # Defining global variables
  . = NULL
  
  missing <-
    contributors_table %>% 
    tibble::rownames_to_column(var = "rowname") %>% 
    dplyr::filter_at(dplyr::vars(dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)),
                     dplyr::all_vars(. == FALSE))
  
  if (nrow(missing) != 0) {
    list(
      type = "warning",
      message = glue::glue("No CRediT categories are indicated for the row number(s) that follow, although tenzing will still provide other outputs: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and ")))
  } else {
    list(
      type = "success",
      message = "All authors have at least one CRediT statement checked.")
  }
}

#' Check for missing COI statement
check_coi <- function(contributors_table) {
  if (any(is.na(contributors_table[, "Conflict of interest"]))) {
    missing <-
      contributors_table %>%
      tibble::rownames_to_column(var = "rowname") %>% 
      dplyr::filter(is.na(.data[["Conflict of interest"]]))
    
    list(
      type = "warning",
      message = glue::glue("The conflict of interest statement is missing for row number(s): ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
    )
  } else {
    list(
      type = "success",
      message = "There are no missing conflict of interest statements."
    )
  }
}

#' Check for same initials
#' 
#' This function checks the contributors_table for duplicate initials, and
#' issues a warning that the surnames will be used to differentiate
#' between the users.
#' 
#' @param contributors_table the imported contributors_table
#' 
#' @return The function returns a list with two character strings. type
#' records whether the check was successful or not (either warning or success).
#' message shows the accompanying informative message.
#' 
#' @importFrom rlang .data
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
    list(
      type = "warning",
      message = glue::glue("The contributors_table has the following duplicate initials: ", glue::glue_collapse(toupper(duplicate$Initials), sep = ", ", last = " and "))
    )
  } else {
    list(
      type = "success",
      message = "There are no duplicate initials in the contributors_table."
    )
  }
}