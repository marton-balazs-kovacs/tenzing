#' Generate an XML document of the contributions
#' 
#' The function generates an XML document that contains the contributors' name,
#' affiliation, CRediT roles, funding information, and conflict of interest 
#' statements with a structure outlined in the JATS DTD specifications. 
#' The output is generated from a `contributors_table` based on the 
#' [contributors_table_template()].
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
#' @param full_document Logical. If `TRUE`, generates a complete valid JATS XML 
#'   document with placeholder metadata. If `FALSE` (default), returns only 
#'   the contributor-related XML fragments (`<contrib-group>`, `<aff>`, 
#'   `<funding-group>`, `<author-notes>`) that can be embedded in an existing 
#'   JATS document.
#' 
#' @return If `full_document = FALSE` (default), returns an xml nodeset 
#'   containing the contributor-related fragments. If `full_document = TRUE`, 
#'   returns a complete valid JATS XML document with XML declaration and DOCTYPE.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' print_xml(contributors_table = example_contributors_table)
#' print_xml(contributors_table = example_contributors_table, full_document = TRUE)
#' 
#' @importFrom rlang .data
#' @importFrom stats na.omit
print_xml <- function(contributors_table, full_document = FALSE) {
  # Filter to authors only (exclude "Acknowledgment only" and "Don't agree to be named")
  authors_only <- contributors_table %>%
    dplyr::filter(.data$`Author/Acknowledgee` == "Author")
  
  if (nrow(authors_only) == 0) {
    stop("No authors found in the contributors_table.")
  }
  
  # Extract unique affiliations in row-by-row order
  legacy_affiliation_cols <- c("Primary affiliation", "Secondary affiliation")
  numbered_affiliation_cols <- grep("^Affiliation \\d+$", colnames(contributors_table), value = TRUE)
  affiliation_cols <- c(
    intersect(legacy_affiliation_cols, colnames(contributors_table)),
    numbered_affiliation_cols
  )
  
  affiliation_data <- contributors_table %>%
    dplyr::select(all_of(affiliation_cols)) %>%
    tidyr::pivot_longer(cols = everything(), values_to = "affiliation") %>%
    dplyr::filter(!is.na(affiliation)) %>%
    dplyr::distinct(affiliation) %>%
    dplyr::pull(affiliation)
  
  # Prepare contributor data with affiliations and roles
  contrib_data <- authors_only %>%
      abbreviate_middle_names_df() %>%
    dplyr::mutate(`Given-names` = dplyr::if_else(
      is.na(.data$`Middle name`),
                                                   .data$Firstname,
      paste(.data$Firstname, .data$`Middle name`)
    )) %>%
    dplyr::mutate(
      affiliation_ids = purrr::map_chr(
        dplyr::row_number(),
        ~ paste(
          which(affiliation_data %in% stats::na.omit(unlist(contributors_table[., affiliation_cols]))),
          collapse = ","
        )
      )
    )
  
  # Generate XML fragments
  contrib_group_node <- generate_contrib_group(contrib_data, affiliation_data, authors_only)
  aff_nodes <- generate_affiliations(affiliation_data)
  funding_group_node <- generate_funding_group(authors_only)
  author_notes_node <- generate_author_notes(authors_only)
  
  if (full_document) {
    # Create complete JATS document structure
    doc <- xml2::xml_new_root(.value = "article")
    doc %>% xml2::xml_set_attr("xmlns:xlink", "http://www.w3.org/1999/xlink")
    doc %>% xml2::xml_set_attr("xmlns:mml", "http://www.w3.org/1998/Math/MathML")
    doc %>% xml2::xml_set_attr("xmlns:ali", "http://www.niso.org/schemas/ali/1.0/")
    doc %>% xml2::xml_set_attr("dtd-version", "1.3")
    doc %>% xml2::xml_set_attr("article-type", "research-article")
    
    front <- doc %>% xml2::xml_add_child("front")
    
    # Journal metadata (placeholder)
    journal_meta <- front %>% xml2::xml_add_child("journal-meta")
    journal_id_node <- journal_meta %>% xml2::xml_add_child("journal-id", "tenzing-placeholder")
    journal_id_node %>% xml2::xml_set_attr("journal-id-type", "publisher-id")
    journal_title_group <- journal_meta %>% xml2::xml_add_child("journal-title-group")
    journal_title_group %>% xml2::xml_add_child("journal-title", "Tenzing (placeholder)")
    issn_node <- journal_meta %>% xml2::xml_add_child("issn", "0000-0000")
    issn_node %>% xml2::xml_set_attr("pub-type", "ppub")
    publisher <- journal_meta %>% xml2::xml_add_child("publisher")
    publisher %>% xml2::xml_add_child("publisher-name", "Tenzing")
    
    # Article metadata
    article_meta_wrapper <- front %>% xml2::xml_add_child("article-meta")
    article_id_node <- article_meta_wrapper %>% xml2::xml_add_child("article-id", "tenzing-000000")
    article_id_node %>% xml2::xml_set_attr("pub-id-type", "publisher-id")
    title_group <- article_meta_wrapper %>% xml2::xml_add_child("title-group")
    title_group %>% xml2::xml_add_child("article-title", "Author list only")
    
    # Add contributor-related elements
    # Clone contrib-group by copying all children
    contrib_group_clone <- article_meta_wrapper %>% xml2::xml_add_child("contrib-group")
    for (child in xml2::xml_children(contrib_group_node)) {
      xml2::xml_add_child(contrib_group_clone, child)
    }
    
    for (aff_node in aff_nodes) {
      article_meta_wrapper %>% xml2::xml_add_child(aff_node)
    }
    
    if (!is.null(author_notes_node)) {
      article_meta_wrapper %>% xml2::xml_add_child(author_notes_node)
    }
    
    article_meta_wrapper %>% xml2::xml_add_child("pub-date-not-available")
    
    # Add permissions
    permissions_node <- article_meta_wrapper %>% xml2::xml_add_child("permissions")
    permissions_node %>% xml2::xml_add_child("copyright-statement", "© 2025 The Authors")
    permissions_node %>% xml2::xml_add_child("copyright-year", "2025")
    permissions_node %>% xml2::xml_add_child("copyright-holder", "The Authors")
    license_node <- permissions_node %>% xml2::xml_add_child("license")
    license_node %>% xml2::xml_set_attr("license-type", "open-access")
    license_node %>% xml2::xml_set_attr("xlink:href", "https://creativecommons.org/licenses/by/4.0/")
    # Add ali:license_ref using proper namespace
    # xml2 doesn't handle namespaced elements well, so we construct it as XML and parse
    # Create a temporary wrapper to parse the namespaced element
    wrapper_xml <- paste0('<wrapper xmlns:ali="http://www.niso.org/schemas/ali/1.0/">',
                          '<ali:license_ref>https://creativecommons.org/licenses/by/4.0/</ali:license_ref>',
                          '</wrapper>')
    wrapper_doc <- xml2::read_xml(wrapper_xml)
    license_ref_node <- xml2::xml_children(wrapper_doc)[[1]]
    xml2::xml_add_child(license_node, license_ref_node)
    license_node %>% xml2::xml_add_child("license-p", "This work is licensed under a Creative Commons Attribution 4.0 International License.")
    
    if (!is.null(funding_group_node)) {
      article_meta_wrapper %>% xml2::xml_add_child(funding_group_node)
    }
    
    return(doc)
  } else {
    # Combine fragments into article-meta structure
    article_meta <- xml2::xml_new_root(.value = "article-meta")
    article_meta %>% xml2::xml_add_child(contrib_group_node)
    
    for (aff_node in aff_nodes) {
      article_meta %>% xml2::xml_add_child(aff_node)
    }
    
    if (!is.null(author_notes_node)) {
      article_meta %>% xml2::xml_add_child(author_notes_node)
    }
    
    if (!is.null(funding_group_node)) {
      article_meta %>% xml2::xml_add_child(funding_group_node)
    }
    
    return(article_meta)
  }
}

#' Generate contrib-group XML node
#' 
#' @param contrib_data preprocessed contributors table with affiliations
#' @param affiliation_data vector of unique affiliations
#' @param authors_only full authors table for metadata
#' 
#' @keywords internal
generate_contrib_group <- function(contrib_data, affiliation_data, authors_only) {
  # Prepare CRediT role data
  contrib_with_roles <- contrib_data %>%
    dplyr::select(.data$`Given-names`, .data$Surname, 
                    dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)) %>%
      tidyr::gather(key = "CRediT Taxonomy", value = "Included",
                    -.data$`Given-names`, -.data$Surname) %>%
    dplyr::filter(!is.na(.data$Included) & .data$Included == TRUE) %>%
      dplyr::select(-.data$Included) %>%
      dplyr::group_by(.data$Surname, .data$`Given-names`) %>%
      dplyr::mutate(group_id = dplyr::cur_group_id()) %>%
      dplyr::ungroup() %>%
      dplyr::left_join(., credit_taxonomy, by = "CRediT Taxonomy")
  
  # Create contrib-group root
  contrib_group <- xml2::xml_new_root(.value = "contrib-group")
  
  # Get contributor order and other metadata
  # Use the same affiliation column detection as main function
  legacy_affiliation_cols <- c("Primary affiliation", "Secondary affiliation")
  numbered_affiliation_cols <- grep("^Affiliation \\d+$", colnames(authors_only), value = TRUE)
  affiliation_cols_full <- c(
    intersect(legacy_affiliation_cols, colnames(authors_only)),
    numbered_affiliation_cols
  )
  
  contrib_order <- authors_only %>%
    abbreviate_middle_names_df() %>%
    dplyr::mutate(`Given-names` = dplyr::if_else(
      is.na(.data$`Middle name`),
      .data$Firstname,
      paste(.data$Firstname, .data$`Middle name`)
    )) %>%
    dplyr::mutate(
      affiliation_ids = purrr::map_chr(
        dplyr::row_number(),
        ~ paste(
          which(affiliation_data %in% stats::na.omit(unlist(authors_only[., affiliation_cols_full]))),
          collapse = ","
        )
      ),
      # Add row number to preserve original order for tie-breaking
      original_row = dplyr::row_number()
    ) %>%
    dplyr::select(.data$`Given-names`, .data$Surname, 
                  .data$`Order in publication`, 
                  .data$`Corresponding author?`,
                  .data$`Email address`,
                  .data$`ORCID iD`,
                  .data$affiliation_ids,
                  .data$original_row) %>%
    # Group by name and take first occurrence to avoid duplicates
    dplyr::group_by(.data$`Given-names`, .data$Surname) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()
  
  # Process each unique contributor - order by publication order
  # First get unique contributors with their metadata
  unique_contribs_df <- contrib_with_roles %>%
    dplyr::select(.data$group_id, .data$`Given-names`, .data$Surname) %>%
    dplyr::distinct() %>%
    dplyr::left_join(
      contrib_order %>% 
        dplyr::select(.data$`Given-names`, .data$Surname, .data$`Order in publication`, .data$original_row),
      by = c("Given-names", "Surname")
    ) %>%
    # Order by publication order, then by original row to preserve CSV order for ties
    dplyr::arrange(.data$`Order in publication`, .data$original_row)
  
  for (i in 1:nrow(unique_contribs_df)) {
    row <- unique_contribs_df[i, ]
    group_id <- row$group_id
    given_names <- row$`Given-names`
    surname <- row$Surname
    
    # Filter roles for this specific contributor by name (more reliable than group_id)
    contributor <- dplyr::filter(contrib_with_roles, 
                                 .data$`Given-names` == given_names &
                                 .data$Surname == surname)
    contrib_meta <- dplyr::filter(contrib_order, 
                                  .data$`Given-names` == given_names &
                                  .data$Surname == surname) %>%
      dplyr::slice(1)  # Take first match to avoid duplicates
    
    # surname and given_names already extracted from unique_contribs_df
    
    # Map CRediT terms for proper formatting (en-dash for Writing roles)
    credit_term_map <- function(term) {
      dplyr::case_when(
        term == "Writing - original draft" ~ "Writing – original draft",
        term == "Writing - review & editing" ~ "Writing – review & editing",
        TRUE ~ term
      )
    }
    
    # Create contrib node
    contrib_node <- xml2::xml_new_root(.value = "contrib")
    
    # Add contrib-type attribute (required by JATS)
    contrib_node %>% xml2::xml_set_attr("contrib-type", "author")
    
    # Add corresponding author attribute
    if (nrow(contrib_meta) > 0 && 
        !is.na(contrib_meta$`Corresponding author?`[1]) && 
        isTRUE(contrib_meta$`Corresponding author?`[1])) {
      contrib_node %>% xml2::xml_set_attr("corresp", "yes")
    }
    
    # Add name with nested structure (not attributes)
    name_node <- contrib_node %>% xml2::xml_add_child("name")
    name_node %>% xml2::xml_add_child("surname", surname)
    name_node %>% xml2::xml_add_child("given-names", given_names)
    
    # Add affiliation references
    if (nrow(contrib_meta) > 0 && !is.na(contrib_meta$affiliation_ids) && contrib_meta$affiliation_ids != "") {
      aff_ids <- as.numeric(stringr::str_split(contrib_meta$affiliation_ids, ",")[[1]])
      for (aff_id in aff_ids) {
        xref_node <- contrib_node %>% xml2::xml_add_child("xref")
        xref_node %>% xml2::xml_set_attr("ref-type", "aff")
        xref_node %>% xml2::xml_set_attr("rid", paste0("aff", aff_id))
      }
    }
    
    # Add CRediT roles
    for (i in seq_len(nrow(contributor))) {
      credit_term <- credit_term_map(contributor$`CRediT Taxonomy`[i])
      credit_url <- contributor$url[i]
      # Convert http to https for vocab URLs
      credit_url <- stringr::str_replace(credit_url, "^http://", "https://")
      
      role_node <- contrib_node %>% xml2::xml_add_child("role")
      role_node %>% xml2::xml_set_attr("vocab", "credit")
      role_node %>% xml2::xml_set_attr("vocab-identifier", "https://credit.niso.org/")
      role_node %>% xml2::xml_set_attr("vocab-term", credit_term)
      role_node %>% xml2::xml_set_attr("vocab-term-identifier", credit_url)
    }
    
    # Add email if present
    if (nrow(contrib_meta) > 0 && 
        !is.na(contrib_meta$`Email address`) && 
        contrib_meta$`Email address` != "") {
      contrib_node %>% xml2::xml_add_child("email", contrib_meta$`Email address`)
    }
    
    # Add ORCID if present
    if (nrow(contrib_meta) > 0 && 
        !is.na(contrib_meta$`ORCID iD`) && 
        contrib_meta$`ORCID iD` != "") {
      contrib_id_node <- contrib_node %>% xml2::xml_add_child("contrib-id", contrib_meta$`ORCID iD`)
      contrib_id_node %>% xml2::xml_set_attr("contrib-id-type", "orcid")
    }
    
    # Add to contrib-group
    contrib_group %>% xml2::xml_add_child(contrib_node)
  }
  
  return(contrib_group)
}

#' Generate affiliation XML nodes
#' 
#' @param affiliation_data vector of unique affiliations
#' 
#' @keywords internal
generate_affiliations <- function(affiliation_data) {
  if (length(affiliation_data) == 0) {
    return(list())
  }
  
  aff_nodes <- list()
  for (i in seq_along(affiliation_data)) {
    aff_id <- paste0("aff", i)
    aff_text <- affiliation_data[i]
    
    # Parse affiliation: split by comma
    aff_parts <- stringr::str_split(aff_text, ",")[[1]] %>% 
      stringr::str_trim() %>%
      stringr::str_subset(".+")
    
    aff_node <- xml2::xml_new_root(.value = "aff")
    aff_node %>% xml2::xml_set_attr("id", aff_id)
    aff_node %>% xml2::xml_add_child("label", as.character(i))
    
    if (length(aff_parts) > 0) {
      # Heuristic parsing: assume structure is institution(s), city, state, country
      # Try to identify common patterns
      parts <- aff_parts
      n_parts <- length(parts)
      
      # Simple heuristic: last 1-3 parts are likely location (city, state/province, country)
      # Everything before is institutions
      if (n_parts >= 2) {
        # Try to identify country codes/names (typically last part)
        last_part <- parts[n_parts]
        country_codes <- c("US", "UK", "GB", "CA", "AU", "DE", "FR", "IT", "ES", "NL", "BE", "CH", "AT", "SE", "NO", "DK", "FI", "PL", "CZ", "HU", "RO", "GR", "PT", "IE")
        country_names <- c("United States", "United Kingdom", "Canada", "Australia", "Germany", "France", "Italy", "Spain", "Netherlands", "Belgium", "Switzerland", "Austria", "Sweden", "Norway", "Denmark", "Finland", "Poland", "Czech Republic", "Hungary", "Romania", "Greece", "Portugal", "Ireland")
        
        is_country <- last_part %in% c(country_codes, country_names) || 
                      stringr::str_length(last_part) <= 2 ||
                      last_part %in% c("Hungary", "Hungary", "USA")
        
        if (is_country && n_parts >= 2) {
          # We have at least country
          institutions <- parts[1:(n_parts - 1)]
          
          # Add institutions
          for (inst in institutions) {
            aff_node %>% xml2::xml_add_child("institution", inst)
          }
          
          # Create addr-line with location info
          addr_line <- aff_node %>% xml2::xml_add_child("addr-line")
          
          # Try to identify city (typically second-to-last)
          # and state (third-to-last, if present)
          if (n_parts >= 3) {
            city_part <- parts[n_parts - 1]
            # Check if there's a state (typically third-to-last)
            state_part <- NULL
            if (n_parts >= 4) {
              potential_state <- parts[n_parts - 2]
              # Common US state names/abbreviations
              us_states <- c("Kansas", "California", "New York", "Texas", "Florida", "Alabama", "Alaska", "Arizona", "Arkansas", "Colorado", "Connecticut", "Delaware", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")
              if (potential_state %in% us_states || stringr::str_length(potential_state) == 2) {
                state_part <- potential_state
              }
            }
            
            # Add city
            addr_line %>% xml2::xml_add_child("city", city_part)
            
            # Add state if identified
            if (!is.null(state_part)) {
              addr_line %>% xml2::xml_add_child("state", state_part)
            }
          }
          
          # Add country with proper code if known
          country_code <- NULL
          if (last_part == "US" || last_part == "USA") {
            country_code <- "US"
          } else if (last_part == "UK" || last_part == "United Kingdom") {
            country_code <- "GB"
          } else if (last_part == "Hungary") {
            country_code <- "HU"
          } else if (last_part %in% country_codes) {
            country_code <- last_part
          }
          
          country_node <- addr_line %>% xml2::xml_add_child("country", last_part)
          if (!is.null(country_code)) {
            country_node %>% xml2::xml_set_attr("country", country_code)
          }
        } else {
          # Fallback: treat all as institutions
          for (part in parts) {
            aff_node %>% xml2::xml_add_child("institution", part)
          }
        }
      } else {
        # Only one part - treat as institution
        aff_node %>% xml2::xml_add_child("institution", parts[1])
      }
    } else {
      aff_node %>% xml2::xml_add_child("institution", aff_text)
    }
    
    aff_nodes[[i]] <- aff_node
  }
  
  return(aff_nodes)
}

#' Generate funding-group XML node
#' 
#' @param contributors_table contributors table
#' 
#' @keywords internal
generate_funding_group <- function(contributors_table) {
  if (!"Funding" %in% colnames(contributors_table)) {
    return(NULL)
  }
  
  funding_data <- contributors_table %>%
    dplyr::select(.data$Funding) %>%
    dplyr::filter(!is.na(.data$Funding) & .data$Funding != "") %>%
    dplyr::distinct(.data$Funding) %>%
    dplyr::pull(.data$Funding)
  
  if (length(funding_data) == 0) {
    return(NULL)
  }
  
  funding_group <- xml2::xml_new_root(.value = "funding-group")
  
  for (funding_source in funding_data) {
    award_group <- funding_group %>% xml2::xml_add_child("award-group")
    funding_source_node <- award_group %>% xml2::xml_add_child("funding-source")
    inst_wrap <- funding_source_node %>% xml2::xml_add_child("institution-wrap")
    inst_wrap %>% xml2::xml_add_child("institution", funding_source)
  }
  
  return(funding_group)
}

#' Generate author-notes XML node
#' 
#' @param contributors_table contributors table
#' 
#' @keywords internal
generate_author_notes <- function(contributors_table) {
  has_corresp <- "Email address" %in% colnames(contributors_table) &&
    "Corresponding author?" %in% colnames(contributors_table)
  has_coi <- "Conflict of interest" %in% colnames(contributors_table)
  
  if (!has_corresp && !has_coi) {
    return(NULL)
  }
  
  author_notes <- xml2::xml_new_root(.value = "author-notes")
  
  # Add correspondence information
  if (has_corresp) {
    corresp_authors <- contributors_table %>%
      dplyr::filter(!is.na(.data$`Corresponding author?`) &
                    .data$`Corresponding author?` == TRUE &
                    !is.na(.data$`Email address`) &
                    .data$`Email address` != "") %>%
      abbreviate_middle_names_df() %>%
      dplyr::mutate(Name = dplyr::if_else(
        is.na(.data$`Middle name`),
        paste(.data$Firstname, .data$Surname),
        paste(.data$Firstname, .data$`Middle name`, .data$Surname)
      ))
    
    if (nrow(corresp_authors) > 0) {
      corresp_node <- author_notes %>% xml2::xml_add_child("corresp")
      corresp_node %>% xml2::xml_set_attr("id", "cor1")
      corresp_text <- paste0("Correspondence to: ")
      corresp_node %>% xml2::xml_set_text(corresp_text)
      # Add first corresponding author's email
      corresp_node %>% xml2::xml_add_child("email", corresp_authors$`Email address`[1])
    }
  }
  
  # Add conflict of interest statement
  if (has_coi) {
    coi_data <- contributors_table %>%
      dplyr::filter(!is.na(.data$`Conflict of interest`) &
                    .data$`Conflict of interest` != "") %>%
      abbreviate_middle_names_df() %>%
      dplyr::mutate(Name = dplyr::if_else(
        is.na(.data$`Middle name`),
        paste(.data$Firstname, .data$Surname),
        paste(.data$Firstname, .data$`Middle name`, .data$Surname)
      )) %>%
      dplyr::select(.data$Name, .data$`Conflict of interest`) %>%
      dplyr::distinct()
    
    if (nrow(coi_data) > 0) {
      # Group by COI statement
      coi_grouped <- coi_data %>%
        dplyr::group_by(.data$`Conflict of interest`) %>%
        dplyr::summarise(Names = glue_oxford_collapse(.data$Name), .groups = "drop")
      
      coi_text <- coi_grouped %>%
        dplyr::transmute(
          out = glue::glue("{Names} {dplyr::if_else(dplyr::n() > 1, 'declare', 'declares')} {`Conflict of interest`}.")
        ) %>%
        dplyr::summarise(out = glue::glue_collapse(.data$out, sep = " ")) %>%
        dplyr::pull(.data$out)
      
      fn_node <- author_notes %>% xml2::xml_add_child("fn")
      fn_node %>% xml2::xml_set_attr("fn-type", "coi-statement")
      fn_node %>% xml2::xml_add_child("p", coi_text)
    }
  }
  
  return(author_notes)
}
