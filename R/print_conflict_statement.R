#' Generate human readable report of the conflict of interest statements
#' 
#' The functions generates the conflict of interest statement section of the manuscript.
#' The output is generated from an contributors_table based on the [contributors_table_template()].
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
#' print_conflict_statement(contributors_table = example_contributors_table, initials = FALSE)
#' 
#' @importFrom rlang .data
print_conflict_statement <- function(contributors_table, initials = FALSE) {
  # Validate input ---------------------------
  if (all(is.na(contributors_table[["Conflict of interest"]]))) stop("There are no conflict of interest statements provided for any of the contributors.")
  
  # Restructure dataframe ---------------------------
  if (initials) {
    coi_data <-
      contributors_table %>% 
      dplyr::mutate_at(
        dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = .data$abbrev_name)
    } else {
      coi_data <-
        contributors_table %>% 
        abbreviate_middle_names_df() %>%
        dplyr::mutate(Name = dplyr::if_else(is.na(.data$`Middle name`),
                                            paste(.data$Firstname, .data$Surname),
                                            paste(.data$Firstname, .data$`Middle name`, .data$Surname)))
    }
  
  coi_data <- 
    coi_data %>% 
    dplyr::select(.data$Name, .data[["Conflict of interest"]]) %>% 
    dplyr::filter(!is.na(.data[["Conflict of interest"]]) & .data[["Conflict of interest"]] != "") %>% 
    dplyr::group_by(.data[["Conflict of interest"]]) %>% 
    dplyr::summarise(Names = glue_oxford_collapse(.data$Name),
                     n_names = dplyr::n())
  
  # Format output string ---------------------------
  res <-
    coi_data %>% 
    dplyr::transmute(
      out = glue::glue("{Names} {dplyr::if_else(n_names > 1, 'declare', 'declares')} {`Conflict of interest`}")) %>% 
    dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "; ")) %>% 
    dplyr::mutate(out = stringr::str_c(.data$out, "."))
  
  res %>% 
    dplyr::pull(.data$out)
}
