template_url <- "https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing"

infosheet_template <- 
  template_url %>% 
  googlesheets4::read_sheet() %>% 
  tibble::as_tibble() %>% 
  dplyr::slice(1:5)

usethis::use_data(infosheet_template, overwrite = TRUE, internal = FALSE)
