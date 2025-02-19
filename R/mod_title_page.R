# Module UI
  
#' @title   mod_title_page_ui and mod_title_page_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname mod_title_page
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_title_page_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Contributor list with affiliations",
          class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'Title information'])"
        )
    )
  }
    
# Module Server
    
#' @rdname mod_title_page
#' @export
#' @keywords internal
    
mod_title_page_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # Setup ---------------------------
    ns <- session$ns
    
    # Reactive value to track modal state
    modal_open <- reactiveVal(FALSE)
    
    # Validation ---------------------------
    # Initialize ValidateOutput with the title validation config
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/title_validation.yaml", package = "tenzing")
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
      if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        HTML(print_title_page(contributors_table = input_data(), text_format = "html"))
      }
    })
    
    ## Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Contributors' affiliation page", style = "color: #d45f68;"),
        hr(style = "border-color: #d45f68;"),
        uiOutput(NS(id, "preview")),
        easyClose = FALSE,
        footer = tagList(
          mod_validation_card_ui(ns("validation_card")),
          div(style = "display: inline-block",
              uiOutput(session$ns("clip"))) %>%
            tagAppendAttributes(# Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'Title information'])"),
          div(
            style = "display: inline-block",
            downloadButton(NS(id, "report"),
                           label = "Download file",
                           class = "btn-download")
          ) %>%
            tagAppendAttributes(# Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Title information'])"),
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
    
    ## Restructure dataframe for the contributors affiliation output
    to_download <- reactive({
      req(!has_errors())
      print_title_page(contributors_table = input_data(), text_format = "rmd")
    })
    
    ## Set up parameters to pass to Rmd document
    params <- reactive({
      list(contrib_affil = to_download())
    })
    
    ## Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste0("contributors_affiliation_", Sys.Date(), ".doc")
      },
      # Set content of the file
      content = function(file) {
        # Start progress bar
        waitress$notify()
        # Copy the report file to a temporary directory before processing it
        file_path <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
        file.copy("contribs_affiliation.Rmd", file_path, overwrite = TRUE)
        
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
      if (has_errors()) {
        ""
      } else {
        print_title_page(contributors_table = input_data(), text_format = "raw") 
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
# mod_title_page_ui("title_page")
    
## To be copied in the server
# mod_title_page_server("title_page")
 
