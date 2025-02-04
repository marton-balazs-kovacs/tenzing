template_url <- "https://docs.google.com/spreadsheets/d/1ay8pS-ftvfzWTrKCZr6Fa0cTLg3n8KxAOOleZmuE7Hs/edit?usp=sharing"

contributors_table_template <- 
  template_url %>% 
  googlesheets4::read_sheet() %>% 
  tibble::as_tibble() %>% 
  dplyr::slice(1:3)

usethis::use_data(contributors_table_template, overwrite = TRUE, internal = FALSE)
