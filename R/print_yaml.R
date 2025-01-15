#' Generate an YAML document of the contributions
#' 
#' The function generates a YAML document containing the contributors information
#' and contributions according to the CRediT taxonomy. The output is generated
#' from an `contributors_table` validated with the [validate_contributors_table()] function.
#' The `contributors_table` must be based on the [contributors_table_template()].
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param contributors_table validated contributors_table
#' 
#' @return The function returns a YAML document
#' @export
#' @examples 
#' example_contributors_table <-
#' read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_contributors_table(contributors_table = example_contributors_table)
#' print_yaml(contributors_table = example_contributors_table)
#' 
#' @importFrom rlang .data
#' @importFrom stats na.omit
print_yaml <- function(contributors_table) {
  # Combine legacy and numbered affiliation columns ---------------------------
  # Identify all columns matching `Affiliation {n}` format
  # Define valid affiliation columns
  legacy_affiliation_cols <- c("Primary affiliation", "Secondary affiliation")
  numbered_affiliation_cols <- grep("^Affiliation \\d+$", colnames(contributors_table), value = TRUE)
  
  # Combine columns that actually exist in the table
  affiliation_cols <- c(
    intersect(legacy_affiliation_cols, colnames(contributors_table)), # Keep only legacy columns that exist
    numbered_affiliation_cols # Add numbered affiliation columns
  )
  
  # Extract unique affiliations in row-by-row order ---------------------------
  affiliation_data <- contributors_table %>%
    dplyr::select(all_of(affiliation_cols)) %>%
    tidyr::pivot_longer(cols = everything(), values_to = "affiliation") %>%
    dplyr::filter(!is.na(affiliation)) %>%
    dplyr::distinct(affiliation) %>%
    dplyr::pull(affiliation)
    
  # Prepare contributor data with affiliations and roles ----------------------
  contrib_data <- contributors_table %>%
    abbreviate_middle_names_df() %>%
    dplyr::rename(
      order = `Order in publication`,
      email = `Email address`,
      corresponding = `Corresponding author?`
    ) %>%
    dplyr::arrange(order) %>%
    dplyr::mutate(
      name = gsub("NA\\s*", "", paste(Firstname, `Middle name`, Surname)),
      affiliation = purrr::map_chr(
        dplyr::row_number(),
        ~ paste(
          which(affiliation_data %in% na.omit(unlist(contributors_table[., affiliation_cols]))),
          collapse = ","
        )
      )
    ) %>%
    dplyr::select(
      dplyr::pull(credit_taxonomy, `CRediT Taxonomy`),
      name, corresponding, email, affiliation
    ) %>%
    dplyr::filter(name != "") %>%
    dplyr::mutate(name = factor(name, levels = name))
  
  # Generate role assignments
  contrib_data$role <- I(
    purrr::map(
      split(contrib_data, contrib_data$name),
      ~ names(dplyr::select(., dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)))[.x[1, -c(1:4)] == TRUE]
    )
  )
  
  # Create YAML structure
  author_list <- contrib_data %>%
    dplyr::select(name, affiliation, role, corresponding, email) %>%
    split(.$name) %>%
    purrr::map(as.list) %>%
    purrr::map(function(x) {
      x$role <- x$role[[1]]
      if (isTRUE(x$corresponding)) x$address <- "Enter postal address here"
      if (is.na(x$email)) x$email <- NULL
      x
    })
  
  affiliation_list <- purrr::imap(affiliation_data, ~ list(id = .y, institution = .x))
  
  # Assemble final YAML
  yaml <- list(author = author_list, affiliation = affiliation_list)
  yaml::as.yaml(yaml, indent.mapping.sequence = TRUE) %>%
    gsub("\\naffiliation:", "\n\naffiliation:", .)
}
