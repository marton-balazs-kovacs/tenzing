#' Validating the contributors table
#' 
#' This function validates the `contributors_table` provided to it by checking whether the
#' provided `contributors_table` is compatible with the [contributors_table_template()]. The function
#' early escapes only if the provided `contributors_table` is not a dataframe, the variable
#' names that are present in the `contributors_table_template` is missing, or if the 
#' `contributors_table` is empty.
#' 
#' @section The function checks the following statements:
#' \itemize{
#'   \item error, the provided contributors_table is not a dataframe
#'   \item error, none of the outputs can be created based the provided contributors_table due to missing columns
#'   \item error, the provided contributors_table is empty
#' }
#' 
#' @param contributors_table dataframe, filled out contributors_table
#' @param config_path character, file path to validation configuration file
#' 
#' @return The function returns a list for each checked statement. Each list contains
#'   a `type` vector that stores whether the statement passed the check "success"
#'   or failed "warning" or "error", and a `message` vector that contains information
#'   about the nature of the check.
#' @export 
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
  column_validator <- ColumnValidator$new(config_input = config$column_config)
  
  # Run column validation
  column_results <- column_validator$validate_columns(contributors_table)
  
  return(column_results)
}
