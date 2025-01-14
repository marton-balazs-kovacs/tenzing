ColumnValidator <- R6::R6Class(
  classname = "ColumnValidator",
  
  public = list(
    config = NULL,
    
    initialize = function(config_input) {
      # Expect a pre-parsed YAML list for config_input
      if (!is.list(config_input)) {
        stop("config_input must be a list representing the column validation rules.")
      }
      self$config <- config_input
    },
    
    validate_columns = function(contributors_table) {
      results <- list()
      
      for (rule_name in names(self$config$rules)) {
        rule <- self$config$rules[[rule_name]]
        result <- self$check_rule(contributors_table, rule, rule_name)
        results[[rule_name]] <- result
      }
      
      return(results)
    },
    
    check_rule = function(contributors_table, rule, rule_name) {
      operator <- rule$operator
      columns <- rule$columns
      severity <- rule$severity %||% "warning"  # Default severity to "warning"
      regex <- rule$regex %||% NULL  # Use regex if provided
      
      # Get actual columns if regex is provided
      if (!is.null(regex)) {
        matched_columns <- colnames(contributors_table)[grepl(regex, colnames(contributors_table))]
        columns <- unique(c(columns, matched_columns))
      }
      
      # Apply the operator logic
      missing_columns <- setdiff(columns, colnames(contributors_table))
      present_columns <- intersect(columns, colnames(contributors_table))
      
      if (operator == "AND") {
        if (length(missing_columns) > 0) {
          return(list(
            type = severity,
            message = glue::glue("Rule '{rule_name}': Missing columns: {paste(missing_columns, collapse = ', ')}")
          ))
        }
      } else if (operator == "OR") {
        if (length(present_columns) == 0) {
          return(list(
            type = severity,
            message = glue::glue("Rule '{rule_name}': None of the required columns are present: {paste(columns, collapse = ', ')}")
          ))
        }
      } else if (operator == "NOT") {
        if (length(present_columns) > 0) {
          return(list(
            type = severity,
            message = glue::glue("Rule '{rule_name}': Unexpected columns found: {paste(present_columns, collapse = ', ')}")
          ))
        }
      } else {
        stop(glue::glue("Unknown operator: {operator}"))
      }
      
      # If validation passes
      return(list(
        type = "success",
        message = glue::glue("Rule '{rule_name}': All column requirements satisfied.")
      ))
    }
  )
)
