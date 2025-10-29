#' JavaScript Handler Wrappers
#' 
#' Wrapper functions for JavaScript invocations via golem::invoke_js().
#' These functions provide a consistent interface and make it easier to
#' maintain JavaScript calls throughout the application.
#'
#' @keywords internal
#' @noRd
#' @importFrom golem invoke_js

#' Disable buttons by selector
#' 
#' @param selector CSS selector for buttons to disable
js_disable_buttons <- function(selector) {
  golem::invoke_js("disable", selector)
}

#' Enable buttons by selector
#' 
#' Note: The underlying JS handler is named "reable" (typo) but this wrapper
#' provides the correct name "enable" for better clarity.
#' 
#' @param selector CSS selector for buttons to enable
js_enable_buttons <- function(selector) {
  golem::invoke_js("reable", selector)  # Keep typo for backward compatibility with JS
}

#' Add tooltip to element
#' 
#' @param selector CSS selector for element
#' @param message Tooltip message
js_add_tooltip <- function(selector, message) {
  golem::invoke_js(
    "add_tooltip",
    list(where = selector, message = message)
  )
}

#' Remove tooltip from element
#' 
#' @param selector CSS selector for element
js_remove_tooltip <- function(selector) {
  golem::invoke_js("remove_tooltip", selector)
}

#' Show error alert
#' 
#' @param error Error message
#' @param warning Warning message (optional, defaults to empty string)
js_error_alert <- function(error, warning = "") {
  golem::invoke_js(
    "error_alert",
    list(error = error, warning = warning)
  )
}

#' Show success alert
#' 
#' @param message Success message (optional, defaults to empty string)
js_success_alert <- function(message = "") {
  golem::invoke_js("success_alert", message)
}

#' Show warning alert
#' 
#' @param message Warning message
js_warning_alert <- function(message) {
  golem::invoke_js("warning_alert", message)
}

#' Show element by ID
#' 
#' @param id Element ID (without #)
js_show_id <- function(id) {
  golem::invoke_js("showid", id)
}

#' Hide element by ID
#' 
#' @param id Element ID (without #)
js_hide_id <- function(id) {
  golem::invoke_js("hideid", id)
}

#' Update validation card styles
#' 
#' @param card_id Card element ID
#' @param header_text_id Header text element ID
#' @param text_color Text color hex code
#' @param border_color Border color hex code
js_update_card_styles <- function(card_id, header_text_id, text_color, border_color) {
  golem::invoke_js(
    "update_card_styles",
    list(
      cardId = card_id,
      headerTextId = header_text_id,
      textColor = text_color,
      borderColor = border_color
    )
  )
}

