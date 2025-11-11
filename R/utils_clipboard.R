#' Send content to the browser clipboard
#'
#' Wraps `session$sendCustomMessage()` to deliver both HTML and plain-text
#' representations for the rich clipboard handler defined in
#' `inst/app/www/clipboard.js`.
#'
#' @param session Shiny session object.
#' @param html Optional HTML string to push to the clipboard. When provided, the
#'   browser attempts to write this as `text/html`.
#' @param text Optional plain-text fallback. If omitted but `html` is supplied,
#'   the helper will derive text by stripping tags on the client.
#' @param status_input Optional Shiny input id that will receive copy status
#'   updates (`success` or `error`) for reactive handling.
#'
#' @return Invisibly returns `NULL`. Called for its side effects.
#' @keywords internal
copy_to_clipboard <- function(session, html = NULL, text = NULL, status_input = NULL) {
  stopifnot(!is.null(session))

  payload <- list(
    html = if (!is.null(html)) html else "",
    text = if (!is.null(text)) text else "",
    statusInputId = if (!is.null(status_input)) status_input else NULL
  )

  session$sendCustomMessage("tenzing-copy", payload)
  invisible(NULL)
}


