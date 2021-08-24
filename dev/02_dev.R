# Building a Prod-Ready, Robust Shiny Application.
# Each step is optional. 

# 2. All along your project
## Add functions
usethis::use_r("initials")
usethis::use_r("print_grant")

## 2.1 Add modules

golem::add_module(name = "read_spreadsheet")
golem::add_module(name = "show_spreadsheet")
golem::add_module(name = "human_readable_report")
golem::add_module(name = "xml_report")
golem::add_module(name = "about_modal")
golem::add_module(name = "contribs_affiliation_page")
golem::add_module(name = "check_modal")
golem::add_module(name = "grant_information")

## 2.2 Add dependencies

usethis::use_package("shiny")
usethis::use_package("DT")
usethis::use_package("dplyr")
usethis::use_package("xml2")
usethis::use_package("readr")
usethis::use_package("tidyr")
usethis::use_package("stringr")
usethis::use_package("shinyWidgets")
usethis::use_package("purrr")
usethis::use_package("tibble")
usethis::use_package("waiter")
usethis::use_package("vroom")
usethis::use_package("readxl")
usethis::use_package("magrittr")
usethis::use_package("yaml")
usethis::use_package("rclipboard")
usethis::use_package("markdown")
usethis::use_package("lifecycle")
usethis::use_package("rlang")
usethis::use_package("stats")
usethis::use_package("covr", "Suggests")
usethis::use_pipe()

## 2.3 Add tests

usethis::use_test("app")

## 2.4 Add a browser button

golem::browser_button()

## 2.5 Add external files

golem::add_js_file("script")
golem::add_js_handler("sweetalert")
golem::add_js_handler("add_tooltip")
golem::add_js_handler("remove_tooltip")
golem::add_css_file("custom")

# 3. Documentation

## 3.1 Vignette
usethis::use_vignette("app_use")
usethis::use_vignette("local_use")
devtools::build_vignettes()

## 3.2 Code coverage
## You'll need GitHub there
usethis::use_github()
# usethis::use_travis()
# usethis::use_appveyor()

## News
pkgdown::build_news()

# You're now set! 
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
