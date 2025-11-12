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

#' Format a single row identifier for display
#'
#' Formats a row identifier using surname (or firstname as fallback) and order in publication.
#' Falls back gracefully when data is missing.
#'
#' @param row_data A single-row dataframe containing contributor information.
#' @return A formatted string like "Smith (order 3)", "John (order 3)" (if surname missing), "Smith", "(order 3)", or "row X".
#' @export
format_row_identifier <- function(row_data) {
  # Extract surname, firstname, and order
  surname <- if ("Surname" %in% colnames(row_data)) {
    surname_val <- row_data$Surname[1]
    if (!is.na(surname_val) && trimws(as.character(surname_val)) != "") {
      as.character(surname_val)
    } else {
      NULL
    }
  } else {
    NULL
  }
  
  firstname <- if ("Firstname" %in% colnames(row_data)) {
    firstname_val <- row_data$Firstname[1]
    if (!is.na(firstname_val) && trimws(as.character(firstname_val)) != "") {
      as.character(firstname_val)
    } else {
      NULL
    }
  } else {
    NULL
  }
  
  order <- if ("Order in publication" %in% colnames(row_data)) {
    order_val <- row_data$`Order in publication`[1]
    if (!is.na(order_val)) {
      as.character(order_val)
    } else {
      NULL
    }
  } else {
    NULL
  }
  
  # Format based on what's available
  # Prefer surname, fallback to firstname
  name <- if (!is.null(surname)) {
    surname
  } else if (!is.null(firstname)) {
    firstname
  } else {
    NULL
  }
  
  if (!is.null(name) && !is.null(order)) {
    return(glue::glue("{name} (order {order})"))
  } else if (!is.null(name)) {
    return(name)
  } else if (!is.null(order)) {
    return(glue::glue("(order {order})"))
  } else {
    # Fallback to row number if available in rownames
    row_num <- if (nrow(row_data) > 0 && !is.null(rownames(row_data))) {
      rownames(row_data)[1]
    } else {
      "unknown row"
    }
    return(glue::glue("row {row_num}"))
  }
}

#' Format affected rows for display
#'
#' Takes a filtered dataframe and formats row identifiers for each row,
#' then collapses them with appropriate separators and capping.
#'
#' @param filtered_df A dataframe containing the filtered rows to format.
#' @param max_display Maximum number of rows to display (default: 10).
#' @param collapse_sep Separator for collapsing multiple rows (default: ", ").
#' @param last_sep Separator for the last item (default: " and ").
#' @return Formatted string of affected rows.
#' @export
format_affected_rows <- function(filtered_df, max_display = 10, collapse_sep = ", ", last_sep = " and ") {
  if (is.null(filtered_df) || nrow(filtered_df) == 0) {
    return("")
  }
  
  # Format each row identifier
  formatted <- purrr::map_chr(seq_len(nrow(filtered_df)), function(i) {
    format_row_identifier(filtered_df[i, , drop = FALSE])
  })
  
  # Limit display if too many rows
  if (length(formatted) > max_display) {
    display_rows <- formatted[1:max_display]
    remaining <- length(formatted) - max_display
    formatted_str <- glue::glue_collapse(display_rows, sep = collapse_sep, last = last_sep)
    return(glue::glue("{formatted_str} and {remaining} more"))
  } else {
    return(glue::glue_collapse(formatted, sep = collapse_sep, last = last_sep))
  }
}

#' Create a validation result for missing values
#'
#' @param column_name Name of the column with missing values.
#' @param missing_rows_df A dataframe containing the rows with missing values.
#' @param severity Severity level: "warning" or "error" (default: "warning").
#' @return A standardized validation result for missing values.
#' @export
validation_missing_values <- function(column_name, missing_rows_df, severity = "warning") {
  if (is.null(missing_rows_df) || nrow(missing_rows_df) == 0) {
    return(validation_success(glue::glue("No missing values found in '{column_name}' column.")))
  }
  
  formatted_rows <- format_affected_rows(missing_rows_df)
  message <- glue::glue("The {column_name} is missing for: {formatted_rows}")
  
  # Extract row numbers for affected_rows (backward compatibility)
  row_nums <- if ("rowname" %in% colnames(missing_rows_df)) {
    as.numeric(missing_rows_df$rowname)
  } else {
    seq_len(nrow(missing_rows_df))
  }
  
  if (severity == "error") {
    return(validation_error(message, affected_rows = row_nums))
  } else {
    return(validation_warning(message, affected_rows = row_nums))
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
  
  # Format duplicate groups (duplicate_rows is a list of vectors, so we format as numbers)
  duplicate_groups <- sapply(duplicate_rows, function(group) {
    # For backward compatibility, if it's a vector of numbers, format directly
    if (is.numeric(group) || is.character(group)) {
      if (length(group) > 5) {
        display <- group[1:5]
        remaining <- length(group) - 5
        formatted <- glue::glue_collapse(display, sep = ", ", last = " and ")
        return(glue::glue("{formatted} and {remaining} more"))
      } else {
        return(glue::glue_collapse(group, sep = ", ", last = " and "))
      }
    } else {
      # If it's a dataframe, use format_affected_rows
      format_affected_rows(group, max_display = 5)
    }
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
