test_that("acknowledgees are excluded from title page, funding and conflict outputs", {
  tbl <- make_contributors_table()
  expect_false(grepl("Zzack", print_title_page(tbl, text_format = "raw")))
  expect_false(grepl("AckFunder", print_funding(tbl)))
  expect_false(grepl("ack conflict", print_conflict_statement(tbl)))
})

test_that("tables without Author/Acknowledgee column keep all contributors in every output", {
  tbl <- make_contributors_table()
  tbl[["Author/Acknowledgee"]] <- NULL
  expect_true(grepl("Zzack", print_title_page(tbl, text_format = "raw")))
  expect_true(grepl("AckFunder", print_funding(tbl)))
  expect_true(grepl("ack conflict", print_conflict_statement(tbl)))
  expect_true(grepl("Zzack", print_yaml(tbl)))
  expect_equal(nrow(filter_authors(tbl)), nrow(tbl))
})

test_that("acknowledgees are excluded from the YAML output", {
  expect_false(grepl("Zzack", print_yaml(make_contributors_table())))
})

test_that("XML output excludes acknowledgees unless requested", {
  tbl <- make_contributors_table()
  expect_false(grepl("Zzack", as.character(print_xml(tbl))))
  expect_true(grepl("Zzack", as.character(print_xml(tbl, include_acknowledgees = TRUE))))
})

test_that("print_xml and print_credit_roles treat a table without the column as all authors", {
  tbl <- make_contributors_table()
  tbl[["Author/Acknowledgee"]] <- NULL
  
  xml <- as.character(print_xml(tbl))
  expect_true(grepl("Zzack", xml))
  expect_false(grepl("acknowledgees", xml))
  # the acknowledgee flag has nothing to act on without the column
  expect_equal(as.character(print_xml(tbl, include_acknowledgees = TRUE)), xml)
  
  expect_true(grepl("Zzack", print_credit_roles(tbl, include = "author", text_format = "raw")))
})

test_that("upload-time validation only warns about a missing Author/Acknowledgee column", {
  cfg <- system.file("config", "column_validation.yaml", package = "tenzing", mustWork = TRUE)
  
  tbl <- make_contributors_table()
  with_col <- validate_contributors_table(tbl, cfg)
  expect_equal(with_col$author_acknowledgee$type, "success")
  
  tbl[["Author/Acknowledgee"]] <- NULL
  without_col <- validate_contributors_table(tbl, cfg)
  expect_equal(without_col$author_acknowledgee$type, "warning")
  expect_false(any(vapply(without_col, function(x) x$type, "") == "error"))
})

test_that("output validations do not repeat the missing-column warning or error on old tables", {
  tbl <- make_contributors_table()
  tbl[["Author/Acknowledgee"]] <- NULL
  for (cfg in c("title", "funding", "coi", "yaml", "xml", "credit")) {
    v <- ValidateOutput$new(
      config_path = system.file("config", paste0(cfg, "_validation.yaml"), package = "tenzing", mustWork = TRUE),
      validate_schema = FALSE
    )
    res <- v$run_validations(tbl, context = list(include = "author"))
    types <- vapply(res, function(x) x$type, "")
    expect_false(any(types == "error"), info = cfg)
    messages <- vapply(res, function(x) x$message, "")
    expect_false(any(grepl("Author/Acknowledgee", messages, fixed = TRUE)), info = cfg)
  }
})

test_that("empty rows are still dropped by the reader's cleaning step", {
  tbl <- make_contributors_table()
  blank <- tbl[1, ]
  blank[1, ] <- NA
  cleaned <- clean_contributors_table(dplyr::bind_rows(tbl, blank))
  expect_equal(nrow(cleaned), nrow(tbl))
})

test_that("contributors left out for an unclear Author/Acknowledgee value are reported", {
  tbl <- make_contributors_table()
  
  # all values valid -> nothing to report
  expect_equal(check_excluded_unclear_author_status(tbl)$type, "success")
  
  # blank value on a named row
  blank <- tbl
  blank$`Author/Acknowledgee`[1] <- NA
  res <- check_excluded_unclear_author_status(blank)
  expect_equal(res$type, "warning")
  expect_true(grepl(blank$Surname[1], res$message))
  # ... and that row really is excluded from the author-only outputs
  expect_false(grepl(blank$Surname[1], print_title_page(blank, text_format = "raw")))
  expect_false(blank$Surname[1] %in% filter_authors(blank)$Surname)
  
  # unrecognized value (typo) is reported as well
  typo <- tbl
  typo$`Author/Acknowledgee`[1] <- "Autor"
  expect_equal(check_excluded_unclear_author_status(typo)$type, "warning")
  
  # a fully empty row is not reported (removed on upload anyway)
  empty <- tbl[1, ]
  empty[1, ] <- NA
  expect_equal(check_excluded_unclear_author_status(dplyr::bind_rows(tbl, empty))$type, "success")
  
  # old tables without the column are fine
  tbl[["Author/Acknowledgee"]] <- NULL
  expect_equal(check_excluded_unclear_author_status(tbl)$type, "success")
})

test_that("an acknowledgee marked as corresponding author is reported, not silently dropped", {
  tbl <- make_contributors_table()
  ack <- which(tbl$`Author/Acknowledgee` == "Acknowledgment only")
  tbl$`Corresponding author?` <- FALSE
  expect_equal(check_corresponding_non_author(tbl)$type, "success")
  
  tbl$`Corresponding author?`[ack] <- TRUE
  res <- check_corresponding_non_author(tbl)
  expect_equal(res$type, "warning")
  expect_true(all(vapply(tbl$Surname[ack], grepl, logical(1), x = res$message, fixed = TRUE)))
  
  # the XML config runs it on the full table
  v <- ValidateOutput$new(
    config_path = system.file("config", "xml_validation.yaml", package = "tenzing", mustWork = TRUE),
    validate_schema = FALSE
  )
  xml_res <- v$run_validations(tbl, context = list(include = "author"))
  expect_equal(xml_res$check_corresponding_non_author$type, "warning")
  
  # old tables / tables without the corresponding column: nothing to report
  no_col <- tbl
  no_col[["Author/Acknowledgee"]] <- NULL
  expect_equal(check_corresponding_non_author(no_col)$type, "success")
  no_corr <- tbl
  no_corr[["Corresponding author?"]] <- NULL
  expect_equal(check_corresponding_non_author(no_corr)$type, "success")
})

test_that("a blank Author/Acknowledgee value never produces all-NA rows in the author/acknowledgee subsets", {
  tbl <- make_contributors_table()
  blank <- which(tbl$`Author/Acknowledgee` == "Author")[1]
  tbl$`Author/Acknowledgee`[blank] <- NA
  
  authors <- filter_authors(tbl)
  acks <- filter_acknowledgees(tbl)
  expect_false(anyNA(authors$Surname))
  expect_false(anyNA(acks$Surname))
  expect_false(tbl$Surname[blank] %in% c(authors$Surname, acks$Surname))
  
  # the validations of the credit output run on those subsets: no errors, and the
  # excluded row is reported through the separate notice instead
  v <- ValidateOutput$new(
    config_path = system.file("config", "credit_validation.yaml", package = "tenzing", mustWork = TRUE),
    validate_schema = FALSE
  )
  for (sub in list(list(authors, "author"), list(acks, "acknowledgee"))) {
    types <- vapply(v$run_validations(sub[[1]], context = list(include = sub[[2]])), function(x) x$type, "")
    expect_false(any(types == "error"), info = sub[[2]])
  }
  expect_equal(check_excluded_unclear_author_status(tbl)$type, "warning")
  
  # the credit statement itself leaves the row out
  expect_false(grepl(tbl$Surname[blank], print_credit_roles(tbl, include = "author", text_format = "raw")))
})

test_that("filter_acknowledgees treats old tables as having no acknowledgees", {
  tbl <- make_contributors_table()
  tbl[["Author/Acknowledgee"]] <- NULL
  expect_equal(nrow(filter_acknowledgees(tbl)), 0)
  expect_equal(nrow(filter_authors(tbl)), nrow(tbl))
})

test_that("filter_authors can require at least one author", {
  tbl <- make_contributors_table()
  tbl$`Author/Acknowledgee` <- "Acknowledgment only"
  expect_equal(nrow(filter_authors(tbl)), 0)
  expect_error(filter_authors(tbl, require_authors = TRUE), "No authors found")
  expect_equal(nrow(filter_authors(make_contributors_table(), require_authors = TRUE)), 3)
})

test_that("outputs that need an author list stop clearly when no authors remain", {
  tbl <- make_contributors_table()
  tbl$`Author/Acknowledgee` <- "Acknowledgment only"
  expect_error(print_title_page(tbl, text_format = "raw"), "No authors found")
  expect_error(print_yaml(tbl), "No authors found")
  expect_error(print_xml(tbl), "No authors found")
})

test_that("the empty-subset check does not depend on a validation context", {
  tbl <- make_contributors_table()
  tbl$`Author/Acknowledgee` <- "Acknowledgment only"
  empty <- filter_authors(tbl)
  for (cfg in c("title", "funding", "coi", "yaml", "credit")) {
    v <- ValidateOutput$new(
      config_path = system.file("config", paste0(cfg, "_validation.yaml"), package = "tenzing", mustWork = TRUE),
      validate_schema = FALSE
    )
    for (ctx in list(NULL, list(include = "author"))) {
      res <- v$run_validations(empty, context = ctx)
      expect_equal(res$check_nonempty_filtered_subset$type, "error", info = cfg)
    }
  }
})

test_that("author_status_results collects the Author/Acknowledgee notices for a card", {
  tbl <- make_contributors_table()
  tbl$`Corresponding author?` <- FALSE
  data <- shiny::reactiveVal(tbl)
  
  res <- shiny::isolate(author_status_results(data)())
  expect_named(res, "excluded_unclear_author_status")
  
  res <- shiny::isolate(author_status_results(data, corresponding = TRUE)())
  expect_named(res, c("excluded_unclear_author_status", "corresponding_non_author"))
  expect_equal(res$corresponding_non_author$type, "success")
  
  tbl$`Corresponding author?`[tbl$`Author/Acknowledgee` == "Acknowledgment only"][1] <- TRUE
  data(tbl)
  res <- shiny::isolate(author_status_results(data, corresponding = TRUE)())
  expect_equal(res$corresponding_non_author$type, "warning")
})

test_that("print_credit_roles separates authors and acknowledgees by Author/Acknowledgee", {
  tbl <- make_contributors_table()
  authors <- print_credit_roles(tbl, include = "author", text_format = "raw")
  acks <- print_credit_roles(tbl, include = "acknowledgment", text_format = "raw")
  expect_true(grepl("Zzack", acks))
  expect_false(grepl("Zzack", authors))
  
  # blank status: in neither section
  blank <- which(tbl$`Author/Acknowledgee` == "Author")[1]
  tbl$`Author/Acknowledgee`[blank] <- NA
  expect_false(grepl(tbl$Surname[blank], print_credit_roles(tbl, include = "author", text_format = "raw")))
  expect_false(grepl(tbl$Surname[blank], print_credit_roles(tbl, include = "acknowledgment", text_format = "raw")))
  
  # old tables: everyone is an author, nobody is an acknowledgee
  tbl[["Author/Acknowledgee"]] <- NULL
  expect_true(grepl("Zzack", print_credit_roles(tbl, include = "author", text_format = "raw")))
  expect_error(print_credit_roles(tbl, include = "acknowledgment", text_format = "raw"), "No rows remain")
})

test_that("acknowledgees do not change the affiliation numbering of the authors", {
  tbl <- make_contributors_table()
  ack <- tbl$`Author/Acknowledgee` == "Acknowledgment only"
  authors_only <- tbl[!ack, ]
  # an acknowledgee ordered between the authors, whose affiliation would otherwise be numbered early
  tbl$`Order in publication`[tbl$Surname == "Holcombe"] <- 1.5
  ack_first <- tbl[order(!ack), ]
  
  expect_equal(print_title_page(tbl, text_format = "raw"), print_title_page(authors_only, text_format = "raw"))
  expect_equal(print_title_page(ack_first, text_format = "raw"), print_title_page(authors_only, text_format = "raw"))
  
  author_aff_refs <- function(xml) {
    xml2::xml_attr(xml2::xml_find_all(xml, "//contrib[@contrib-type='author']/xref[@ref-type='aff']"), "rid")
  }
  expected <- author_aff_refs(print_xml(authors_only))
  expect_equal(author_aff_refs(print_xml(tbl, include_acknowledgees = TRUE)), expected)
  expect_equal(author_aff_refs(print_xml(ack_first, include_acknowledgees = TRUE)), expected)
})
