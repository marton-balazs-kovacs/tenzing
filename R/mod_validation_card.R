# UI stays the same (you already neutralized inline colors)
mod_validation_card_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::div(
      id = ns("validation_card"),
      class = "card",
      style = "border: 2px solid; border-radius: 8px; width: 100%; margin: 12px 0 1em;",
      shiny::div(
        id = ns("validation_header"),
        class = "card-header collapsible-header",
        `data-target` = ns("validation_section"),
        `data-collapsed` = "true",
        style = "cursor: pointer;",
        shiny::tags$p(
          "Table Validation ",
          shiny::tags$i(class = "fas fa-chevron-down"),
          style = "text-align: left; font-weight: 900; margin: 10px",
          id = ns("header_text")
        )
      ),
      shiny::div(
        id = ns("validation_section"),
        class = "collapsible-content",
        style = "visibility: hidden; height: 0; overflow: hidden; padding-left: 10px; padding-right: 10px;",
        shiny::uiOutput(ns("validation_results"))
      )
    )
  )
}

# Server
mod_validation_card_server <- function(
    id,
    contributors_table,
    validate_output_instance,
    trigger = reactive(NULL),
    context = reactive(NULL)
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ---- Run validations (context-aware) with safety net --------------------
    validation_results <- reactive({
      req(contributors_table())
      ctx <- if (is.function(context)) context() else NULL
      
      # Ensure we always return a list of results with $type/$message
      out <- tryCatch(
        validate_output_instance$run_validations(contributors_table(), context = ctx),
        error = function(e) {
          list(runtime = list(
            type = "error",
            message = paste("Validation runtime error:", conditionMessage(e))
          ))
        }
      )
      
      # Normalize: coerce to list; ensure each entry has character type/message
      if (is.null(out)) out <- list()
      lapply(out, function(x) {
        if (is.null(x) || !is.list(x)) x <- list()
        x$type    <- as.character(x$type %||% "")
        x$message <- as.character(x$message %||% "")
        x
      })
    })
    
    # ---- Errors/warnings only (ignore NA/empty types) -----------------------
    filtered_results <- reactive({
      rs <- validation_results()
      purrr::keep(rs, ~ isTRUE((.x$type %||% "") %in% c("error", "warning")))
    })
    
    # ---- Boolean error flag (never NA) --------------------------------------
    has_errors <- reactive({
      rs <- validation_results()
      types <- purrr::map_chr(rs, ~ (.x$type %||% ""), .null = "")
      # Guarantee TRUE/FALSE (no NA leakage)
      isTRUE(any(types == "error"))
    })
    
    # ---- Severity object (never NA) -----------------------------------------
    severity <- reactive({
      res <- filtered_results()
      types <- purrr::map_chr(res, ~ (.x$type %||% ""), .null = "")
      if (any(types == "error")) {
        list(type = "error", textColor = "#D45F68", borderColor = "#D45F68")
      } else if (any(types == "warning")) {
        list(type = "warning", textColor = "#ecd149", borderColor = "#ecd149")
      } else {
        list(type = "success", textColor = "#7ec4ad", borderColor = "#7ec4ad")
      }
    })
    
    # ---- Apply styles AFTER DOM is ready; don't read reactives inside onFlushed
    apply_styles <- function(current) {
      js_update_card_styles(
        card_id = ns("validation_card"),
        header_text_id = ns("header_text"),
        text_color = current$textColor,
        border_color = current$borderColor
      )
    }
    
    observeEvent(trigger(), {
      s <- severity()  # snapshot reactively here
      session$onFlushed(function() apply_styles(s), once = FALSE)
    }, ignoreInit = FALSE)
    
    observeEvent(severity(), {
      s <- severity()  # snapshot
      session$onFlushed(function() apply_styles(s), once = FALSE)
    }, ignoreInit = FALSE)
    
    # ---- Render messages (no if(NA)) ----------------------------------------
    output$validation_results <- shiny::renderUI({
      res <- filtered_results()
      if (length(res) == 0) {
        shiny::tags$div(
          class = "alert alert-success",
          shiny::tags$strong("Success: "),
          "No errors or warnings found."
        )
      } else {
        shiny::tags$div(lapply(res, function(r) {
          t   <- r$type %||% ""
          cls <- if (identical(t, "error")) "alert-danger"
          else if (identical(t, "warning")) "alert-warning"
          else "alert-info"
          lbl <- if (identical(t, "error")) "Error: "
          else if (identical(t, "warning")) "Warning: "
          else "Note: "
          shiny::tags$div(
            class = paste("alert", cls),
            shiny::tags$strong(lbl),
            r$message
          )
        }))
      }
    })
    
    # Return a TRUE/FALSE reactive (never NA)
    has_errors
  })
}
