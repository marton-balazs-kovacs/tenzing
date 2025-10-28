# Module UI
  
#' @title   mod_credit_roles_ui and mod_credit_roles_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname mod_credit_roles
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_credit_roles_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Contributions text",
          class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
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
    # Setup ---------------------------
    ns <- session$ns
    
    # Reactive value to track modal state
    modal_open <- reactiveVal(FALSE)
    
    # Validation ---------------------------
    # Initialize ValidateOutput with the title validation config
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/credit_validation.yaml", package = "tenzing")
    )
    
    # Initialize validation card logic only when modal is open
    # Use mod_validation_card_server to handle validation and get error status
    has_errors <- mod_validation_card_server(
      id = "validation_card",
      contributors_table = input_data,
      validate_output_instance = validate_output_instance,
      trigger = modal_open
    )
    
    observe({
      req(modal_open())
      if (has_errors()) {
        golem::invoke_js("disable", paste0("#", ns("report")))
        golem::invoke_js("hideid", ns("clip"))
        golem::invoke_js("add_tooltip",
                         list(
                           where = paste0("#", ns("report")),
                           message = "Fix the errors to enable the download."))
      } else {
        golem::invoke_js("remove_tooltip", paste0("#", ns("report")))
        golem::invoke_js("reable", paste0("#", ns("report")))
        golem::invoke_js("showid", ns("clip"))
      }
    })
    
    # Preview ---------------------------
    ## Render preview
    # ---- Author preview (HTML) ----
    output$preview_auth <- renderUI({
      req(modal_open())
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
      } else if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        HTML(
          print_credit_roles(
            contributors_table = input_data(),
            text_format = "html",
            initials = isTRUE(input$initials),
            order_by = order(),
            include = "author",
            pub_order = pub_order()
          )
        )
      }
    })
    
    # ---- Acknowledgee preview (HTML), only if present ----
    output$preview_ack <- renderUI({
      req(modal_open(), has_ack())
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
      } else if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        HTML(
          print_credit_roles(
            contributors_table = input_data(),
            text_format = "html",
            initials = isTRUE(input$initials_ack),
            order_by = order_ack(),
            include = "acknowledgment",
            pub_order = pub_order_ack()
          )
        )
      }
    })
    
    ## Build preview modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Author contributions"),
        div(
          class = "toggle-row",
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "initials"), label = "Full names", inline = TRUE),
            span("Initials")
          ),
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "order_by"), label = "Contributor names", inline = TRUE),
            span("Roles")
          ),
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "pub_desc"), label = "Desc", inline = TRUE),
            span("Asc")
          )
        ), 
        hr(style= "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "preview_auth")),
        # ---- Acknowledgee block (conditionally shown) ----
        uiOutput(NS(id, "ack_section")),
        easyClose = FALSE,
        footer = tagList(
          mod_validation_card_ui(ns("validation_card")),
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
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
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Author information'])"
            ),
          actionButton(ns("close_modal"), label = "Close", class = "btn btn-close")
        )
      )
    }
    
    output$ack_section <- renderUI({
      req(modal_open())
      # only show if there are acknowledgees present
      if (!has_ack())
        return(NULL)
      
      tagList(
        hr(),
        h3("Acknowledgee contributions"),
        div(
          class = "toggle-row",
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "initials_ack"), label = "Full names", inline = TRUE),
            span("Initials")
          ),
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "order_by_ack"), label = "Contributor names", inline = TRUE),
            span("Roles")
          ),
          div(
            class = "toggle-item",
            shinyWidgets::materialSwitch(NS(id, "pub_desc_ack"), label = "Desc", inline = TRUE),
            span("Asc")
          )
        ),
        
        hr(style = "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "preview_ack"))
      )
    })
    
    ## Show preview modal
    observeEvent(input$show_report, {
      modal_open(TRUE)  # Mark modal as open
      showModal(modal())
    })
    
    # Handle Close button
    observeEvent(input$close_modal, {
      modal_open(FALSE)  # Mark modal as closed
      removeModal()      # Close modal explicitly
    })

    # contributor vs role (authors)
    order <- reactive({
      ifelse(input$order_by, "contributor", "role")
    })
    
    # pub order (authors)
    pub_order <- reactive({
      if (isTRUE(input$pub_desc)) "desc" else "asc"
    })
    
    # contributor vs role (acknowledgees)
    order_ack <- reactive({
      ifelse(isTRUE(input$order_by_ack), "contributor", "role")
    })
    
    # pub order (acknowledgees)
    pub_order_ack <- reactive({
      if (isTRUE(input$pub_desc_ack)) "desc" else "asc"
    })
    
    
    # any acknowledgees? (excluding "Don't agree to be named")
    has_ack <- reactive({
      req(input_data())
      df <- input_data()
      if (!"Author/Acknowledgee" %in% names(df)) return(FALSE)
      any(
        df$`Author/Acknowledgee` == "Acknowledgment only" &
          df$`Author/Acknowledgee` != "Don't agree to be named",
        na.rm = TRUE
      )
    })
    
    # Download ---------------------------
    ## Set up loading bar
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    ## Restructure dataframe for the human readable output
    to_download <- reactive({
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE) || has_errors()) {
        return("There are no CRediT roles checked for any of the contributors.")
      }
      
      # Build Rmd-formatted string
      parts <- list()
      
      # Authors section (always)
      auth_txt <- print_credit_roles(
        contributors_table = input_data(),
        text_format = "rmd",
        initials = isTRUE(input$initials),
        order_by = order(),
        include = "author",
        pub_order = pub_order()
      )
      parts <- c(parts, paste0("### Author contributions\n\n", auth_txt, "\n\n"))
      
      # Acknowledgees section (conditional)
      if (has_ack()) {
        ack_txt <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "rmd",
          initials = isTRUE(input$initials_ack),
          order_by = order_ack(),
          include = "acknowledgment",
          pub_order = pub_order_ack()
        )
        parts <- c(parts, paste0("### Acknowledgee contributions\n\n", ack_txt, "\n\n"))
      }
      
      paste0(parts, collapse = "\n")
    })
    
    
    ## Set up parameters to pass to Rmd document
    params <- reactive({
      list(human_readable = to_download())
    })
  
    ## Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste0("human_readable_report_", Sys.Date(), ".doc")
      },
      # Set content of the file
      content = function(file) {
        # Start progress bar
        waitress$notify()
        # Copy the report file to a temporary directory before processing it
        file_path <- file.path("inst/app/www/", "human_readable_report.Rmd")
        file.copy("human_readable_report.Rmd", file_path, overwrite = TRUE)
        # Knit the document
        callr::r(
          render_report,
          list(input = file_path, output = file, format = "word_document", params = params())
        )
        # Stop progress bar
        waitress$close()
      }
    )
    
    # Clip ---------------------------
    ## Set up output text to clip
    to_clip <- reactive({
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE) || has_errors()) {
        return("There are no CRediT roles checked for either of the contributors.")
      }
      
      parts <- list()
      
      # Authors (raw)
      auth_raw <- print_credit_roles(
        contributors_table = input_data(),
        text_format = "raw",
        initials = isTRUE(input$initials),
        order_by = order(),
        include = "author",
        pub_order = pub_order()
      )
      parts <- c(parts, paste0("Author contributions: ", auth_raw))
      
      # Acknowledgees (raw, if present)
      if (has_ack()) {
        ack_raw <- print_credit_roles(
          contributors_table = input_data(),
          text_format = "raw",
          initials = isTRUE(input$initials_ack),
          order_by = order_ack(),
          include = "acknowledgment",
          pub_order = pub_order_ack()
        )
        parts <- c(parts, paste0("Acknowledgee contributions: ", ack_raw))
      }
      
      paste(parts, collapse = "\n\n")
    })
    
    ## Add clipboard buttons
    output$clip <- renderUI({
      rclipboard::rclipButton(
        inputId = "clip_btn", 
        label = "Copy output to clipboard",
        clipText = to_clip(), 
        icon = icon("clipboard"),
        modal = TRUE,
        class = "btn-download")
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(to_clip()))
  })
}
    
## To be copied in the UI
# mod_credit_roles_ui("credit_roles")
    
## To be copied in the server
# mod_credit_roles_server("credit_roles")
 
