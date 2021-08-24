#' Generate human readable report of the funding information
#' 
#' The functions generates the funding information section of the manuscript.
#' The output is generated from an contributors_table validated with
#' the [validate_contributors_table()] function.
#' The contributors_table must be based on the [contributors_table_template()].
#' 
#' @family output functions
#' 
#' @param contributors_table validated contributors_table
#' @param initials Logical. If true initials will be included instead of full
#'   names in the output
#'   
#' @return The function returns a string.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_contributors_table(contributors_table = example_contributors_table)
#' print_funding(contributors_table = example_contributors_table, initials = FALSE)
#' 
#' @importFrom rlang .data
print_funding <- function(contributors_table, initials = FALSE) {
  # Validate input ---------------------------
  if (all(is.na(contributors_table$Funding))) stop("There is no funding information provided for any of the contributors.")
  
  # Restructure dataframe ---------------------------
  if (initials) {
    funding_data <-
      contributors_table %>% 
      dplyr::mutate_at(
        dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = .data$abbrev_name)
    } else {
      funding_data <-
        contributors_table %>% 
        abbreviate_middle_names_df() %>%
        dplyr::mutate(Name = dplyr::if_else(is.na(.data$`Middle name`),
                                            paste(.data$Firstname, .data$Surname),
                                            paste(.data$Firstname, .data$`Middle name`, .data$Surname)))
    }
  
  funding_data <- 
    funding_data %>% 
    dplyr::select(.data$Name, .data$Funding) %>% 
    dplyr::filter(!is.na(.data$Funding) & .data$Funding != "") %>% 
    dplyr::group_by(.data$Funding) %>% 
    dplyr::summarise(Names = glue_oxford_collapse(.data$Name),
                     n_names = dplyr::n())
  
  # Format output string ---------------------------
  res <-
    funding_data %>% 
    dplyr::transmute(
      out = glue::glue("{Names} {dplyr::if_else(n_names > 1, 'were', 'was')} supported by {Funding}")) %>% 
    dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "; ")) %>% 
    dplyr::mutate(out = stringr::str_c(.data$out, "."))
  
  res %>% 
    dplyr::pull(.data$out)
}
