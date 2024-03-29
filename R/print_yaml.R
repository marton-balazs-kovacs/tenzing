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
  # Restructure input data
  affiliation_data <- contributors_table %>% 
    dplyr::select(dplyr::contains("affiliation")) %>% 
    unlist() %>% 
    unique() %>% 
    na.omit()
  
  contrib_data <- contributors_table %>%
    abbreviate_middle_names_df() %>%
    dplyr::rename(
      order = .data$`Order in publication`,
      email = .data$`Email address`,
      corresponding = .data$`Corresponding author?`
    ) %>% 
    dplyr::arrange(.data$order) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      name = gsub("NA\\s*", "", paste(.data$Firstname, .data$`Middle name`, .data$Surname)),
      affiliation = paste(
        which(affiliation_data %in% na.omit(c(.data$`Primary affiliation`, .data$`Secondary affiliation`))),
        collapse = ","
      )
    ) %>%
    dplyr::ungroup() %>% 
    dplyr::select(
      dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`),
      .data$name, .data$corresponding, .data$email, .data$affiliation
      ) %>% 
    dplyr::filter(.data$name != "") %>%
    dplyr::mutate(name = factor(.data$name, levels = .data$name)) # Ensure split retains order
  
  # Create list column of roles
  contrib_data$role <- I(
    list(
      names(
        dplyr::select(contrib_data, -c(.data$name, .data$corresponding, .data$email, .data$affiliation))
      )
    )
  )
  
  contrib_data$role_logical <- I(
    lapply(
      split(
        dplyr::select(contrib_data, -c(.data$name, .data$corresponding, .data$email, .data$role, .data$affiliation)),
        contrib_data$name
      ),
      unlist
    )
  )
  
  contrib_data$role <- Map(`[`, contrib_data$role, contrib_data$role_logical)
  
  # Turn author information into a list (currently ignores affiliation information)
  author <- dplyr::select(
    contrib_data,
    .data$name,
    .data$affiliation,
    .data$role,
    .data$corresponding,
    .data$email)
  yaml <- list(author = as.list(split(author, author$name)))
  yaml$author <- lapply(yaml$author, as.list)
  yaml$author <- lapply(yaml$author, function(x) { x$role <- x$role[[1]]; x })
  yaml <- lapply(yaml, function(x) { names(x) <- NULL; x })
  
  # Fix missing information
  yaml$author <- lapply(
    yaml$author,
    function(x) { 
      if(isTRUE(x$corresponding)) {
        x$address <- "Enter postal address here"
      } else {
        x$corresponding <- NULL
      }
      if(length(x$role) == 0) x$role <- NULL
      if(is.na(x$email)) x$email <- NULL
      
      x[c("name", "affiliation", names(x)[!names(x) %in% c("name", "affiliation")])]
    }
  )
  
  affiliation <- lapply(
    seq_along(affiliation_data),
    function(x) c(id = x, institution = affiliation_data[x])
  )
  
  yaml <- c(yaml, affiliation = list(lapply(affiliation, as.list)))
  yaml <- yaml::as.yaml(yaml, indent.mapping.sequence = TRUE)
  
  gsub("\\naffiliation:", "\n\naffiliation:", yaml)
}
