# Module UI
#' @title   mod_credit_roles_ui and mod_credit_roles_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname mod_credit_roles
#' @keywords internal
#' @export
#' @importFrom shiny NS tagList
#' @importFrom tenzing toggle
mod_credit_roles_ui <- function(id){
  tagList(
    div(
      class = "out-btn",
      actionButton(
        NS(id, "show_report"),
        label = "Contributions text",
        class = "btn btn-primary btn-validate"
      )
    ) %>%
      tagAppendAttributes(
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'Author information'])"
      )
  )
}

# Module Server
#' @rdname mod_credit_roles
#' @export
#' @keywords internal
mod_credit_roles_server <- function(id, input_data){
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Modal open flag ----------------------------------------------------------
    modal_open <- reactiveVal(FALSE)
    
    # Validator instance (config has context-aware validations) ----------------
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/credit_validation.yaml", package = "tenzing")
    )
    
    # Toggle reactives (authors) -----------------------------------------------
    order <- reactive({
      ifelse(isTRUE(input$order_by), "contributor", "role")
    })
    pub_order <- reactive({
      if (isTRUE(input$pub_desc)) "desc" else "asc"
    })
    
    # Toggle reactives (acknowledgees) -----------------------------------------
    order_ack <- reactive({
      ifelse(isTRUE(input$order_by_ack), "contributor", "role")
    })
    pub_order_ack <- reactive({
      if (isTRUE(input$pub_desc_ack)) "desc" else "asc"
    })
    
    # Filtered subsets ----------------------------------------------------------
    authors_df <- reactive({
      df <- req(input_data())
      if (!"Author/Acknowledgee" %in% names(df)) return(df)
      df[df$`Author/Acknowledgee` != "Don't agree to be named" &
           df$`Author/Acknowledgee` == "Author", , drop = FALSE]
    })
    
    acks_df <- reactive({
      df <- req(input_data())
      if (!"Author/Acknowledgee" %in% names(df)) return(df[0, , drop = FALSE])
      df[df$`Author/Acknowledgee` != "Don't agree to be named" &
           df$`Author/Acknowledgee` == "Acknowledgment only", , drop = FALSE]
    })
    
    has_ack <- reactive({
      nrow(acks_df()) > 0
    })
    
    # Contexts for YAML dependency conditions ----------------------------------
    # Note: your config uses include values: "author" and "acknowledgee"
    ctx_auth <- reactive({
      list(include = "author")
    })
    ctx_ack <- reactive({
      list(include = "acknowledgee")
    })
    
    # Two independent validation cards -----------------------------------------
    # IMPORTANT: mod_validation_card_server must accept `context` and pass it to
    # ValidateOutput$run_validations(contributors_table, context).
    has_errors_auth <- mod_validation_card_server(
      id = "validation_card_auth",
      contributors_table = authors_df,
      validate_output_instance = validate_output_instance,
      trigger = modal_open,
      context = ctx_auth
    )
    
    has_errors_ack <- mod_validation_card_server(
      id = "validation_card_ack",
      contributors_table = acks_df,
      validate_output_instance = validate_output_instance,
      trigger = modal_open,
      context = ctx_ack
    )
    
    # Global disable for download/clip: disable only if BOTH sections invalid OR no sections
    disable_all <- reactive({
      no_auth <- nrow(authors_df()) == 0 || isTRUE(has_errors_auth())
      no_ack  <- !has_ack() || isTRUE(has_errors_ack())
      no_auth && no_ack
    })
    
    observe({
      req(modal_open())
      if (disable_all()) {
        golem::invoke_js("disable", paste0("#", ns("report")))
        golem::invoke_js("hideid", ns("clip"))
        golem::invoke_js("add_tooltip",
                         list(
                           where = paste0("#", ns("report")),
                           message = "Fix the validation errors to enable the download."
                         )
        )
      } else {
        golem::invoke_js("remove_tooltip", paste0("#", ns("report")))
        golem::invoke_js("reable", paste0("#", ns("report")))
        golem::invoke_js("showid", ns("clip"))
      }
    })
    
    # Previews ------------------------------------------------------------------
    output$preview_auth <- renderUI({
      req(modal_open())
      if (isTRUE(has_errors_auth())) {
        "The author section cannot be generated. See 'Table Validation' (Authors) for details."
      } else {
        HTML(
          print_credit_roles(
            contributors_table = input_data(),
            text_format = "html",
            initials = isTRUE(input$initials),
            order_by = order(),
            include = "author",
            pub_order = pub_order(),
            include_orcid = isTRUE(input$include_orcid),
            orcid_style = if (isTRUE(input$orcid_style_text)) "text" else "badge"
          )
        )
      }
    })
    
    output$preview_ack <- renderUI({
      req(modal_open(), has_ack())
      if (isTRUE(has_errors_ack())) {
        "The acknowledgee section cannot be generated. See 'Table Validation' (Acknowledgees) for details."
      } else {
        HTML(
          print_credit_roles(
            contributors_table = input_data(),
            text_format = "html",
            initials = isTRUE(input$initials_ack),
            order_by = order_ack(),
            include = "acknowledgment",  # print fn expects 'acknowledgment'
            pub_order = pub_order_ack(),
            include_orcid = isTRUE(input$include_orcid_ack),
            orcid_style = if (isTRUE(input$orcid_style_text_ack)) "text" else "badge"
          )
        )
      }
    })
    
    # Modal ---------------------------------------------------------------------
    modal <- function() {
      modalDialog(
        size = "l",
        # -------- Authors block --------
        h3("Author contributions"),
        div(
          class = "toggle-row",
          toggle(ns, "initials", "Full names", "Initials"),
          toggle(ns, "order_by", "Roles", "Contributor names"),
          toggle(ns, "pub_desc", "Desc", "Asc"),
          toggle(ns, "include_orcid", "Include ORCID", value = TRUE),
          toggle(ns, "orcid_style_text", "Badge", "Text")
        ),
        hr(style = "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "preview_auth")),
        # Authors validation card
        mod_validation_card_ui(ns("validation_card_auth")),
        # -------- Acknowledgees block (conditional) --------
        uiOutput(NS(id, "ack_section")),
        easyClose = FALSE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ) %>%
            tagAppendAttributes(
              onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'Author information'])"
            ),
          div(
            style = "display: inline-block",
            downloadButton(
              NS(id, "report"),
              label = "Download file",
              class = "btn-download"
            )
          ) %>%
            tagAppendAttributes(
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Author information'])"
            ),
          actionButton(ns("close_modal"), label = "Close", class = "btn btn-close")
        )
      )
    }
    
    output$ack_section <- renderUI({
      req(modal_open())
      if (!has_ack()) return(NULL)
      tagList(
        hr(),
        h3("Acknowledgee contributions"),
        div(
          class = "toggle-row",
          toggle(ns, "initials_ack", "Full names", "Initials"),
          toggle(ns, "order_by_ack", "Roles", "Contributor names"),
          toggle(ns, "pub_desc_ack", "Desc", "Asc"),
          toggle(ns, "include_orcid_ack", "Include ORCID badges"),
          toggle(ns, "orcid_style_text_ack", "Badge", "Text")
        ),
        hr(style = "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "preview_ack")),
        # Acknowledgees validation card
        mod_validation_card_ui(ns("validation_card_ack"))
      )
    })
    
    # Show/close modal ----------------------------------------------------------
    observeEvent(input$show_report, {
      modal_open(TRUE)
      showModal(modal())
    })
    observeEvent(input$close_modal, {
      modal_open(FALSE)
      removeModal()
    })
    
    # Download / Clipboard ------------------------------------------------------
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    to_download <- reactive({
      parts <- list()
      
      if (!isTRUE(has_errors_auth()) && nrow(authors_df()) > 0) {
        auth_txt <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "rmd",
          initials = isTRUE(input$initials),
          order_by = order(),
          include = "author",
          pub_order = pub_order(),
          include_orcid = isTRUE(input$include_orcid),
          orcid_style = if (isTRUE(input$orcid_style_text)) "text" else "badge"
        )
        parts <- c(parts, paste0("### Author contributions\n\n", auth_txt, "\n\n"))
      }
      
      if (has_ack() && !isTRUE(has_errors_ack()) && nrow(acks_df()) > 0) {
        ack_txt <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "rmd",
          initials = isTRUE(input$initials_ack),
          order_by = order_ack(),
          include = "acknowledgment",
          pub_order = pub_order_ack(),
          include_orcid = isTRUE(input$include_orcid_ack),
          orcid_style = if (isTRUE(input$orcid_style_text_ack)) "text" else "badge"
        )
        parts <- c(parts, paste0("### Acknowledgee contributions\n\n", ack_txt, "\n\n"))
      }
      
      if (length(parts) == 0)
        return("There are no sections that can be generated due to validation errors. See 'Table Validation'.")
      
      paste0(parts, collapse = "\n")
    })
    
    params <- reactive({
      list(human_readable = to_download())
    })
    
    output$report <- downloadHandler(
      filename = function() {
        paste0("human_readable_report_", Sys.Date(), ".doc")
      },
      content = function(file) {
        waitress$notify()
        file_path <- file.path("inst/app/www/", "human_readable_report.Rmd")
        file.copy("human_readable_report.Rmd", file_path, overwrite = TRUE)
        callr::r(
          render_report,
          list(input = file_path, output = file, format = "word_document", params = params())
        )
        waitress$close()
      }
    )
    
    to_clip <- reactive({
      parts <- list()
      
      if (!isTRUE(has_errors_auth()) && nrow(authors_df()) > 0) {
        auth_raw <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "raw",
          initials = isTRUE(input$initials),
          order_by = order(),
          include = "author",
          pub_order = pub_order(),
          include_orcid = isTRUE(input$include_orcid),
          orcid_style = if (isTRUE(input$orcid_style_text)) "text" else "badge"
        )
        parts <- c(parts, paste0("Author contributions: ", auth_raw))
      }
      
      if (has_ack() && !isTRUE(has_errors_ack()) && nrow(acks_df()) > 0) {
        ack_raw <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "raw",
          initials = isTRUE(input$initials_ack),
          order_by = order_ack(),
          include = "acknowledgment",
          pub_order = pub_order_ack(),
          include_orcid = isTRUE(input$include_orcid_ack),
          orcid_style = if (isTRUE(input$orcid_style_text_ack)) "text" else "badge"
        )
        parts <- c(parts, paste0("Acknowledgee contributions: ", ack_raw))
      }
      
      if (length(parts) == 0)
        return("No valid sections to copy due to validation errors. See 'Table Validation'.")
      
      paste(parts, collapse = "\n\n")
    })
    
    clipboard_payload <- reactive({
      req(modal_open())
      
      text_value <- to_clip()
      
      html_parts <- list()
      if (!isTRUE(has_errors_auth()) && nrow(authors_df()) > 0) {
        html_parts <- c(
          html_parts,
          paste0(
            "<h3>Author contributions</h3>",
            print_credit_roles(
              contributors_table = input_data(),
              text_format = "html",
              initials = isTRUE(input$initials),
              order_by = order(),
              include = "author",
              pub_order = pub_order(),
              include_orcid = isTRUE(input$include_orcid),
              orcid_style = if (isTRUE(input$orcid_style_text)) "text" else "badge"
            )
          )
        )
      }
      
      if (has_ack() && !isTRUE(has_errors_ack()) && nrow(acks_df()) > 0) {
        html_parts <- c(
          html_parts,
          paste0(
            "<h3>Acknowledgee contributions</h3>",
            print_credit_roles(
              contributors_table = input_data(),
              text_format = "html",
              initials = isTRUE(input$initials_ack),
              order_by = order_ack(),
              include = "acknowledgment",
              pub_order = pub_order_ack(),
              include_orcid = isTRUE(input$include_orcid_ack),
              orcid_style = if (isTRUE(input$orcid_style_text_ack)) "text" else "badge"
            )
          )
        )
      }
      
      html_value <- if (length(html_parts) > 0) {
        paste(html_parts, collapse = "<br><br>")
      } else {
        paste0("<p>", htmltools::htmlEscape(text_value), "</p>")
      }
      
      list(
        html = html_value,
        text = text_value
      )
    })
    
    output$clip <- renderUI({
      actionButton(
        inputId = ns("clip_btn"),
        label = "Copy output to clipboard",
        icon = icon("clipboard"),
        class = "btn-download"
      )
    })
    
    observeEvent(input$clip_btn, {
      req(modal_open())
      if (disable_all()) {
        return(NULL)
      }
      
      payload <- clipboard_payload()
      copy_to_clipboard(
        session = session,
        html = payload$html,
        text = payload$text,
        status_input = ns("clipboard_status")
      )
    })
  })
}
