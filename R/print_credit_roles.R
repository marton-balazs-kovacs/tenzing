#' Generate report of the contributions with CRedit
#' 
#' The function generates rmarkdown formatted text of the contributions according
#' to the CRediT taxonomy. The output is generated from an infosheet validated with
#' the \code{\link{validate_infosheet}} function. The infosheet must be based on the
#' \code{\link{infosheet_template}}. The function can return the output string as
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
#' @param infosheet Tibble. Validated infosheet
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
#' example_infosheet <- read_infosheet(infosheet = system.file("extdata", "infosheet_template_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_infosheet(infosheet = example_infosheet)
#' print_credit_roles(infosheet = example_infosheet)
print_credit_roles <-  function(infosheet, text_format = "rmd", initials = FALSE, order_by = "role") {
  # Validate input ---------------------------
  if (all(infosheet[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
    stop("There are no CRediT roles checked for either of the contributors.")
  } 
  
  # Adding initials ---------------------------
  if (initials) {
    roles_data <-
      infosheet %>% 
      dplyr::mutate_at(
        dplyr::vars(Firstname, `Middle name`, Surname),
        as.character) %>% 
      add_initials() %>% 
      dplyr::rename(Name = abbrev_name) %>% 
      dplyr::select(Name,
                    dplyr::pull(credit_taxonomy, `CRediT Taxonomy`))
  } else {
    roles_data <-
      infosheet %>% 
      abbreviate_middle_names_df() %>%
      dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                                          paste(Firstname, Surname),
                                          paste(Firstname, `Middle name`, Surname)))
  }
  
  # Restructure dataframe for the credit roles output ---------------------------
  roles_data <-
    roles_data %>% 
    dplyr::select(Name,
                  dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>% 
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -Name) %>% 
    dplyr::filter(Included == TRUE) %>% 
    dplyr::select(-Included)
  
  # Ordered by roles ---------------------------
  if (order_by == "role") {
  # Restructure to fit the chosen order ---------------------------
  roles_data <- 
    roles_data %>% 
    dplyr::group_by(`CRediT Taxonomy`) %>% 
    dplyr::summarise(Names = glue_oxford_collapse(Name))
  
  # Format output string according to the text_format argument ---------------------------
  if (text_format == 'rmd') {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("**{`CRediT Taxonomy`}:** {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        roles_data %>% 
        dplyr::transmute(out = glue::glue("<b>{`CRediT Taxonomy`}:</b> {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
        dplyr::summarise(out = glue::glue_collapse(out, sep = "<br>"))
      } else if (text_format == "raw") {
        res <-
          roles_data %>% 
          dplyr::transmute(out = glue::glue("{`CRediT Taxonomy`}: {Names}{dplyr::if_else(initials, '', '.')}")) %>% 
          dplyr::summarise(out = glue::glue_collapse(out, sep = " "))
        }
  
  # Ordered by authors ---------------------------
  } else if (order_by == "contributor") {
  # Restructure to fit the chosen order ---------------------------
    roles_data <- 
    roles_data %>% 
    dplyr::group_by(Name) %>% 
    dplyr::summarise(Roles = glue_oxford_collapse(`CRediT Taxonomy`))
  
  # Format output string according to the text_format argument ---------------------------
  if (text_format == 'rmd') {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("**{Name}:** {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "  \n"))
  } else if (text_format == "html") {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("<b>{Name}:</b> {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = "<br>"))
  } else if (text_format == "raw") {
    res <-
      roles_data %>% 
      dplyr::transmute(out = glue::glue("{Name}: {Roles}.")) %>% 
      dplyr::summarise(out = glue::glue_collapse(out, sep = " "))
  }
  }
  
  res %>% 
    dplyr::pull(out)
}

