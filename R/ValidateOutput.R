ValidateOutput <- R6::R6Class(
  classname = "ValidateOutput",
  
  public = list(
    validator = NULL,
    column_validator = NULL,
    config = NULL,
    
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
