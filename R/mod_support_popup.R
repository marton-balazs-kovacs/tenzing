#' Support popup (server-only; no UI function)
#' Uses insertUI/removeUI + later; styled via CSS (.support-toast)
#'
#' @param id Module id (required by shiny module system)
#' @param enable Logical or reactive logical. If FALSE, popup is never shown. Default is TRUE.
#' @param show_prob Numeric between 0 and 1. Probability that popup will be shown. Default is 0.33.
#' @param delay_ms Integer. Delay in milliseconds before showing popup. Default is 1500.
#' @param dismiss_ms Integer. Delay in milliseconds before auto-dismissing popup. Default is 60000.
#' @param donation_url Character. URL for donation link. Default is "https://opencollective.com/tenzing"
#'
#' @keywords internal
mod_support_popup_server <- function(
    id,
    enable       = TRUE,
    show_prob    = 0.33,
    delay_ms     = 1500,
    dismiss_ms   = 60000,
    donation_url = "https://opencollective.com/tenzing"
) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    is_enabled <- function() {
      if (isTRUE(is.reactive(enable))) isTRUE(enable()) else isTRUE(enable)
    }
    
    guard_key <- "tenzing_support_popup_shown"
    if (is.null(session$userData[[guard_key]])) {
      session$userData[[guard_key]] <- shiny::reactiveVal(FALSE)
    }
    
    if (is.null(session$userData$tenzing_support_popup_coin)) {
      p <- suppressWarnings(as.numeric(show_prob))
      p <- if (is.na(p) || p < 0 || p > 1) 0 else p
      session$userData$tenzing_support_popup_coin <- stats::runif(1) < p
    }
    
    build_message <- function() {
      ask_donation <- (as.integer(format(Sys.Date(), "%j")) %% 2) == 0
      if (ask_donation) {
        glue::glue(
          "Please support tenzing by <br>donating ",
          "<a href='{donation_url}' target='_blank' rel='noopener noreferrer'>here</a>."
        )
      } else {
        "Please cite tenzing (references listed at bottom)"
      }
    }
    
    shiny::observe({
      if (!is_enabled()) return()
      if (isTRUE(session$userData[[guard_key]]())) return()
      if (!isTRUE(session$userData$tenzing_support_popup_coin)) return()
      
      msg <- build_message()
      delay_s   <- max(0, as.integer(delay_ms))   / 1000
      dismiss_s <- max(0, as.integer(dismiss_ms)) / 1000
      toast_id  <- ns("support_toast")
      
      later::later(function() {
        shiny::insertUI(
          selector = "body",
          where    = "beforeEnd",
          immediate = TRUE,
          session  = session,         # <-- important
          ui = shiny::div(
            id = toast_id,
            class = "support-toast",
            shiny::HTML(msg)
          )
        )
        
        if (dismiss_s > 0) {
          later::later(function() {
            shiny::removeUI(
              selector  = paste0("#", toast_id),
              multiple  = FALSE,
              immediate = TRUE,
              session   = session      # <-- important
            )
          }, delay = dismiss_s)
        }
      }, delay = delay_s)
      
      session$userData[[guard_key]](TRUE)
    })
  })
}
