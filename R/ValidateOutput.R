#' ValidateOutput Class for Contributors Table Validation
#'
#' The `ValidateOutput` class runs both **column-based validation** (ensuring required columns exist)
#' and **data-based validation** (checking correctness of values) for a contributors table.
#' 
#' It integrates two validation classes:
#' \itemize{
#'   \item **\code{\link{ColumnValidator}}**: Ensures required columns are present.
#'   \item **\code{\link{Validator}}**: Runs content-based validation checks on contributor data.
#' }
#' 
#' This validation process is **configured via a YAML file**. The `inst/config/` package di contains predefined YAML configuration files
#' for each of the six output types.
#'
#' @section Column Validation:
#' The `ColumnValidator` ensures that required columns exist **before running data-based checks**.
#' If a required column is missing, **validation stops immediately** with an error.
#' 
#' Example YAML Configuration (`inst/config/title_validation.yaml`):
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
#' @section General Data Validation:
#' The `Validator` runs content-based validation checks **after** column validation passes.
#' 
#' Example Validation Configuration (`inst/config/title_validation.yaml`):
#' \preformatted{
#' validation_config:
#'   validations:
#'     - name: check_missing_order
#'     - name: check_duplicate_order
#'     - name: check_missing_surname
#'     - name: check_missing_firstname
#'     - name: check_duplicate_initials
#'     - name: check_missing_corresponding
#'       dependencies:
#'         - '"Corresponding author?" %in% colnames(contributors_table)'
#'     - name: check_missing_email
#'       dependencies:
#'         - '"Corresponding author?" %in% colnames(contributors_table)'
#'         - 'self$results[["check_missing_corresponding"]]$type == "success"'
#'         - '"Email address" %in% colnames(contributors_table)'
#'     - name: check_duplicate_names
#'     - name: check_affiliation
#'     - name: check_affiliation_consistency
#' }
#'
#' **Dependencies**:
#' - Some validation checks only run if other conditions are met.
#' - Example: `check_missing_email` only runs if:
#'   1. `"Corresponding author?"` exists.
#'   2. `check_missing_corresponding` has passed.
#'   3. `"Email address"` is in the dataset.
#'
#' @section Integration:
#' The class runs in the following order:
#' \enumerate{
#'   \item **Column validation** (via `ColumnValidator`).
#'   \item **If columns are valid** → Run content validation (via `Validator`).
#'   \item **If column validation fails** → Stop and return column validation errors.
#' }
#'
#' @section Usage:
#' \preformatted{
#' # Load a validation configuration file
#' config_path <- "inst/config/title_validation.yaml"
#' 
#' # Create a ValidateOutput instance
#' validate_output <- ValidateOutput$new(config_path = config_path)
#' 
#' # Run validation on the contributors table
#' results <- validate_output$run_validations(contributors_table)
#' print(results)
#' }
#'
#' @seealso \code{\link{ColumnValidator}}, \code{\link{Validator}}
#'
#' @export
ValidateOutput <- R6::R6Class(
  classname = "ValidateOutput",
  
  public = list(
    #' @field validator Instance of the `Validator` class for data validation.
    validator = NULL,
    
    #' @field column_validator Instance of the `ColumnValidator` class for column validation.
    column_validator = NULL,
    
    #' @field config Stores the combined YAML validation configuration.
    config = NULL,
    
    #' @description
    #' Initializes the `ValidateOutput` class.
    #' @param config_path Path to the YAML configuration file.
    initialize = function(config_path) {
      if (missing(config_path)) {
        stop("config_path is required")
      }
      
      # Load the combined YAML config
      self$config <- yaml::read_yaml(config_path)
      
      # Initialize ColumnValidator with the column configuration
      self$column_validator <- ColumnValidator$new(config_input = self$config$column_config)
      
      # Initialize Validator
      self$validator <- Validator$new()
      
      # Set up the validator with the validation config
      self$validator$setup_validator(self$config$validation_config)
    },
    
    #' @description
    #' Runs both column and data validation on a contributors table.
    #' @param contributors_table A dataframe containing contributor data.
    #' @return A list of validation results, each containing:
    #' \itemize{
    #'   \item `type`: `"error"`, `"warning"`, or `"success"`.
    #'   \item `message`: A descriptive validation message.
    #' }
    run_validations = function(contributors_table) {
      # Run column validations first
      column_results <- self$column_validator$validate_columns(contributors_table)
      
      # If column validation fails, return only those results
      if (any(purrr::map_chr(column_results, "type") == "error")) {
        return(column_results)
      }
      
      # Run specified general validations
      validation_results <- self$validator$run_validations(contributors_table)
      
      # Combine and return results
      return(c(column_results, validation_results))
    }
  )
)
