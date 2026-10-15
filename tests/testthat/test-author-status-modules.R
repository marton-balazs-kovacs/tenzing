# Module-level tests: what the user sees in the validation card and the preview of
# each output when the Author/Acknowledgee column has acknowledgees, blank values,
# or is missing.

card_id <- "validation_card-validation_results"
notice <- "Not included in this output"

blank_status <- function(tbl, surname = "Kovacs") {
  tbl$`Author/Acknowledgee`[tbl$Surname == surname] <- NA
  tbl
}

open_module <- function(server, tbl, open_input, expr) {
  local_real_moduleServer(parent.frame())
  shiny::testServer(server, args = list(input_data = shiny::reactive(tbl)), {
    # `initials` is a toggle inside the real modal; set it as a user would
    session$setInputs(initials = FALSE)
    do.call(session$setInputs, stats::setNames(list(1), open_input))
    session$flushReact()
    expr(output)
  })
}

# Outputs that list authors only: module, input that opens it, preview output id,
# a string that must only appear for an acknowledgee, and one for a (blank-status) author
author_only_outputs <- list(
  title   = list(server = mod_title_page_server, open = "show_report", preview = "preview",
                 ack_text = "Zzack", author_text = "Kovacs"),
  funding = list(server = mod_funding_information_server, open = "show_report", preview = "preview",
                 ack_text = "AckFunder", author_text = "National Funding Agency"),
  coi     = list(server = mod_conflict_statement_server, open = "show_report", preview = "preview",
                 ack_text = "ack conflict", author_text = "Kovacs"),
  yaml    = list(server = mod_show_yaml_server, open = "show_yaml", preview = "papaja_yaml",
                 ack_text = "Zzack", author_text = "Kovacs")
)

for (name in names(author_only_outputs)) {
  out <- author_only_outputs[[name]]
  
  test_that(paste0("[", name, "] the preview leaves out acknowledgees and the card stays quiet about them"), {
    open_module(out$server, make_contributors_table(), out$open, function(output) {
      expect_false(grepl(out$ack_text, rendered_text(output[[out$preview]]), fixed = TRUE))
      expect_false(grepl(notice, rendered_text(output[[card_id]]), fixed = TRUE))
    })
  })
  
  test_that(paste0("[", name, "] a blank status is excluded from the preview and reported by name"), {
    open_module(out$server, blank_status(make_contributors_table()), out$open, function(output) {
      expect_false(grepl(out$author_text, rendered_text(output[[out$preview]]), fixed = TRUE))
      card <- rendered_text(output[[card_id]])
      expect_true(grepl(notice, card, fixed = TRUE))
      expect_true(grepl("Kovacs", card, fixed = TRUE))
      expect_false(grepl("Error", card, fixed = TRUE))
    })
  })
  
  test_that(paste0("[", name, "] old tables without the column list everyone and report nothing"), {
    tbl <- make_contributors_table()
    tbl[["Author/Acknowledgee"]] <- NULL
    open_module(out$server, tbl, out$open, function(output) {
      expect_true(grepl(out$ack_text, rendered_text(output[[out$preview]]), fixed = TRUE))
      expect_false(grepl(notice, rendered_text(output[[card_id]]), fixed = TRUE))
    })
  })
}

# Funding / declarations that only an acknowledgee has must not count as "provided":
# the output has to say there is nothing to show, not fail
test_that("[funding] funding given only by an acknowledgee counts as no funding", {
  tbl <- make_contributors_table()
  tbl$Funding[tbl$`Author/Acknowledgee` == "Author"] <- NA
  open_module(mod_funding_information_server, tbl, "show_report", function(output) {
    expect_true(grepl("no funding information", rendered_text(output$preview), fixed = TRUE))
  })
})

test_that("[coi] declarations given only by an acknowledgee count as no declarations", {
  tbl <- make_contributors_table()
  tbl$Declares[tbl$`Author/Acknowledgee` == "Author"] <- NA
  open_module(mod_conflict_statement_server, tbl, "show_report", function(output) {
    expect_true(grepl("no conflict of interest statements", rendered_text(output$preview), fixed = TRUE))
  })
})

for (name in c("title", "yaml")) {
  test_that(paste0("[", name, "] an acknowledgee marked as corresponding author is reported"), {
    tbl <- make_contributors_table()
    tbl$`Corresponding author?`[tbl$Surname == "Ackerman"] <- TRUE
    out <- author_only_outputs[[name]]
    open_module(out$server, tbl, out$open, function(output) {
      card <- rendered_text(output[[card_id]])
      expect_true(grepl("not listed as corresponding author", card, fixed = TRUE))
      expect_true(grepl("Ackerman", card, fixed = TRUE))
    })
  })
}

test_that("the validation card appends extra_results to the validator's results", {
  local_real_moduleServer()
  v <- ValidateOutput$new(
    config_path = system.file("config", "funding_validation.yaml", package = "tenzing", mustWork = TRUE),
    validate_schema = FALSE
  )
  extra <- list(note = validation_warning("An extra warning from outside the validator"))
  shiny::testServer(
    mod_validation_card_server,
    args = list(contributors_table = shiny::reactive(make_contributors_table()),
                validate_output_instance = v, extra_results = shiny::reactive(extra)),
    {
      expect_true(grepl("An extra warning", rendered_text(output$validation_results), fixed = TRUE))
      expect_false(session$returned())  # a warning is not an error
    }
  )
})

test_that("credit statement: a blank status is reported on both cards without nonsense errors", {
  tbl <- blank_status(make_contributors_table())
  open_module(mod_credit_roles_server, tbl, "show_report", function(output) {
    for (id in c("validation_card_auth", "validation_card_ack")) {
      card <- rendered_text(output[[paste0(id, "-validation_results")]])
      expect_true(grepl(notice, card, fixed = TRUE), info = id)
      expect_true(grepl("Kovacs", card, fixed = TRUE), info = id)
      # regression: a blank status used to turn into an all-NA row ("row 1")
      expect_false(grepl("missing order", card, fixed = TRUE), info = id)
      expect_false(grepl("Surname is missing", card, fixed = TRUE), info = id)
      expect_false(grepl("Error", card, fixed = TRUE), info = id)
    }
  })
})

test_that("credit statement: valid statuses give clean cards", {
  open_module(mod_credit_roles_server, make_contributors_table(), "show_report", function(output) {
    for (id in c("validation_card_auth", "validation_card_ack")) {
      expect_true(grepl("No errors or warnings", rendered_text(output[[paste0(id, "-validation_results")]]), fixed = TRUE), info = id)
    }
  })
})

test_that("XML: the acknowledgee toggle is only offered when the table has the column", {
  shown <- NULL
  local_mocked_bindings(showModal = function(ui, ...) shown <<- ui, .package = "tenzing")
  
  open_module(mod_xml_report_server, make_contributors_table(), "show_report", function(output) NULL)
  expect_true(grepl("include_acknowledgees", as.character(shown), fixed = TRUE))
  
  tbl <- make_contributors_table()
  tbl[["Author/Acknowledgee"]] <- NULL
  open_module(mod_xml_report_server, tbl, "show_report", function(output) NULL)
  expect_false(grepl("include_acknowledgees", as.character(shown), fixed = TRUE))
  expect_true(grepl("include_orcid", as.character(shown), fixed = TRUE))
})

test_that("XML: a blank status is reported by name", {
  open_module(mod_xml_report_server, blank_status(make_contributors_table()), "show_report", function(output) {
    card <- rendered_text(output[[card_id]])
    expect_true(grepl(notice, card, fixed = TRUE))
    expect_true(grepl("Kovacs", card, fixed = TRUE))
  })
})
