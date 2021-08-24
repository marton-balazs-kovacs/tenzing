#' Validating the contributors table
#' 
#' This function validates the `contributors_table` provided to it by checking whether the
#' provided `contributors_table` is compatible with the [contributors_table_template()]. The function
#' early escapes only if the provided `contributors_table` is not a dataframe, the variable
#' names that are present in the `contributors_table_template` are missing, or if the 
#' `contributors_table` is empty.
#' 
#' @section The function checks the following statements:
#' \itemize{
#'   \item error, the provided contributors_table is a dataframe
#'   \item error, the provided contributors_table does not have the same column names as the template
#'   \item error, the provided contributors_table is empty
#'   \item error, `Firstname` variable has missing value for one of the contributors
#'   \item error, `Surname` variable has a missing value for one of the contributors
#'   \item warning, the contributors_table has duplicate names
#'   \item warning, the contributors_table has names with duplicate initials
#'   \item error, the `'Order in publication'` variable has missing values
#'   \item error, the `'Order in publication'` variable has duplicate values
#'   \item error, both `'Primary affiliation'` and `'Secondary affiliation'` variables
#'     are missing for one contributor
#'   \item warning, there is no corresponding author added
#'   \item warning, email address is missing for the corresponding author
#'   \item warning, there is at least one CRediT role provided for all contributors
#' }
#' 
#' @param contributors_table dataframe, filled out contributors_table
#' 
#' @return The function returns a list for each checked statement. Each list contains
#'   a `type` vector that stores whether the statement passed the check "success"
#'   or failed "warning" or "error", and a `message` vector that contains information
#'   about the nature of the check.
#' @export 
#' @examples
#' # Read the example contributors table
#' file_path <- system.file("extdata", "contributors_table_example.csv", package = "tenzing", mustWork = TRUE)
#' my_contributors_table <- read_contributors_table(contributors_table_path = file_path)
#' # Validate the table
#' check_result <- validate_contributors_table(contributors_table = my_contributors_table)
#' # Show the results of the checks
#' purrr::map(check_result, "type")
#' # Show the corresponding messages
#' purrr::map(check_result, "message")
#' 
#' @importFrom rlang .data
#' @importFrom utils data
validate_contributors_table <- function(contributors_table) {
  # Check if contributors_table is a dataframe ---------------------------
  if (!is.data.frame(contributors_table)) stop("The provided contributors_table is not a dataframe.")
  
  # Check necessary variable names ---------------------------
  check_cols <- function(x) {
    # Defining global variables
    contributors_table_template = NULL
    
    utils::data("contributors_table_template", envir = environment(), package = "tenzing")

    col_match <- tibble::tibble(
      cols = colnames(contributors_table_template),
      check = tibble::has_name(x, .data$cols))

    if (!all(col_match$check)) {
      missing <-
        col_match %>%
        dplyr::filter(.data$check == FALSE)
      
      stop(glue::glue("Missing column(s): ", glue::glue_collapse(missing$cols, sep = ", ", last = " and ")))
      }
  }
  
  check_cols(contributors_table)
  
  # Check if contributors_table is empty ---------------------------
  if (all(is.na(contributors_table[, c("Firstname", "Middle name", "Surname")]))) {
    stop("There are no contributors in the table.")
  }
  
  # Delete empty rows ---------------------------
  contributors_table_clean <- clean_contributors_table(contributors_table)

  # Check author names ---------------------------
  check_missing_surname <- function(x) {
  # Check for missing surname
    if (any(is.na(x[, "Surname"]))) {
      missing <-
        x %>%
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::filter(is.na(.data$Surname))
      
      list(
        type = "error",
        message = glue::glue("The Surname is missing for row numbers: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
      )
      } else {
        list(
          type = "success",
          message = "There are no missing surnames."
        )
      }
    }
  # Check for missing first name
  check_missing_firstname <- function(x) {
    if (any(is.na(x[, "Firstname"]))) {
      missing <-
        x %>%
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::filter(is.na(.data$Firstname))
      
      list(
        type = "error",
        message = glue::glue("The firstname is missing for row number: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
        )
    } else{
      list(
        type = "success",
        message = "There are no missing firstnames."
      )
    }
  }
  # Check for same names
  check_duplicate_names <- function(x) {
    duplicate <- 
      x %>% 
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
  # Check for same initials, issue a warning that we will use surname to differentiate
  check_duplicate_initials <- function(x) {
    duplicate <-
      x %>% 
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
  # Check order ---------------------------
  ## Check if order value is not missing
  check_missing_order <- function(x) {
    missing <-
      x %>% 
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
  ## Check if order has only unique values
  check_duplicate_order <- function(x) {
    ## Check if there are shared first authors
    shared_first <- nrow(contributors_table[contributors_table$`Order in publication` == 1, ]) > 1
    
    duplicate <-
      x %>% 
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
  # Check if at least one affiliation is provided for each name ---------------------------
  check_affiliation <- function(x) {
    # Defining global variables
    . = NULL
    
    if (any(is.na(x[, "Primary affiliation"]) & is.na(x[, "Secondary affiliation"]))) {
      missing <-
        x %>% 
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::mutate_at(
          dplyr::vars(.data$`Primary affiliation`, .data$`Secondary affiliation`),
          list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
        dplyr::filter_at(
          dplyr::vars(.data$`Primary affiliation`, .data$`Secondary affiliation`),
          dplyr::all_vars(is.na(.)))
      
      list(
        type = "error",
        message = glue::glue("There is no affiliation provided for the following row number(s):", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
        )
      } else {
        list(
          type = "success",
          message = "There are no missing affiliations in the contributors_table."
        )
      }
    }
  # Check corresponding author ---------------------------
  ## Check if corresponding author is not missing
  check_missing_corresponding <- function(x) {
    if (any(x$`Corresponding author?`)) {
      list(
        type = "success",
        message = "There is at least one author indicated as corresponding author.")
      } else {
        list(
          type = "warning",
          message = "There is no indication of a corresponding author.")
      }
    }
    
    ## Check if email address is provided
    check_missing_email <- function(x) {
      corresponding <-
        x %>%
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
  # Check if there is a name but all CRediT statement is FALSE ---------------------------
  check_credit <- function(x) {
    # Defining global variables
    . = NULL
    
    missing <-
      x %>% 
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
  
  # Return output ---------------------------
  res <- list(
    missing_surname = check_missing_surname(contributors_table_clean),
    missing_firstname = check_missing_firstname(contributors_table_clean),
    duplicate_names = check_duplicate_names(contributors_table_clean),
    duplicate_initials = check_duplicate_initials(contributors_table_clean),
    missing_order = check_missing_order(contributors_table_clean),
    duplicate_order = check_duplicate_order(contributors_table_clean),
    missing_affiliation = check_affiliation(contributors_table_clean),
    missing_corresponding = check_missing_corresponding(contributors_table_clean),
    missing_credit = check_credit(contributors_table_clean)
    )
    
    if(res$missing_corresponding$type == "success") {
      res <- c(
        res,
        list(missing_email = check_missing_email(contributors_table_clean))
      )
    }
    
    return(res)
  }

#' Check for same initials
#' 
#' This function checks the contributors_table for duplicate initials, and
#' issues a warning that the surnames will be used to differentiate
#' between the users.
#' 
#' @param contributors_table the imported contributors_table
#' 
#' @return The function returns
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
