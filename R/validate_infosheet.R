validate_infosheet <- function(infosheet) {
  # Check if infosheet is a dataframe ---------------------------
  if (!is.data.frame(infosheet)) stop("The provided infosheet is not a dataframe.")
  
  # Check necessary variable names ---------------------------
  check_cols <- function(x) {
    col_match <- tibble::tibble(
      cols = colnames(infosheet_template),
      check = tibble::has_name(x, cols))

    if (!all(col_match$check)) {
      missing <-
        col_match %>%
        dplyr::filter(check == FALSE)
      
      stop(glue::glue("Missing column(s): ", glue::glue_collapse(missing$cols, sep = ", ", last = " and ")))
      # list(
      #   type = "error",
      #   message = glue::glue("Missing column(s): ", glue::glue_collapse(missing$cols, sep = ", ", last = " and "))
      # )
      }
    # else {
    #     list(
    #       type = "success",
    #       message = "There are no missing columns in the infosheet."
    #     )
    #   }
  }
  
  check_cols(infosheet)

  # Check author names ---------------------------
  check_missing_surname <- function(x) {
  # Check for missing surname
    if (any(is.na(x[, "Surname"]))) {
      missing <-
        x %>%
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::filter(is.na(Surname))
      
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
  # Check for missing firstname
  check_missing_firstname <- function(x) {
    if (any(is.na(x[, "Firstname"]))) {
      missing <-
        x %>%
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::filter(is.na(Firstname))
      
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
        dplyr::vars(Firstname, `Middle name`, Surname),
        list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
      dplyr::mutate(Names = dplyr::if_else(is.na(`Middle name`),
                                           paste(Firstname, Surname),
                                           paste(Firstname, `Middle name`, Surname))) %>% 
      dplyr::count(Names) %>% 
      dplyr::filter(n > 1)
    
    if (nrow(duplicate) != 0) {
      list(
        type = "warning",
        message = glue::glue("The infosheet has the following duplicate names: ", glue::glue_collapse(stringr::str_to_title(duplicate$Names), sep = ", ", last = " and "))
      )
    } else {
      list(
        type = "success",
        message = "There are no duplicate names in the infosheet."
      )
    }
    }
  # Check for same initials, issue a warning that we will use surname to differentiate
  check_duplicate_initials <- function(x) {
    duplicate <-
      x %>% 
      dplyr::mutate_at(
        dplyr::vars(Firstname, `Middle name`, Surname),
        list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
      dplyr::mutate_at(dplyr::vars(Firstname, `Middle name`, Surname),
                       ~ dplyr::if_else(is.na(.),
                                        NA_character_,
                                        paste0(stringr::str_sub(., 1, 1), "."))) %>% 
      dplyr::mutate(Initials = dplyr::if_else(is.na(`Middle name`),
                                              paste(Firstname, Surname),
                                              paste(Firstname, `Middle name`, Surname))) %>% 
      dplyr::count(Initials) %>% 
      dplyr::filter(n > 1)
    
    if (nrow(duplicate) != 0) {
      list(
        type = "warning",
        message = glue::glue("The infosheet has the following duplicate initials: ", glue::glue_collapse(toupper(duplicate$Initials), sep = ", ", last = " and "))
      )
    } else {
      list(
        type = "success",
        message = "There are no duplicate initials in the infosheet."
      )
      }
    }
  # Check order ---------------------------
  ## Check if order value is not missing
  check_missing_order <- function(x) {
    missing <-
      x %>% 
      tibble::rownames_to_column(var = "rowname") %>%
      dplyr::filter(is.na(`Order in publication`))
    
    if (nrow(missing) != 0) {
      list(
        type = "error",
        message = glue::glue("The infosheet has the following missing order numbers: ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
      )
    } else {
      list(
        type = "success",
        message = "There is no missing value in the order of publication."
      )
    }
  }
  ## Check if order has only unique values
  check_duplicate_order <- function(x) {
    duplicate <-
      x %>% 
      dplyr::count(`Order in publication`) %>% 
      dplyr::filter(n > 1)
    
    if (nrow(duplicate) != 0) {
      list(
        type = "error",
        message = glue::glue("The order number is duplicated for the following: ", glue::glue_collapse(duplicate$`Order in publication`, sep = ", ", last = " and "))
        )
      } else {
        list(
          type = "success",
          message = "There is no duplicated order number in the infosheet."
        )
      }
    }
  # Check if at least one affiliation is provided for each name ---------------------------
  check_affiliation <- function(x) {
    if (any(is.na(x[, "Primary affiliation"]) & is.na(x[, "Secondary affiliation"]))) {
      missing <-
        x %>% 
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::mutate_at(
          dplyr::vars(`Primary affiliation`, `Secondary affiliation`),
          list(~ as.character(stringr::str_trim(tolower(.), side = "both")))) %>% 
        dplyr::filter_at(
          dplyr::vars(`Primary affiliation`, `Secondary affiliation`),
          dplyr::all_vars(is.na(.)))
      
      list(
        type = "error",
        message = glue::glue("There is no affiliation provided for the following row number(s):", glue::glue_collapse(missing$rowname, sep = ", ", last = " and "))
        )
      } else {
        list(
          type = "success",
          message = "There is no missing affiliation in the infosheet."
        )
      }
    }
  # Check corresponding author ---------------------------
  ## Check if corresponding author is not missing
  check_missing_corresponding <- function(x) {
    if (any(x$`Corresponding author?`)) {
      list(
        type = "success",
        message = "There is at least one author added as corresponding author.")
      } else {
        list(
          type = "warning",
          message = "There is no author added as corresponding author.")
      }
    }
    
    ## Check if email address is provided
    check_missing_email <- function(x) {
      corresponding <-
        x %>%
        tibble::rownames_to_column(var = "rowname") %>% 
        dplyr::filter(`Corresponding author?` == TRUE)
      
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
    missing <-
      x %>% 
      tibble::rownames_to_column(var = "rowname") %>% 
      dplyr::filter_at(dplyr::vars(dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)),
                       dplyr::all_vars(. == FALSE))
  
    if (nrow(missing) != 0) {
      list(
        type = "warning",
        message = glue::glue("There is no credit taxonomy checked for the following row number(s): ", glue::glue_collapse(missing$rowname, sep = ", ", last = " and ")))
      } else {
        list(
          type = "success",
          message = "All authors have at least one CRediT statement checked.")
      }
    }
  
  # Return output ---------------------------
  list(
    # missing_cols = check_cols(infosheet),
    missing_surname = check_missing_surname(infosheet),
    missing_firstname = check_missing_firstname(infosheet),
    duplicate_names = check_duplicate_names(infosheet),
    duplicate_initials = check_duplicate_initials(infosheet),
    missing_order = check_missing_order(infosheet),
    duplicate_order = check_duplicate_order(infosheet),
    missing_affiliation = check_affiliation(infosheet),
    missing_corresponding = check_missing_corresponding(infosheet),
    missing_email = check_missing_email(infosheet),
    missing_credit = check_credit(infosheet)
  )
  }

