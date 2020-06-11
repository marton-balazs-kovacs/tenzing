# Module UI
  
#' @title   mod_contribs_affiliation_page_ui and mod_contribs_affiliation_page_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_contribs_affiliation_page
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_contribs_affiliation_page_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Show author list with affiliations",
          class = "btn btn-primary")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_contribs_affiliation_page
#' @export
#' @keywords internal
    
mod_contribs_affiliation_page_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)

    # Restructure dataframe for the contributors affiliation output
    to_print <- reactive({
      contrib_affil_print(infosheet = input_data())
    })
    
    # Set up parameters to pass to Rmd document
    params <- reactive({
      list(
        contrib_data = to_print()$contrib,
        affil_data = to_print()$affil)
    })
    
    report_path <- reactive({
      file_path <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
      file.copy("contribs_affiliation.Rmd", file_path, overwrite = TRUE)
      tempReportRender <- tempfile(fileext = ".html")

      callr::r(
        render_report,
        list(input = file_path, output = tempReportRender, format = "html_document", params = params())
      )
      
      tempReportRender
    })
    
    # Render output Rmd
    output$report <- downloadHandler(
      filename = function() {
        paste0("contributors_affiliation_", Sys.Date(), ".doc")
      },
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed)
        file_path <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
        file.copy("contribs_affiliation.Rmd", file_path, overwrite = TRUE)

        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        callr::r(
          render_report,
          list(input = file_path, output = file, format = "word_document", params = params())
        )
      }
    )
    
    to_clip <- reactive({
      paste(to_print()$contrib, to_print()$affil, sep = "/n")
    })
    
    # Add clipboard buttons
    output$clip <- renderUI({
      rclipboard::rclipButton("clip_btn", "Copy output to clipboard", to_clip(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(report_path()))
    
    # Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        includeHTML(report_path()),
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
      waitress$notify()
      showModal(modal())
      waitress$close()
      })
  })
}
    
## To be copied in the UI
# mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1")
    
## To be copied in the server
# mod_contribs_affiliation_page_server("contribs_affiliation_page_ui_1")
 
