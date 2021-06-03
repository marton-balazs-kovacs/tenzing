# Module UI
  
#' @title   mod_human_readable_report_ui and mod_human_readable_report_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_human_readable_report
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_human_readable_report_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Show author contributions text",
          class = "btn btn-primary btn-validate")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_human_readable_report
#' @export
#' @keywords internal
    
mod_human_readable_report_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # Preview ---------------------------
    ## Render preview
    output$preview <- renderText({
      if (all(input_data()[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
        } else {
          print_roles_readable(infosheet = input_data(), text_format = "html", initials = input$initials)
          }
    })
    
    ## Build preview modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Author contributions"),
        # Toggle between initials and full names
        div(
          shinyWidgets::materialSwitch(
            NS(id, "initials"),
            label = "Full names",
            inline = TRUE),
          span("Initials")
        ),
        hr(),
        htmlOutput(NS(id, "preview")),
        easyClose = TRUE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ),
          downloadButton(
            NS(id, "report"),
            label = "Download file",
            class = "download-report"
          ),
          modalButton("Close")
        )
      )
    }
    
    ## Show preview modal
    observeEvent(input$show_report, {
      showModal(modal())
    })
    
    # Download ---------------------------
    ## Set up loading bar
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    ## Restructure dataframe for the human readable output
    to_download <- reactive({
      if (all(input_data()[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
        } else {
          print_roles_readable(infosheet = input_data(), initials = input$initials)
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
      if (all(input_data()[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
        } else {
          print_roles_readable(infosheet = input_data(), text_format = "raw", initials = input$initials)
          }
    })
    
    ## Add clipboard buttons
    output$clip <- renderUI({
      rclipboard::rclipButton("clip_btn", "Copy output to clipboard", to_clip(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(to_clip()))
  })
}
    
## To be copied in the UI
# mod_human_readable_report_ui("human_readable_report_ui_1")
    
## To be copied in the server
# mod_human_readable_report_server("human_readable_report_ui_1")
 
