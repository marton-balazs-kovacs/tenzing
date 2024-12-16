# Module UI

#' @title   mod_create_table_ui and mod_create_table_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_create_table
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList
mod_create_table_ui <- function(id) {
  tagList(
    p("Duplicate and edit the ",
      style = "display: inline; margin-bottom: 0;"),
    a(
      href = "https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing",
      "contributors table template",
      target = "_blank",
      style = "display: inline; color: #ffdf57; text-decoration: underline;",
      class = "link"
    )
  )
  
}

# Module Server

#' @rdname mod_create_table
#' @export
#' @keywords internal

mod_create_table_server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}

## To be copied in the UI
# mod_create_table_ui("create_table")

## To be copied in the server
# mod_create_table_server("create_table")
