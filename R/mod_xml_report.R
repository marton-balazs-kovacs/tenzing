# Module UI
  
#' @title   mod_xml_report_ui and mod_xml_report_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_xml_report
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_xml_report_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(NS(id, "show_report"),
                       label = "JATS-XML (for publisher use)",
                       class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'XML information'])"
        )
    )
  }
    
# Module Server
    
#' @rdname mod_xml_report
#' @export
#' @keywords internal
    
mod_xml_report_server <- function(id, input_data){
  
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
    
    # Create XML
    to_print <- reactive({
      # Table data validation
      req(input_data(), modal_open())

      # Create output
      if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        print_xml(contributors_table = input_data())
      } 
    })

    ## Create preview
    output$jats_xml <- renderUI({
      tagList(
        tagAppendAttributes(
          tags$code(as.character(to_print())),
          class = "language-xml"
        ),
        tags$script("Prism.highlightAll()")
      )
    })
    
    
    # Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste("machine_readable_report_", Sys.Date(), ".xml", sep = "")
      },
      
      # Set content of the file
      content = function(file) {
        xml2::write_xml(to_print(), file, options = "format")}
    )
    
    # Add clipboard buttons
    output$clip <- renderUI({
      rclipboard::rclipButton(
        inputId = "clip_btn",
        label = "Copy output to clipboard", 
        clipText = to_print(), 
        icon = icon("clipboard"),
        modal = TRUE,
        class = "btn-download")
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(to_print()))
    
    # Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("JATS XML"),
        hr(),
        p("The Journal Article Tag Suite (JATS) is an XML format used to describe scientific literature published online.", a("Find out more about JATS XML", href = "https://en.wikipedia.org/wiki/Journal_Article_Tag_Suite")),
        uiOutput(NS(id, "jats_xml"), container = pre),
        easyClose = FALSE,
        footer = tagList(
          mod_validation_card_ui(ns("validation_card")),
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ) %>%
            tagAppendAttributes(
            # Track click event with Matomo
            onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'XML information'])"
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
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'XML information'])"
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
    })
}
    
## To be copied in the UI
# mod_xml_report_ui("xml_report")
    
## To be copied in the server
# mod_xml_report_server("xml_report")
 
