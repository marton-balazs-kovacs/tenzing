#' Settings card helper
#'
#' Generates a reusable collapsible card for settings panels.
#'
#' @param ns Shiny namespace function.
#' @param id Unique identifier used for the collapsible content.
#' @param title Header text for the card.
#' @param collapsed Logical indicating whether the card should be collapsed by default.
#' @param ... UI elements to render inside the card content.
#'
#' @noRd
settings_card <- function(ns, id, title = "Settings", collapsed = TRUE, ...) {
  stopifnot(is.function(ns))

  content <- list(...)

  collapsed_flag <- if (isTRUE(collapsed)) "true" else "false"
  icon_class <- if (isTRUE(collapsed)) "fas fa-chevron-down" else "fas fa-chevron-up"
  content_style <- if (isTRUE(collapsed)) {
    "visibility: hidden; height: 0; overflow: hidden; padding-left: 10px; padding-right: 10px;"
  } else {
    "visibility: visible; height: auto; overflow: hidden; padding-left: 10px; padding-right: 10px;"
  }

  shiny::div(
    class = "card settings-card",
    style = "border: 2px solid #7ec4ad; border-radius: 8px; width: 100%; margin-bottom: 1em;",
    shiny::div(
      class = "card-header collapsible-header settings-header",
      `data-target` = ns(id),
      `data-collapsed` = collapsed_flag,
      style = "cursor: pointer;",
      shiny::tags$p(
        title,
        shiny::tags$i(class = icon_class, style = "margin-left: 6px;"),
        class = "settings-header-text",
        style = "text-align: left; font-weight: 900; margin: 10px"
      )
    ),
    shiny::div(
      id = ns(id),
      class = "collapsible-content settings-content",
      style = content_style,
      shiny::div(
        class = "settings-content-inner",
        do.call(shiny::tagList, content)
      )
    )
  )
}

