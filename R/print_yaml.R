#' Generate an YAML document of the contributions
#' 
#' The function generates a YAML document containing the contributors information
#' and contributions according to the CRediT taxonomy. The output is generated
#' from an infosheet validated with the \code{\link{validate_infosheet}} function.
#' The infosheet must be based on the \code{\link{infosheet_template}}.
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param infosheet validated infosheet
#' 
#' @return The function returns a YAML document
#' @export
#' @examples 
#' example_infosheet <- read_infosheet(infosheet = system.file("extdata", "infosheet_template_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_infosheet(infosheet = example_infosheet)
#' print_yaml(infosheet = example_infosheet)
print_yaml <- function(infosheet) {
  # Restructure input data
  affiliation_data <- infosheet %>% 
    dplyr::select(dplyr::contains("affiliation")) %>% 
    unlist() %>% 
    unique() %>% 
    na.omit()
  
  contrib_data <- infosheet %>%
    abbreviate_middle_names_df() %>%
    dplyr::rename(
      order = `Order in publication`
      , email = `Email address`
      , corresponding = `Corresponding author?`
    ) %>% 
    dplyr::arrange(order) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      name = gsub("NA\\s*", "", paste(Firstname, `Middle name`, Surname))
      , affiliation = paste(
        which(affiliation_data %in% na.omit(c(`Primary affiliation`, `Secondary affiliation`)))
        , collapse = ","
      )
    ) %>%
    dplyr::ungroup() %>% 
    dplyr::select(dplyr::pull(credit_taxonomy, `CRediT Taxonomy`), name, corresponding, email, affiliation) %>% 
    dplyr::filter(name != "") %>%
    dplyr::mutate(name = factor(name, levels = name)) # Ensure split retains order
  
  # Create list column of roles
  contrib_data$role <- I(
    list(
      names(
        dplyr::select(contrib_data, -c(name, corresponding, email, affiliation))
      )
    )
  )
  
  contrib_data$role_logical <- I(
    lapply(
      split(
        dplyr::select(contrib_data, -c(name, corresponding, email, role, affiliation)),
        contrib_data$name
      ),
      unlist
    )
  )
  
  contrib_data$role <- Map(`[`, contrib_data$role, contrib_data$role_logical)
  
  # Turn author information into a list (currently ignores affiliation information)
  author <- dplyr::select(contrib_data, name, affiliation, role, corresponding, email)
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
