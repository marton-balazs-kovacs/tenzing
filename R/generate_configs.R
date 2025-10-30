#' Generate Validation Configuration Files
#'
#' This script generates validation configuration files from templates,
#' reducing duplication and ensuring consistency across configurations.

#' Generate a validation configuration file
#'
#' @param output_name Name of the output type (e.g., "title", "credit", "yaml")
#' @param column_rules Vector of column rule names to include
#' @param validation_groups Vector of validation group names to include
#' @param output_path Path where to save the generated config file
#' @export
generate_validation_config <- function(output_name, column_rules, validation_groups, output_path) {
  
  # Get common rules and validations
  common_rules <- get_common_rules()
  common_validations <- get_common_validations()
  
  # Build column config
  column_config <- list(rules = list())
  for (rule_name in column_rules) {
    if (rule_name %in% names(common_rules)) {
      column_config$rules[[rule_name]] <- common_rules[[rule_name]]
    }
  }
  
  # Build validation config
  validation_config <- list(validations = list())
  for (group_name in validation_groups) {
    if (group_name %in% names(common_validations)) {
      validation_config$validations <- c(validation_config$validations, common_validations[[group_name]])
    }
  }
  
  # Combine into final config
  final_config <- list(
    column_config = column_config,
    validation_config = validation_config
  )
  
  # Write to file
  yaml::write_yaml(final_config, output_path)
  
  cat("Generated configuration for", output_name, "at", output_path, "\n")
  return(final_config)
}

#' Generate all standard validation configurations
#'
#' @param config_dir Directory where config files should be saved
#' @export
generate_all_configs <- function(config_dir = "inst/config") {
  
  # Define configurations for each output type
  configs <- list(
    title = list(
      column_rules = c("minimal_rule", "affiliation_rule", "title_rule"),
      validation_groups = c("core_validations", "title_validations", "affiliation_validations")
    ),
    credit = list(
      column_rules = c("minimal_rule", "author_acknowledgee_rule", "credit_rule"),
      validation_groups = c("core_validations", "credit_validations", "context_validations")
    ),
    yaml = list(
      column_rules = c("minimal_rule", "affiliation_rule", "title_rule", "credit_rule"),
      validation_groups = c("core_validations", "title_validations", "affiliation_validations", "credit_validations")
    ),
    xml = list(
      column_rules = c("minimal_rule", "affiliation_rule", "title_rule", "credit_rule"),
      validation_groups = c("core_validations", "title_validations", "affiliation_validations", "credit_validations")
    ),
    funding = list(
      column_rules = c("minimal_rule", "funding_rule"),
      validation_groups = c("core_validations")
    ),
    coi = list(
      column_rules = c("minimal_rule", "coi_rule"),
      validation_groups = c("core_validations", "coi_validations")
    )
  )
  
  # Generate each configuration
  for (output_name in names(configs)) {
    output_path <- file.path(config_dir, paste0(output_name, "_validation.yaml"))
    generate_validation_config(
      output_name = output_name,
      column_rules = configs[[output_name]]$column_rules,
      validation_groups = configs[[output_name]]$validation_groups,
      output_path = output_path
    )
  }
  
  cat("Generated all validation configurations in", config_dir, "\n")
}

# Example usage:
# generate_all_configs()
