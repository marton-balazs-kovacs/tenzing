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
                       label = "Show XML file (for publisher use)",
                       class = "btn btn-primary")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_xml_report
#' @export
#' @keywords internal
    
mod_xml_report_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    # Prepare the spreadsheet data
    to_print <- reactive({
      xml_print(infosheet = input_data())
    })
    
    # # Create preview
    output$xml_path <- renderText({as.character(to_print())})
  
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
      rclipboard::rclipButton("clip_btn", "Copy output to clipboard", to_print(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(report_path()))
    
    # Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        textOutput(NS(id, "xml_path")),
        easyClose = TRUE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ),
          downloadButton(
            NS(id, "report"),
            label = "Download file"
          ),
          modalButton("Close")
        )
      )
    }
    
    observeEvent(input$show_report, {
      # waitress$notify()
      showModal(modal())
      # waitress$close()
      })
    })
}
    
## To be copied in the UI
# mod_xml_report_ui("xml_report_ui_1")
    
## To be copied in the server
# mod_xml_report_server("xml_report_ui_1")
 
