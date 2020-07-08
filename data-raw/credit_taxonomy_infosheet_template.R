# CRediT taxonomy definition

credit_taxonomy <-
  tibble::tibble('CRediT Taxonomy' = c("Conceptualization",
                                       "Data Curation",
                                       "Formal Analysis",
                                       "Funding Acquisition",
                                       "Investigation",
                                       "Methodology",
                                       "Project Administration",
                                       "Resources",
                                       "Software",
                                       "Supervision",
                                       "Validation",
                                       "Visualization",
                                       "Writing - Original Draft Preparation",
                                       "Writing - Review & Editing"),
                 url = c("https://dictionary.casrai.org/Contributor_Roles/Conceptualization",
                         "https://dictionary.casrai.org/Contributor_Roles/Data_curation",
                         "https://dictionary.casrai.org/Contributor_Roles/Formal_analysis",
                         "https://dictionary.casrai.org/Contributor_Roles/Funding_acquisition",
                         "https://dictionary.casrai.org/Contributor_Roles/Investigation",
                         "https://dictionary.casrai.org/Contributor_Roles/Methodology",
                         "https://dictionary.casrai.org/Contributor_Roles/Project_administration",
                         "https://dictionary.casrai.org/Contributor_Roles/Resources",
                         "https://dictionary.casrai.org/Contributor_Roles/Software",
                         "https://dictionary.casrai.org/Contributor_Roles/Supervision",
                         "https://dictionary.casrai.org/Contributor_Roles/Validation",
                         "https://dictionary.casrai.org/Contributor_Roles/Visualization",
                         "https://dictionary.casrai.org/Contributor_Roles/Writing_original_draft",
                         "https://dictionary.casrai.org/Contributor_Roles/Writing_review_editing"))


# Infosheet template

template_url <- "https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing"

safe_gs_url <- purrr::safely(googlesheets::gs_url)

gs_info <- safe_gs_url(template_url, visibility = "public")

infosheet_template <- 
  gs_info$result %>% 
  googlesheets::gs_read() %>% 
  tibble::as_tibble() %>% 
  dplyr::filter_at(
    dplyr::vars(`Primary affiliation`, Firstname, `Middle name`, Surname),
    dplyr::any_vars(!is.na(.))) %>% 
  dplyr::mutate_at(
    dplyr::vars('Middle name', 'Email address', 'Secondary affiliation'),
    as.character)

# Save as interal data

usethis::use_data(
  infosheet_template,
  credit_taxonomy,
  overwrite = TRUE,
  internal = TRUE
)
