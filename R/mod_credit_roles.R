# Module UI
  
#' @title   mod_credit_roles_ui and mod_credit_roles_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
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
          label = "Show contributor contributions text",
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
    output$preview <- renderUI({
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
            initials = input$initials,
            order_by = order()
          )
        )
      }
    })
    
    ## Build preview modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Author contributions"),
        # Toggle between initials and full names
        div(
          style = "display:inline-block; width:100%; padding-bottom:0px; margin-bottom:0px;",
          div(
            style = "display:inline-block; float:left;",
            shinyWidgets::materialSwitch(
              NS(id, "initials"),
              label = "Full names",
              inline = TRUE),
            span("Initials")
          ),
          div(
            style = "display:inline-block; float:right;",
            shinyWidgets::materialSwitch(
              NS(id, "order_by"),
              label = "Contributor names",
              inline = TRUE),
            span("Roles")
            )
          ),
        hr(style= "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "preview")),
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

    ## Switch for order_by input
    order <- reactive({
      ifelse(input$order_by, "contributor", "role")
    })
    
    # Download ---------------------------
    ## Set up loading bar
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    ## Restructure dataframe for the human readable output
    to_download <- reactive({
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE) | has_errors()) {
        "There are no CRediT roles checked for any of the contributors."
        } else {
          print_credit_roles(contributors_table = input_data(), initials = input$initials, order_by = order())
      }
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
      if (all(input_data()[dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)] == FALSE) | has_errors()) {
        "There are no CRediT roles checked for either of the contributors."
        } else {
          print_credit_roles(contributors_table = input_data(), text_format = "raw", initials = input$initials, order_by = order())
          }
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
 
