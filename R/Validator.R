Validator <- R6::R6Class(
  classname = "Validator",
  
  public = list(
    validations = list(),
    dependencies = list(),
    results = list(),
    specified_validations = NULL, # Store the subset of validations to run
    
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
        check_coi = check_coi
      )
      self$results <- list()
    },
    
    # Add dependency
    add_dependency = function(validation_name, conditions) {
      self$dependencies[[validation_name]] <- conditions
    },
    
    # Filter to a subset of validations
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
    
    # Run validations
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
    
    # Check if a validation should run
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
