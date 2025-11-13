#' Configuration Utilities for Validation
#'
#' This module provides utilities for managing validation configurations,
#' including loading base configurations and merging them with specific configs.

#' Configuration cache environment
#'
#' Internal environment used for caching validation configurations.
#'
#' @keywords internal
.config_cache <- new.env()

#' Load and merge validation configuration
#'
#' This function loads a base configuration and merges it with a specific
#' configuration file, allowing for inheritance and reduced duplication.
#' Includes caching to improve performance.
#'
#' @param config_path Path to the specific configuration file
#' @param base_config_path Path to the base configuration file (optional)
#' @param use_cache Whether to use caching (default: TRUE)
#' @return Merged configuration list
#' @keywords internal
#' @export
load_validation_config <- function(config_path, base_config_path = NULL, use_cache = TRUE) {
  # Create cache key
  cache_key <- paste0(config_path, ":", base_config_path %||% "default")
  
  # Check cache first
  if (use_cache && exists(cache_key, envir = .config_cache)) {
    return(.config_cache[[cache_key]])
  }
  # Load the specific configuration
  config <- yaml::read_yaml(config_path)
  
  # Ensure the config has the required structure
  if (is.null(config$column_config)) {
    stop("Configuration must contain 'column_config' section")
  }
  if (is.null(config$validation_config)) {
    stop("Configuration must contain 'validation_config' section")
  }
  
  # Cache the result
  if (use_cache) {
    .config_cache[[cache_key]] <- config
  }
  
  return(config)
}

#' Clear configuration cache
#'
#' Clears the configuration cache. Useful for testing or when configurations
#' have been updated and you want to reload them.
#'
#' @export
clear_config_cache <- function() {
  rm(list = names(.config_cache), envir = .config_cache)
}

#' Get cache statistics
#'
#' Returns information about the current configuration cache.
#'
#' @return List with cache statistics
#' @export
get_cache_stats <- function() {
  cached_configs <- names(.config_cache)
  list(
    cached_count = length(cached_configs),
    cached_configs = cached_configs
  )
}


#' Validate YAML configuration structure
#'
#' Validates that a YAML configuration has the required structure and fields.
#'
#' @param config Configuration list to validate
#' @return TRUE if valid, FALSE otherwise
#' @export
validate_config_schema <- function(config) {
  # Check if config is a list
  if (!is.list(config)) {
    warning("Configuration must be a list")
    return(FALSE)
  }
  
  # Check for required top-level sections
  required_sections <- c("column_config", "validation_config")
  missing_sections <- setdiff(required_sections, names(config))
  
  if (length(missing_sections) > 0) {
    warning(glue::glue("Missing required sections: {paste(missing_sections, collapse = ', ')}"))
    return(FALSE)
  }
  
  # Validate column_config structure
  if (!validate_column_config_schema(config$column_config)) {
    return(FALSE)
  }
  
  # Validate validation_config structure
  if (!validate_validation_config_schema(config$validation_config)) {
    return(FALSE)
  }
  
  return(TRUE)
}

#' Validate column configuration schema
#'
#' @param column_config Column configuration to validate
#' @return TRUE if valid, FALSE otherwise
#' @keywords internal
#' @export
validate_column_config_schema <- function(column_config) {
  if (!is.list(column_config)) {
    warning("column_config must be a list")
    return(FALSE)
  }
  
  if (!"rules" %in% names(column_config)) {
    warning("column_config must contain 'rules' section")
    return(FALSE)
  }
  
  if (!is.list(column_config$rules)) {
    warning("column_config$rules must be a list")
    return(FALSE)
  }
  
  # Validate each rule
  for (rule_name in names(column_config$rules)) {
    rule <- column_config$rules[[rule_name]]
    
    if (!is.list(rule)) {
      warning(glue::glue("Rule '{rule_name}' must be a list"))
      return(FALSE)
    }
    
    # Check required fields
    required_fields <- c("operator", "columns", "severity")
    missing_fields <- setdiff(required_fields, names(rule))
    
    if (length(missing_fields) > 0) {
      warning(glue::glue("Rule '{rule_name}' missing required fields: {paste(missing_fields, collapse = ', ')}"))
      return(FALSE)
    }
    
    # Validate operator
    if (!rule$operator %in% c("AND", "OR", "NOT")) {
      warning(glue::glue("Rule '{rule_name}' has invalid operator: {rule$operator}. Must be one of: AND, OR, NOT"))
      return(FALSE)
    }
    
    # Validate columns
    if (!is.character(rule$columns) && !is.list(rule$columns)) {
      warning(glue::glue("Rule '{rule_name}' columns must be character vector or list"))
      return(FALSE)
    }
    
    # Validate severity
    if (!rule$severity %in% c("error", "warning")) {
      warning(glue::glue("Rule '{rule_name}' has invalid severity: {rule$severity}. Must be 'error' or 'warning'"))
      return(FALSE)
    }
  }
  
  return(TRUE)
}

#' Validate validation configuration schema
#'
#' @param validation_config Validation configuration to validate
#' @return TRUE if valid, FALSE otherwise
#' @keywords internal
#' @export
validate_validation_config_schema <- function(validation_config) {
  if (!is.list(validation_config)) {
    warning("validation_config must be a list")
    return(FALSE)
  }
  
  if (!"validations" %in% names(validation_config)) {
    warning("validation_config must contain 'validations' section")
    return(FALSE)
  }
  
  if (!is.list(validation_config$validations)) {
    warning("validation_config$validations must be a list")
    return(FALSE)
  }
  
  # Validate each validation
  for (i in seq_along(validation_config$validations)) {
    validation <- validation_config$validations[[i]]
    
    if (!is.list(validation)) {
      warning(glue::glue("Validation {i} must be a list"))
      return(FALSE)
    }
    
    # Check required name field
    if (!"name" %in% names(validation)) {
      warning(glue::glue("Validation {i} missing required 'name' field"))
      return(FALSE)
    }
    
    if (!is.character(validation$name) || length(validation$name) != 1) {
      warning(glue::glue("Validation {i} 'name' must be a single character string"))
      return(FALSE)
    }
    
    # Validate dependencies if present
    if ("dependencies" %in% names(validation)) {
      if (!is.list(validation$dependencies) && !is.character(validation$dependencies)) {
        warning(glue::glue("Validation '{validation$name}' dependencies must be character vector or list"))
        return(FALSE)
      }
    }
  }
  
  return(TRUE)
}

