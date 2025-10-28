#' Validator Class for Contributors Table
#'
#' The `Validator` class runs a set of user-defined validation functions on 
#' a contributors table. It allows for configuring which validations should 
#' be executed, handling dependencies between validations, and storing results.
#'
#' This class is used in conjunction with the `ValidateOutput` class to 
#' apply both column and general table validations.
#'
#' @section Configurable Validations:
#' The class dynamically loads validation functions, allowing users to add 
#' custom checks. By default, the predefined functions in `validate_helpers.R` 
#' are available.
#'
#' @section Dependencies:
#' Some validations depend on the presence of specific columns or successful 
#' execution of other validations. These dependencies are defined in a YAML 
#' config file.
#'
#' @section YAML Configuration:
#' The validator reads a YAML configuration file (e.g., `inst/config/validator_example.yaml`), 
#' which specifies:
#' \itemize{
#'   \item The **validations to run**.
#'   \item Any **dependencies** between them.
#' }
#'
#' Example:
#' \preformatted{
#' validation_config:
#'   validations:
#'     - name: check_missing_corresponding
#'       dependencies:
#'         - '"Corresponding author?" %in% colnames(contributors_table)'
#'     - name: check_missing_email
#'       dependencies:
#'         - '"Corresponding author?" %in% colnames(contributors_table)'
#'         - 'self$results[["check_missing_corresponding"]]$type == "success"'
#'         - '"Email address" %in% colnames(contributors_table)'
#' }
#'
#' @section Usage:
#' \preformatted{
#' # Create a Validator instance
#' validator <- Validator$new()
#' 
#' # Configure which validations should run
#' validator$setup_validator(validation_config)
#' 
#' # Run the validations on a contributors table
#' results <- validator$run_validations(contributors_table)
#' }
#'
#' @seealso \code{\link{ValidateOutput}} which integrates this class for validation.
#' 
#' @export
Validator <- R6::R6Class(
  classname = "Validator",
  
  public = list(
    #' @field validations A list of validation functions dynamically loaded from `validate_helpers.R` or custom functions.
    validations = list(),
    
    #' @field dependencies A list of validation dependencies.
    dependencies = list(),
    
    #' @field results Stores the results of executed validations.
    results = list(),
    
    #' @field specified_validations The subset of validations to execute, defined in the YAML config.
    specified_validations = NULL, # Store the subset of validations to run
    
    #' @description
    #' Initializes the `Validator` class. 
    #' Loads predefined validations from `validate_helpers.R` and allows for adding custom validations.
    initialize = function() {
      self$validations <- list(
        check_missing_surname = check_missing_surname,
        check_missing_corresponding = check_missing_corresponding,
        check_missing_email = check_missing_email,
        check_duplicate_names = check_duplicate_names,
        check_affiliation_consistency = check_affiliation_consistency,
        check_missing_order = check_missing_order,
        check_duplicate_order = check_duplicate_order,
        check_missing_firstname = check_missing_firstname,
        check_duplicate_initials = check_duplicate_initials,
        check_affiliation = check_affiliation,
        check_credit = check_credit,
        check_coi = check_coi,
        check_author_acknowledgee_values = check_author_acknowledgee_values,
        check_corresponding_non_author = check_corresponding_non_author,
        check_missing_author_acknowledgee= check_missing_author_acknowledgee
      )
      self$results <- list()
    },
    
    #' @description
    #' Adds dependencies for a validation.
    #' @param validation_name The name of the validation.
    #' @param conditions A list of conditions that must be met before running the validation.
    add_dependency = function(validation_name, conditions) {
      self$dependencies[[validation_name]] <- conditions
    },
    
    #' @description
    #' Configures the validator with the subset of validations to execute.
    #' @param validation_config A list defining which validations to run and their dependencies.
    setup_validator = function(validation_config) {
      validation_names <- sapply(validation_config$validations, function(x) x$name)
      self$specified_validations <- validation_names
      
      # Add dependencies from config
      for (validation in validation_config$validations) {
        if (!is.null(validation$dependencies)) {
          self$add_dependency(validation$name, validation$dependencies)
        }
      }
    },
    
    #' @description
    #' Runs the specified validations on the provided contributors table.
    #' @param contributors_table A dataframe containing contributor data.
    #' @return A list of validation results.
    run_validations = function(contributors_table) {
      self$results <- list() # Reset results
      
      for (validation_name in self$specified_validations) {
        # Check if this validation should run based on dependencies
        if (!self$should_run(validation_name, contributors_table)) {
          next
        }
        
        # Run the validation and store the result
        result <- self$validations[[validation_name]](contributors_table)
        self$results[[validation_name]] <- result
      }
      
      return(self$results)
    },
    
    #' @description
    #' Determines whether a validation should be executed based on dependencies.
    #' @param validation_name The validation function name.
    #' @param contributors_table The dataframe containing contributor data.
    #' @return TRUE if the validation should run, FALSE otherwise.
    should_run = function(validation_name, contributors_table) {
      # If no dependencies, always run
      if (is.null(self$dependencies[[validation_name]])) {
        return(TRUE)
      }
      
      # Evaluate dependency conditions
      conditions <- self$dependencies[[validation_name]]
      for (condition in conditions) {
        # Ensure contributors_table is available in the environment for evaluation
        if (!eval(parse(text = condition))) {
          return(FALSE)
        }
      }
      
      return(TRUE)
    }
  )
)
