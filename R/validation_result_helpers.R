#' Validation Result Helper Functions
#'
#' This module provides standardized helper functions for creating
#' validation results with consistent formatting and structure.

#' Create a standardized validation result
#'
#' This function creates a standardized validation result with consistent
#' structure, formatting, and optional metadata.
#'
#' @param type Character string indicating the validation result type.
#'   Must be one of: "success", "warning", "error".
#' @param message Character string with the validation message.
#' @param details Optional list with additional details about the validation.
#' @param affected_rows Optional vector of row numbers or identifiers affected.
#' @param timestamp Optional POSIXct timestamp (defaults to current time).
#' @return A list with standardized validation result structure.
#' @export
create_validation_result <- function(type, message, details = NULL, affected_rows = NULL, timestamp = NULL) {
  # Validate type
  if (!type %in% c("success", "warning", "error")) {
    stop("type must be one of: 'success', 'warning', 'error'")
  }
  
  # Create base result
  result <- list(
    type = type,
    message = as.character(message),
    timestamp = timestamp %||% Sys.time()
  )
  
  # Add optional details
  if (!is.null(details)) {
    result$details <- details
  }
  
  # Add affected rows if provided
  if (!is.null(affected_rows)) {
    result$affected_rows <- as.vector(affected_rows)
  }
  
  return(result)
}

#' Create a success validation result
#'
#' @param message Character string with the success message.
#' @param details Optional list with additional details.
#' @return A standardized success validation result.
#' @export
validation_success <- function(message, details = NULL) {
  create_validation_result(
    type = "success",
    message = message,
    details = details
  )
}

#' Create a warning validation result
#'
#' @param message Character string with the warning message.
#' @param affected_rows Optional vector of affected row numbers.
#' @param details Optional list with additional details.
#' @return A standardized warning validation result.
#' @export
validation_warning <- function(message, affected_rows = NULL, details = NULL) {
  create_validation_result(
    type = "warning",
    message = message,
    affected_rows = affected_rows,
    details = details
  )
}

#' Create an error validation result
#'
#' @param message Character string with the error message.
#' @param affected_rows Optional vector of affected row numbers.
#' @param details Optional list with additional details.
#' @return A standardized error validation result.
#' @export
validation_error <- function(message, affected_rows = NULL, details = NULL) {
  create_validation_result(
    type = "error",
    message = message,
    affected_rows = affected_rows,
    details = details
  )
}

#' Format affected rows for display
#'
#' @param affected_rows Vector of row numbers or identifiers.
#' @param max_display Maximum number of rows to display (default: 10).
#' @param collapse_sep Separator for collapsing multiple rows (default: ", ").
#' @param last_sep Separator for the last item (default: " and ").
#' @return Formatted string of affected rows.
#' @export
format_affected_rows <- function(affected_rows, max_display = 10, collapse_sep = ", ", last_sep = " and ") {
  if (is.null(affected_rows) || length(affected_rows) == 0) {
    return("")
  }
  
  # Limit display if too many rows
  if (length(affected_rows) > max_display) {
    display_rows <- affected_rows[1:max_display]
    remaining <- length(affected_rows) - max_display
    formatted <- glue::glue_collapse(display_rows, sep = collapse_sep, last = last_sep)
    return(glue::glue("{formatted} and {remaining} more"))
  } else {
    return(glue::glue_collapse(affected_rows, sep = collapse_sep, last = last_sep))
  }
}

#' Create a validation result for missing values
#'
#' @param column_name Name of the column with missing values.
#' @param missing_rows Vector of row numbers with missing values.
#' @param severity Severity level: "warning" or "error" (default: "warning").
#' @return A standardized validation result for missing values.
#' @export
validation_missing_values <- function(column_name, missing_rows, severity = "warning") {
  if (length(missing_rows) == 0) {
    return(validation_success(glue::glue("No missing values found in '{column_name}' column.")))
  }
  
  formatted_rows <- format_affected_rows(missing_rows)
  message <- glue::glue("The {column_name} is missing for row numbers: {formatted_rows}")
  
  if (severity == "error") {
    return(validation_error(message, affected_rows = missing_rows))
  } else {
    return(validation_warning(message, affected_rows = missing_rows))
  }
}

#' Create a validation result for duplicate values
#'
#' @param column_name Name of the column with duplicate values.
#' @param duplicate_rows List of vectors, each containing row numbers for a duplicate group.
#' @param severity Severity level: "warning" or "error" (default: "warning").
#' @return A standardized validation result for duplicate values.
#' @export
validation_duplicate_values <- function(column_name, duplicate_rows, severity = "warning") {
  if (length(duplicate_rows) == 0) {
    return(validation_success(glue::glue("No duplicate values found in '{column_name}' column.")))
  }
  
  # Format duplicate groups
  duplicate_groups <- sapply(duplicate_rows, function(group) {
    format_affected_rows(group, max_display = 5)
  })
  
  if (length(duplicate_groups) == 1) {
    message <- glue::glue("Duplicate values in '{column_name}' column for rows: {duplicate_groups[1]}")
  } else {
    message <- glue::glue("Duplicate values in '{column_name}' column found in {length(duplicate_groups)} groups")
  }
  
  all_affected <- unlist(duplicate_rows)
  
  if (severity == "error") {
    return(validation_error(message, affected_rows = all_affected, details = list(duplicate_groups = duplicate_rows)))
  } else {
    return(validation_warning(message, affected_rows = all_affected, details = list(duplicate_groups = duplicate_rows)))
  }
}

#' Create a validation result for column requirements
#'
#' @param missing_columns Vector of missing column names.
#' @param required_columns Vector of all required column names.
#' @param operator The logical operator used ("AND", "OR", "NOT").
#' @param severity Severity level: "warning" or "error" (default: "error").
#' @return A standardized validation result for column requirements.
#' @export
validation_missing_columns <- function(missing_columns, required_columns, operator, severity = "error") {
  if (length(missing_columns) == 0) {
    return(validation_success("All required columns are present."))
  }
  
  if (operator == "AND") {
    message <- glue::glue("Missing required columns: {glue::glue_collapse(missing_columns, sep = ', ', last = ' and ')}")
  } else if (operator == "OR") {
    message <- glue::glue("None of the required columns are present: {glue::glue_collapse(required_columns, sep = ', ', last = ' and ')}")
  } else if (operator == "NOT") {
    message <- glue::glue("Unexpected columns found: {glue::glue_collapse(missing_columns, sep = ', ', last = ' and ')}")
  } else {
    message <- glue::glue("Column validation failed for operator '{operator}'")
  }
  
  if (severity == "error") {
    return(validation_error(message, details = list(missing_columns = missing_columns, required_columns = required_columns, operator = operator)))
  } else {
    return(validation_warning(message, details = list(missing_columns = missing_columns, required_columns = required_columns, operator = operator)))
  }
}
