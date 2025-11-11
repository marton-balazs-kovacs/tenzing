#' conflict_statement UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_conflict_statement_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Conflict of interest statement",
          class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'Conflict information'])"
        )
  )
}
    
#' conflict_statement Server Function
#'
#' @noRd 
mod_conflict_statement_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # Setup ---------------------------
    ns <- session$ns
    
    # Reactive value to track modal state
    modal_open <- reactiveVal(FALSE)
    
    # Validation ---------------------------
    # Initialize ValidateOutput with the title validation config
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/coi_validation.yaml", package = "tenzing")
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
      if (all(is.na(input_data()[["Conflict of interest"]]))) {
        "There are no conflict of interest statements provided for any of the contributors."
      } else if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        HTML(
          print_conflict_statement(
            contributors_table = input_data(),
            initials = input$initials
          )
        )
      }
    })
    
    ## Build modal
    modal <- function() {
      modalDialog(
        h3("Conflict of interest statement"),
        # Toggle between initials and full names
        div(
          shinyWidgets::materialSwitch(
            NS(id, "initials"),
            label = "Full names",
            inline = TRUE),
          span("Initials")
        ),
        hr(),
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
              onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'Conflict information'])"
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
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Conflict information'])"
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
    
    # Download ---------------------------
    ## Set up loading bar
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    ## Restructure dataframe for the output
    to_download_and_clip <- reactive({
      if(all(is.na(input_data()[["Conflict of interest"]])) | has_errors()) {
        "There are no conflict of interest statements provided for any of the contributors."
      } else {
        print_conflict_statement(contributors_table = input_data(), initials = input$initials)
      }
    })
    
    ## Set up parameters to pass to Rmd document
    params <- reactive({
      list(conflict_statement = to_download_and_clip())
    })
    
    ## Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste0("conflict_statement_", Sys.Date(), ".doc")
      },
      # Set content of the file
      content = function(file) {
        # Start progress bar
        waitress$notify()
        # Copy the report file to a temporary directory before processing it
        file_path <- file.path("inst/app/www/", "conflict_statement.Rmd")
        file.copy("conflict_statement.Rmd", file_path, overwrite = TRUE)
        
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
    ## Add clipboard buttons
    clipboard_payload <- reactive({
      req(modal_open())
      text_value <- to_download_and_clip()
      html_value <- paste0("<p>", htmltools::htmlEscape(text_value), "</p>")
      
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
        class = "btn-download")
    })
    
    observeEvent(input$clip_btn, {
      req(modal_open())
      if (has_errors()) {
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
    
## To be copied in the UI
# mod_conflict_statement_ui("conflict_statement")
    
## To be copied in the server
# mod_conflict_statement_server("conflict_statement")
 
