library(tidyverse)
library(googlesheets4)

template_url <- "https://docs.google.com/spreadsheets/d/1ay8pS-ftvfzWTrKCZr6Fa0cTLg3n8KxAOOleZmuE7Hs/edit?usp=sharing"

contributors_table_example <- 
  template_url %>% 
  googlesheets4::read_sheet() %>%  
  tibble::as_tibble() |> 
  tenzing::clean_contributors_table()

write_csv(contributors_table_example, "inst/extdata/contributors_table_example.csv")
