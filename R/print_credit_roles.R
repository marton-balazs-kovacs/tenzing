#' Generate report of the contributions with CRedit
#' 
#' The function generates rmarkdown formatted text of the contributions according
#' to the CRediT taxonomy. The output is generated from an `contributors_table` validated with
#' the [validate_contributors_table()] function. The `contributors_table` must be based on the
#' [contributors_table_template()]. The function can return the output string as
#' rmarkdown or html formatted text or without any formatting.
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param contributors_table Tibble. Validated contributors_table
#' @param text_format Character. Formatting of the returned string. Possible values: "rmd", "html", "raw".
#'   "rmd" by default.
#' @param initials Logical. If true initials will be included instead of full
#'   names in the output
#' @param order_by Character. Whether the contributing authors listed for each role ("role"), or
#'   the roles are listed after the name of each contributor ("contributor").
#' 
#' @return The function returns a string containing the CRediT roles
#'   with the contributors listed for each role they partake in.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_contributors_table(contributors_table = example_contributors_table)
#' print_credit_roles(contributors_table = example_contributors_table)
#' 
#' @importFrom rlang .data
print_credit_roles <-  function(contributors_table, text_format = "rmd", initials = FALSE, order_by = "role") {
  # Validate input ---------------------------
  if (all(contributors_table[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE)) {
    stop("There are no CRediT roles checked for either of the contributors.")
  } 
  
  # Adding initials ---------------------------
  if (initials) {
    roles_data <-
      contributors_table %>% 
      dplyr::mutate_at(
        dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = .data$abbrev_name) %>% 
      dplyr::select(.data$Name,
                    dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`))
  } else {
    roles_data <-
      contributors_table %>% 
      abbreviate_middle_names_df() %>%
      dplyr::mutate(Name = dplyr::if_else(is.na(.data$`Middle name`),
                                          paste(.data$Firstname, .data$Surname),
                                          paste(.data$Firstname, .data$`Middle name`, .data$Surname)))
  }
  
  # Restructure dataframe for the credit roles output ---------------------------
  roles_data <-
    roles_data %>% 
    dplyr::select(.data$Name,
                  dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)) %>% 
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -.data$Name) %>% 
    dplyr::filter(.data$Included == TRUE) %>% 
    dplyr::select(-.data$Included)
  
  # Ordered by roles ---------------------------
  if (order_by == "role") {
  # Restructure to fit the chosen order ---------------------------
  roles_data <- 
    roles_data %>% 
    dplyr::group_by(.data$`CRediT Taxonomy`) %>% 
    dplyr::summarise(Names = glue_oxford_collapse(.data$Name))
  
  # Format output string according to the text_format argument ---------------------------
  if (text_format == 'rmd') {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("**{`CRediT Taxonomy`}:** {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
      dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        roles_data %>% 
        dplyr::transmute(out = glue::glue("<b>{`CRediT Taxonomy`}:</b> {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "<br>"))
      } else if (text_format == "raw") {
        res <-
          roles_data %>% 
          dplyr::transmute(out = glue::glue("{`CRediT Taxonomy`}: {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
          dplyr::summarise(out = glue::glue_collapse(.data$out, sep = " "))
        }
  
  # Ordered by authors ---------------------------
  } else if (order_by == "contributor") {
  # Restructure to fit the chosen order ---------------------------
    roles_data <- 
    roles_data %>% 
    dplyr::group_by(.data$Name) %>% 
    dplyr::summarise(Roles = glue_oxford_collapse(.data$`CRediT Taxonomy`))
  
  # Format output string according to the text_format argument ---------------------------
  if (text_format == 'rmd') {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("**{Name}:** {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "  \n"))
  } else if (text_format == "html") {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("<b>{Name}:</b> {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "<br>"))
  } else if (text_format == "raw") {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("{Name}: {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(.data$out, sep = " "))
  }
  }
  
  res %>% 
    dplyr::pull(.data$out)
}

