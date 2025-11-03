#' ColumnValidator Class for Contributors Table
#'
#' The `ColumnValidator` class performs column-level validation for a contributors table.
#' It ensures that required columns exist, applying logical validation rules such as:
#' \itemize{
#'   \item **AND**: All listed columns must be present.
#'   \item **OR**: At least one of the listed columns must be present.
#'   \item **NOT**: None of the listed columns should be present.
#' }
#'
#' This validation process is **configurable** via a YAML file.
#'
#' @section Regex Matching:
#' Some columns may follow a dynamic naming pattern (e.g., "Affiliation 1", "Affiliation 2").
#' The `regex` field in the YAML configuration allows **pattern-based matching**.
#'
#' @section YAML Configuration:
#' The validator reads a YAML file (e.g., `inst/config/column_validation.yaml`) that defines:
#' \itemize{
#'   \item **Rules** specifying required columns.
#'   \item **Operators** (`AND`, `OR`, `NOT`) for column validation.
#'   \item **Regex patterns** for dynamically named columns.
#'   \item **Severity levels** (`error` or `warning`).
#' }
#'
#' Example:
#' \preformatted{
#' column_config:
#'   rules:
#'     minimal:
#'       operator: "AND"
#'       columns:
#'         - Firstname
#'         - Middle name
#'         - Surname
#'         - Order in publication
#'       severity: "error"
#' 
#'     affiliation:
#'       operator: "OR"  
#'       columns:
#'         - Primary affiliation
#'         - Secondary affiliation  
#'       regex: "^Affiliation [0-9]+$"
#'       severity: "error"
#'
#'     title:
#'       operator: "AND"
#'       columns:
#'         - Corresponding author?
#'         - Email address
#'       severity: "warning"
#' }
#'
#' @section Integration with ValidateOutput:
#' The `ValidateOutput` class initializes an instance of `ColumnValidator` to perform column checks.
#' If required columns are missing, the validation process halts, returning **only column validation errors**.
#'
#' @section Usage:
#' \preformatted{
#' # Load a column validation config
#' config <- yaml::read_yaml("inst/config/column_validation.yaml")
#' 
#' # Create a ColumnValidator instance
#' column_validator <- ColumnValidator$new(config_input = config$column_config)
#' 
#' # Validate a contributors table
#' results <- column_validator$validate_columns(contributors_table)
#' }
#'
#' @seealso \code{\link{ValidateOutput}} which integrates this class for validation.
#'
#' @export
ColumnValidator <- R6::R6Class(
  classname = "ColumnValidator",
  
  public = list(
    #' @field config Stores the column validation rules loaded from the YAML file.
    config = NULL,
    
    #' @description
    #' Initializes the `ColumnValidator` class.
    #' @param config_input A parsed YAML configuration containing column validation rules.
    initialize = function(config_input) {
      # Expect a pre-parsed YAML list for config_input
      if (!is.list(config_input)) {
        stop("config_input must be a list representing the column validation rules.")
      }
      self$config <- config_input
    },
    
    #' @description
    #' Validates columns in the provided contributors table.
    #' @param contributors_table A dataframe containing contributor data.
    #' @return A list of validation results, each containing:
    #' \itemize{
    #'   \item `type`: `"error"`, `"warning"`, or `"success"`.
    #'   \item `message`: A descriptive validation message.
    #' }
    validate_columns = function(contributors_table) {
      results <- list()
      
      for (rule_name in names(self$config$rules)) {
        rule <- self$config$rules[[rule_name]]
        result <- self$check_rule(contributors_table, rule, rule_name)
        results[[rule_name]] <- result
      }
      
      return(results)
    },
    
    #' @description
    #' Checks whether the contributors table satisfies a specific validation rule.
    #' @param contributors_table A dataframe containing contributor data.
    #' @param rule A validation rule from the YAML configuration.
    #' @param rule_name The name of the validation rule.
    #' @return A validation result indicating whether the rule passed or failed.
    check_rule = function(contributors_table, rule, rule_name) {
      operator <- rule$operator
      columns <- rule$columns
      severity <- rule$severity %||% "warning"  # Default severity to "warning"
      regex <- rule$regex %||% NULL  # Use regex if provided
      
      # Get actual columns if regex is provided
      matched_columns <- character(0)  # Default to empty if no matches
      if (!is.null(regex)) {
        
        matched_columns <- colnames(contributors_table)[grepl(regex, colnames(contributors_table))]
        
        # For OR operator, only add actual matched columns (not the regex pattern)
        # For AND operator, if regex doesn't match, add regex pattern to track missing requirement
        if (length(matched_columns) == 0) {
          if (operator == "AND") {
            matched_columns <- regex  # Keep the regex label for error messages in AND case
          }
          # For OR operator, don't add regex pattern - let explicit columns be checked instead
        }
  
        # Ensure matched columns are appended to required columns
        columns <- unique(c(columns, matched_columns))
      }
      
      # Apply the operator logic
      missing_columns <- setdiff(columns, colnames(contributors_table))
      present_columns <- intersect(columns, colnames(contributors_table))
      
      if (operator == "AND") {
        if (length(missing_columns) > 0) {
          return(list(
            type = severity,
            message = glue::glue("Missing columns: {paste(missing_columns, collapse = ', ')}")
          ))
        }
      } else if (operator == "OR") {
        if (length(present_columns) == 0) {
          return(list(
            type = severity,
            message = glue::glue("None of the required columns are present: {paste(columns, collapse = ', ')}")
          ))
        }
      } else if (operator == "NOT") {
        if (length(present_columns) > 0) {
          return(list(
            type = severity,
            message = glue::glue("Unexpected columns found: {paste(present_columns, collapse = ', ')}")
          ))
        }
      } else {
        stop(glue::glue("Unknown operator: {operator}"))
      }
      
      # If validation passes
      return(list(
        type = "success",
        message = "All column requirements satisfied."
      ))
    }
  )
)
