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
validate_contributors_table <- function(contributors_table, config_path) {
  # Check if contributors_table is a dataframe
  if (!is.data.frame(contributors_table)) {
    stop("The provided contributors_table is not a dataframe.")
  }
  
  # Load the YAML config
  config <- yaml::read_yaml(config_path)
  
  # Initialize ColumnValidator with the column configuration
  column_validator <- ColumnValidator$new(config_input = config)
  
  # Run column validation
  column_results <- column_validator$validate_columns(contributors_table)
  
  return(column_results)

}
