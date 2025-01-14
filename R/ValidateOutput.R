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
      
      # Initialize ColumnValidator and Validator
      self$column_validator <- ColumnValidator$new(config_input = self$config$column_config)
      self$validator <- Validator$new()
      
      # Set up validations
      self$setup_validations()
    },
    
    setup_validations = function() {
      validation_config <- self$config$validation_config
      
      # Filter only the specified validations
      valid_validations <- list()
      for (validation_name in validation_config$validations) {
        if (!validation_name %in% names(self$validator$validations)) {
          stop(glue::glue("Validation function '{validation_name}' not found in Validator."))
        }
        valid_validations[[validation_name]] <- self$validator$validations[[validation_name]]
      }
      self$validator$validations <- valid_validations
      
      # Add dependencies
      for (validation_name in names(validation_config$dependencies)) {
        for (dependency in validation_config$dependencies[[validation_name]]) {
          self$validator$add_dependency(
            validation_name,
            paste0('self$results[["', dependency, '"]]$type == "success"')
          )
        }
      }
    },
    
    run_validations = function(contributors_table) {
      # Run column validations first
      column_results <- self$column_validator$validate_columns(contributors_table)
      
      # Stop further validations if column check fails
      if (any(purrr::map_chr(column_results, "type") == "error")) {
        return(column_results)
      }
      
      # Run the general validations
      validation_results <- self$validator$run_validations(contributors_table)
      
      # Combine and return results
      return(c(column_results, validation_results))
    }
  )
)
