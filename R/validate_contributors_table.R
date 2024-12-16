#' Validating the contributors table
#' 
#' This function validates the `contributors_table` provided to it by checking whether the
#' provided `contributors_table` is compatible with the [contributors_table_template()] or the [contributors_table_template_deluxe()]. The function
#' early escapes only if the provided `contributors_table` is not a dataframe, the variable
#' names that are present in the `contributors_table_template` or`contributors_table_template_deluxe` are missing, or if the 
#' `contributors_table` is empty.
#' 
#' @section The function checks the following statements:
#' \itemize{
#'   \item error, the provided contributors_table is not a dataframe
#'   \item error, the provided contributors_table does not have the same column names as the simple or deluxe template
#'   \item error, the provided contributors_table is empty
#'   \item warning, `Firstname` variable has missing value for one or more of the contributors
#'   \item warning, `Surname` variable has a missing value for one or more of the contributors
#'   \item warning, the contributors_table has duplicate names
#'   \item warning, the contributors_table has names with duplicate initials
#'   \item error, the `'Order in publication'` variable has missing values
#'   \item error, the `'Order in publication'` variable has duplicate values 
#'   \item warning, both `'Primary affiliation'` and `'Secondary affiliation'` variables
#'     are missing for one or more contributors
#'   \item warning, there is no corresponding author added
#'   \item warning, email address is missing for the corresponding author
#'   \item warning, there is at least one CRediT role provided for all contributors
#'   \item warning, author has missing conflict on interest statement
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
validate_contributors_table <- function(contributors_table, output_type = "minimal") {
  # Check if contributors_table is a dataframe ---------------------------
  if (!is.data.frame(contributors_table)) stop("The provided contributors_table is not a dataframe.")
  
  # Check necessary variable names for each output type ---------------------------
  available_outputs <- check_outputs(contributors_table)
  
  # If all outputs disabled throw error
  if (all(!unlist(available_outputs))) {
    stop("All outputs are disabled. Please ensure the contributors table includes the required columns to generate at least one output.")
  }
  
  # Check if contributors_table is empty ---------------------------
  if (all(is.na(contributors_table[, c("Firstname", "Middle name", "Surname")]))) {
    stop("There are no contributors in the table.")
  }
  
  # Delete empty rows ---------------------------
  contributors_table_clean <- clean_contributors_table(contributors_table)
  
  # Run tests ---------------------------
  # Define validation tests for each output type
  minimal_tests <- list(
    check_missing_surname = check_missing_surname,
    check_missing_firstname = check_missing_firstname,
    check_duplicate_names = check_duplicate_names,
    check_duplicate_initials = check_duplicate_initials,
    check_missing_order = check_missing_order,
    check_duplicate_order = check_duplicate_order
  )
  
  credit_tests <- c(
    minimal_tests,
    list(check_credit = check_credit)
  )
  
  title_tests <- c(
    minimal_tests,
    list(
      check_affiliation = check_affiliation,
      check_missing_corresponding = check_missing_corresponding,
      check_missing_email = check_missing_email
    )
  )

  coi_tests <- c(
    minimal_tests,
    list(check_coi = check_coi)
  )
  
  # Map output types to validation tests
  validation_map <- list(
    credit = credit_tests,
    title = title_tests,
    xml = credit_tests,
    yaml = title_tests,
    funding = minimal_tests,
    coi = coi_tests,
    minimal = minimal_tests
  )
  
  # Check if the provided output_type is valid
  if (!output_type %in% names(validation_map)) {
    stop(glue::glue("Invalid output type: '{output_type}'. Valid types are: {glue::glue_collapse(names(validation_map), sep = ', ', last = ' and ')}."))
  }
  
  # Run the selected validation tests
  selected_tests <- validation_map[[output_type]]
  
  # Apply the selected validation functions
  results <- purrr::map(selected_tests, ~ {
    result <- .x(contributors_table_clean)
    list(type = result$type, message = result$message)
  })
  
  # Return validation results ---------------------------
  return(results)
  }