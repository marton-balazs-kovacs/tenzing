Validator <- R6::R6Class(
  classname = "Validator",
  
  public = list(
    validations = list(),
    dependencies = list(),
    results = list(),
    
    # Initialize with validation functions
    initialize = function() {
      self$validations <- list(
        check_affiliation_consistency = check_affiliation_consistency,
        check_missing_surname = check_missing_surname,
        check_missing_firstname = check_missing_firstname,
        check_duplicate_names = check_duplicate_names,
        check_duplicate_initials = check_duplicate_initials,
        check_missing_order = check_missing_order,
        check_duplicate_order = check_duplicate_order,
        check_affiliation = check_affiliation,
        check_missing_corresponding = check_missing_corresponding,
        check_missing_email = check_missing_email,
        check_credit = check_credit,
        check_coi = check_coi,
        check_duplicate_initials = check_duplicate_initials
      )
      self$results <- list()
    },
    
    # Add dependency
    add_dependency = function(validation_name, condition) {
      self$dependencies[[validation_name]] <- condition
    },
    
    # Run validations
    run_validations = function(contributors_table) {
      self$results <- list() # Reset results
      
      for (validation_name in names(self$validations)) {
        # Check if this validation should run based on dependencies
        if (!self$should_run(validation_name)) {
          next
        }
        
        # Run the validation and store the result
        result <- self$validations[[validation_name]](contributors_table)
        self$results[[validation_name]] <- result
      }
      
      return(self$results)
    },
    
    # Check if a validation should run
    should_run = function(validation_name) {
      # If no dependencies, always run
      if (is.null(self$dependencies[[validation_name]])) {
        return(TRUE)
      }
      
      # Check all dependency conditions
      conditions <- self$dependencies[[validation_name]]
      for (condition in conditions) {
        # Safeguard: Ensure results exist before checking type
        dependency_name <- sub('.*\\[\\["(.*?)"\\]\\].*', '\\1', condition)
        if (is.null(self$results[[dependency_name]])) {
          return(FALSE) # Skip this validation if dependency result is missing
        }
        
        # Evaluate the condition
        if (!eval(parse(text = condition))) {
          return(FALSE) # Skip if condition fails
        }
      }
      
      return(TRUE) # Run if all conditions pass
    }
  )
)
