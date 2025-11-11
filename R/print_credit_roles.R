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
#' @param include_orcid Logical. If `TRUE`, append ORCID information after contributor names
#'   (as badges for HTML/Rmd, or plain text for raw output). Defaults to `FALSE`.
#' @param orcid_style Character. When ORCID inclusion is enabled, choose `"badge"` (default)
#'   to render the ORCID icon with a link, or `"text"` to render the normalized ORCID URL
#'   in parentheses after the name.
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
    pub_order = c("asc", "desc"),
    include_orcid = FALSE,
    orcid_style = c("badge", "text")
    ) {
  include   <- match.arg(include)
  pub_order <- match.arg(pub_order)
  orcid_style <- match.arg(orcid_style)
  # get CRediT column names
  role_cols <- dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)
  
  # Map include to the exact values in the column
  include_value <- if (include == "author") "Author" else "Acknowledgment only"
  
  
  # Coerce and filter upfront ---------------------------------------------------
  has_author_ack <- "Author/Acknowledgee" %in% names(contributors_table)
  if (!"ORCID iD" %in% names(contributors_table)) {
    contributors_table[["ORCID iD"]] <- NA_character_
  }

  ct <- contributors_table %>%
    dplyr::mutate(
      # make sure the ordering column is numeric; NA for unparseable
      `Order in publication` = suppressWarnings(as.numeric(.data$`Order in publication`)),
      orcid_normalized = dplyr::if_else(
        include_orcid & !is.na(.data$`ORCID iD`) & .data$`ORCID iD` != "",
        normalize_orcid_id(.data$`ORCID iD`),
        NA_character_
      )
    )
  format_with_orcid <- function(name, orcid_uri, format, style) {
    mapply(
      function(nm, orcid_id) {
        if (!include_orcid || is.null(orcid_id) || is.na(orcid_id) || orcid_id == "") {
          return(nm)
        }

        if (identical(style, "text")) {
          return(paste0(nm, " (", orcid_id, ")"))
        }

        if (identical(format, "html")) {
          return(paste0(
            nm,
            '<a href="', orcid_id,
            '" target="_blank" rel="noopener noreferrer" title="ORCID profile">',
            '<img src="www/ORCID-iD_icon_unauth_16x16.png" alt="ORCID iD" ',
            'style="margin-left:3px; vertical-align:text-bottom;" /></a>'
          ))
        }

        if (identical(format, "rmd")) {
          return(paste0(
            nm,
            '[![ORCID iD](ORCID-iD_icon_unauth_16x16.png){style="vertical-align:text-bottom; margin-left:3px;"}](', orcid_id, ')'
          ))
        }

        paste0(nm, " (", orcid_id, ")")
      },
      name,
      orcid_uri,
      USE.NAMES = FALSE
    )
  }

  
  if (has_author_ack) {
    ct <- ct %>%
      # always exclude "Don't agree to be named"
      dplyr::filter(.data$`Author/Acknowledgee` != "Don't agree to be named") %>%
      # keep only the requested group
      dplyr::filter(.data$`Author/Acknowledgee` == include_value)
  } else {
    # Backward compatibility: treat all rows as authors when the column is missing
    # If caller explicitly requests acknowledgees, produce empty to trigger validation error
    if (identical(include, "acknowledgment")) {
      ct <- ct[0, , drop = FALSE]
    }
  }
  
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
        .data$orcid_normalized,
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
        .data$orcid_normalized,
        dplyr::all_of(role_cols)
      )
  }

  roles_data <- roles_data %>%
    dplyr::mutate(
      Name_fmt = format_with_orcid(.data$Name, .data$orcid_normalized, text_format, orcid_style)
    )
  
  # Restructure dataframe for the credit roles output ---------------------------
  roles_long <-
    roles_data %>% 
    tidyr::gather(key = "CRediT Taxonomy", value = "Included", -c(.data$Name, .data$`Order in publication`, .data$orcid_normalized, .data$Name_fmt)) %>% 
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

  # Compose output ---------------------------
  # Ordered by roles ---------------------------
  if (order_by == "role") {
    # Restructure to fit the chosen order ---------------------------
    roles_grouped <-
      roles_long %>%
      dplyr::group_by(.data$`CRediT Taxonomy`) %>%
      dplyr::summarise(Names = glue_oxford_collapse(.data$Name_fmt), .groups = "drop")
  
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
      dplyr::group_by(.data$Name, .data$Name_fmt) %>%
      dplyr::summarise(Roles = glue_oxford_collapse(.data$`CRediT Taxonomy`), .groups = "drop") %>%
      dplyr::arrange(factor(Name, levels = name_levels))
    
    # Format output string according to the text_format argument ---------------------------
    if (text_format == 'rmd') {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("**{Name_fmt}:** {Roles}.")) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "  \n"))
    } else if (text_format == "html") {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("<b>{Name_fmt}:</b> {Roles}.")) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = "<br>"))
    } else if (text_format == "raw") {
      res <-
        contrib_grouped %>%
        dplyr::transmute(out = glue::glue("{Name_fmt}: {Roles}.")) %>%
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

