# Small, self-contained contributors table for tests (independent of the example
# file shipped in inst/extdata). Three authors followed by two acknowledgees whose
# names, funding and declarations are recognisable in outputs:
#   authors:       Smith (corresponding), Kovacs, Luthor
#   acknowledgees: Holcombe, "Zzack" Ackerman (funding "AckFunder", declares "ack conflict")
make_contributors_table <- function() {
  roles <- dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)
  role_cols <- stats::setNames(rep(list(c(TRUE, TRUE, TRUE, TRUE, TRUE)), length(roles)), roles)
  # one distinct role per person, so every row has a role checked
  for (i in seq_along(roles[1:5])) role_cols[[roles[i]]] <- seq_len(5) == i
  for (r in roles[-(1:5)]) role_cols[[r]] <- rep(FALSE, 5)
  
  dplyr::bind_cols(
    tibble::tibble(
      `Author/Acknowledgee` = c("Author", "Author", "Author", "Acknowledgment only", "Acknowledgment only"),
      `Order in publication` = c(1, 1, 2, 3, 4),
      Firstname = c("John", "Marton", "Lex", "Alex", "Zzack"),
      `Middle name` = c("Mohammad", NA, "W", NA, NA),
      Surname = c("Smith", "Kovacs", "Luthor", "Holcombe", "Ackerman")
    ),
    tibble::as_tibble(role_cols),
    tibble::tibble(
      `Affiliation 1` = c("Institute A", "Institute A", "Company B", "University of Sydney", "Ack Institute"),
      `Affiliation 2` = c("Company B", "Department C", "University D", NA, NA),
      Funding = c("Important Fund", "National Funding Agency", "Important Fund", NA, "AckFunder"),
      `ORCID iD` = c(NA, "https://orcid.org/0000-0002-1825-0097", NA, NA, NA),
      `Email address` = c("some@email.com", NA, NA, NA, NA),
      `Corresponding author?` = c(TRUE, FALSE, FALSE, FALSE, FALSE),
      Declares = c("no competing interest", "no competing interest", "no competing interest",
                   "no competing interest", "ack conflict")
    )
  )
}

# Run module servers in tests with shiny's own `moduleServer`. The package ships an
# old `callModule()`-based wrapper (R/moduleServer.R) that shiny::testServer() cannot
# introspect.
local_real_moduleServer <- function(env = parent.frame()) {
  testthat::local_mocked_bindings(moduleServer = shiny::moduleServer, .package = "tenzing", .env = env)
}

# Plain text of a rendered shiny output (or any tag), for simple expectations
rendered_text <- function(x) {
  html <- if (is.list(x) && !is.null(x$html)) x$html else x
  gsub("[[:space:]]+", " ", gsub("<[^>]+>", " ", as.character(html)))
}
