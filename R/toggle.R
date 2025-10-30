#' @title toggle
#' @description Generates a toggle switch row with a label, a shinyWidgets materialSwitch, and an optional right label, with robust flexbox alignment.
#' @param ns namespacing/shiny ns function
#' @param inputId id of the switch
#' @param left_label Left hand label text
#' @param right_label Optional right hand label text
#' @return A shiny tagList row
#' @export
#' @importFrom shiny div tags
#' @importFrom shinyWidgets materialSwitch

toggle <- function(ns, inputId, left_label, right_label = NULL) {
  shiny::div(
    class = "toggle-item",
    shiny::tags$label(left_label, `for` = ns(inputId), class = "toggle-label"),
    shinyWidgets::materialSwitch(
      inputId = ns(inputId),
      label = NULL,
      inline = TRUE
    ),
    if (!is.null(right_label)) shiny::tags$label(right_label, `for` = ns(inputId), class = "toggle-label-secondary")
  )
}
