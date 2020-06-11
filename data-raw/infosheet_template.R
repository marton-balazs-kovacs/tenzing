library(magrittr)

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

usethis::use_data(infosheet_template, overwrite = TRUE, internal = FALSE)
