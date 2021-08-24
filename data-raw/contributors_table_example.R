library(tidyverse)
library(googlesheets4)

template_url <- "https://docs.google.com/spreadsheets/d/1o6jJiX1OeQpFgDAc0jdiqHj5-Z1JzFn3yS-xAhCfjEQ/edit?usp=sharing"

contributors_table_example <- 
  template_url %>% 
  googlesheets4::read_sheet() %>%  
  tibble::as_tibble()

write_csv(contributors_table_example, "inst/extdata/infosheet_template_example.csv")
