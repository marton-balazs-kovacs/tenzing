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
#' @param include Character. Filter which people to include:
#'   - "author" (keep rows where `Author/Acknowledgee` == "Author")
#'   - "acknowledgment" (keep rows where `Author/Acknowledgee` == "Acknowledgment only")
#'   Rows with "Don't agree to be named" are always excluded.
#' @param pub_order Character. "asc" (default) or "desc" for `Order in publication`.
#' 
#' @return The function returns a string containing the CRediT roles
#'   with the contributors listed for each role they partake in.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' print_credit_roles(contributors_table = example_contributors_table)
#' 
#' @importFrom rlang .data
print_credit_roles <-  function(
    contributors_table,
    text_format = "rmd",
    initials = FALSE,
    order_by = "role",
    include = c("author", "acknowledgment"),
    pub_order = c("asc", "desc")
    ) {
  include   <- match.arg(include)
  pub_order <- match.arg(pub_order)
  # get CRediT column names
  role_cols <- dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)
  
  # Map include to the exact values in the column
  include_value <- if (include == "author") "Author" else "Acknowledgment only"
  
  
  # Coerce and filter upfront ---------------------------------------------------
  ct <- contributors_table %>%
    dplyr::mutate(
      # make sure the ordering column is numeric; NA for unparseable
      `Order in publication` = suppressWarnings(as.numeric(.data$`Order in publication`))
    ) %>%
    # always exclude "Don't agree to be named"
    dplyr::filter(.data$`Author/Acknowledgee` != "Don't agree to be named") %>%
    # keep only the requested group
    dplyr::filter(.data$`Author/Acknowledgee` == include_value)
  
  # Validate input ---------------------------
  if (nrow(ct) == 0) {
    stop("No rows remain after filtering by '", include, "' and excluding 'Don't agree to be named'.")
  }
  
  if (all(ct[role_cols] == FALSE, na.rm = TRUE)) {
    stop("There are no CRediT roles checked for either of the contributors.")
  }
  
  # Build names (initials or full) ---------------------------
  if (initials) {
    roles_data <-
      ct %>% 
      dplyr::mutate(dplyr::across(c(.data$Firstname, .data$`Middle name`, .data$Surname), as.character)) %>%
      add_initials() %>% 
      dplyr::rename(Name = .data$abbrev_name) %>% 
      dplyr::select(
        .data$Name,
        .data$`Order in publication`,
        dplyr::all_of(role_cols)
        )
  } else {
    roles_data <-
      ct %>% 
      abbreviate_middle_names_df() %>%
      dplyr::mutate(
        Name = dplyr::if_else(
          is.na(.data$`Middle name`),
          paste(.data$Firstname, .data$Surname),
          paste(.data$Firstname, .data$`Middle name`, .data$Surname)
          )
        ) %>%
      dplyr::select(
        .data$Name,
        .data$`Order in publication`,
        dplyr::all_of(role_cols)
      )
  }
  
  # Restructure dataframe for the credit roles output ---------------------------
  roles_long <-
    roles_data %>% 
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -c(.data$Name, .data$`Order in publication`)) %>% 
    dplyr::filter(.data$Included == TRUE) %>% 
    dplyr::select(-.data$Included)
  
  # Arrange by pub order ---------------------------
  if (pub_order == "asc") {
    roles_long <- roles_long %>%
      dplyr::arrange(
        # NAs last
        is.na(.data$`Order in publication`),
        .data$`Order in publication`
      )
  } else if (pub_order == "desc") {
    roles_long <- roles_long %>%
      dplyr::arrange(is.na(.data$`Order in publication`),
                     dplyr::desc(.data$`Order in publication`))
  } else {
    stop("Unknown pub_order: ", pub_order)
  }
  
  name_levels <- 
    roles_long %>%
    dplyr::distinct(Name) %>%
    dplyr::pull(Name)
  print(roles_long)
  # Compose output ---------------------------
  # Ordered by roles ---------------------------
  if (order_by == "role") {
    # Restructure to fit the chosen order ---------------------------
    roles_grouped <-
      roles_long %>%
      dplyr::group_by(.data$`CRediT Taxonomy`) %>%
      dplyr::summarise(Names = glue_oxford_collapse(.data$Name), .groups = "drop")
    print(roles_grouped)
    # Format output string according to the text_format argument ---------------------------
    if (text_format == 'rmd') {
      res <-
        roles_grouped %>%
        dplyr::transmute(
          out = glue::glue(
            "**{`CRediT Taxonomy`}:** {Names}{dplyr::if_else(initials, '', '.')}"
          )
        ) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        roles_grouped %>%
        dplyr::transmute(
          out = glue::glue(
            "<b>{`CRediT Taxonomy`}:</b> {Names}{dplyr::if_else(initials, '', '.')}"
          )
        ) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "<br>"))
    } else if (text_format == "raw") {
      res <-
        roles_grouped %>%
        dplyr::transmute(out = glue::glue(
          "{`CRediT Taxonomy`}: {Names}{dplyr::if_else(initials, '', '.')}"
        )) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = " "))
    } else {
      stop("Unknown text_format: ", text_format)
    }
    
    # Ordered by contributors ---------------------------
  } else if (order_by == "contributor") {
    # Restructure to fit the chosen order ---------------------------
    contrib_grouped <-
      roles_long %>%
      dplyr::group_by(.data$Name) %>%
      dplyr::summarise(Roles = glue_oxford_collapse(.data$`CRediT Taxonomy`)) %>%
      dplyr::arrange(factor(Name, levels = name_levels))
    
    print(contrib_grouped)
    # Format output string according to the text_format argument ---------------------------
    if (text_format == 'rmd') {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("**{Name}:** {Roles}.")) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("<b>{Name}:</b> {Roles}.")) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "<br>"))
    } else if (text_format == "raw") {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("{Name}: {Roles}.")) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = " "))
    } else {
      stop("Unknown text_format: ", text_format)
    }
    
  } else {
    stop("Unknown order_by: ", order_by)
  }
  
  res %>% 
    dplyr::pull(.data$out)
}

