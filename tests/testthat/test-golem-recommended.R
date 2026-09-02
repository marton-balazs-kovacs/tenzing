context("golem tests")

library(golem)

test_that("app ui", {
  ui <- app_ui()
  expect_shinytaglist(ui)

  ui_html <- as.character(htmltools::renderTags(ui)$html)
  output_ids <- c(
    "title_page-show_report",
    "credit_roles-show_report",
    "funding_information-show_report",
    "conflict_statement-show_report",
    "show_yaml-show_yaml",
    "xml_report-show_report"
  )
  output_positions <- vapply(
    output_ids,
    function(output_id) regexpr(output_id, ui_html, fixed = TRUE)[1],
    integer(1)
  )

  expect_true(all(output_positions > 0))
  expect_true(all(diff(output_positions) > 0))
})


# test_that("URL input uses load wording", {
#   shiny::testServer(mod_read_spreadsheet_server, {
#     session$setInputs(which_input = "URL")
#     expect_match(output$upload_label, "Load from URL", fixed = TRUE)
#   })
# })

  
test_that("app server", {
  server <- app_server
  expect_is(server, "function")
})

# Configure this test to fit your need
# test_that(
#   "app launches",{
#     skip_on_cran()
#     skip_on_travis()
#     skip_on_appveyor()
#     x <- processx::process$new(
#       "R", 
#       c(
#         "-e", 
#         "setwd('../../'); pkgload::load_all();run_app()"
#       )
#     )
#     Sys.sleep(5)
#     expect_true(x$is_alive())
#     x$kill()
#   }
# )






