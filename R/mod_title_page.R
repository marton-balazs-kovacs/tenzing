# Module UI
  
#' @title   mod_title_page_ui and mod_title_page_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
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
          label = "Show author list with affiliations",
          class = "btn btn-primary btn-validate")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_contribs_affiliation_page
#' @export
#' @keywords internal
    
mod_title_page_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Preview ---------------------------
    ## Render preview
    output$preview <- renderText({
      print_title_page(infosheet = input_data(), text_format = "html")
    })
    
    ## Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Contributors' affiliation page"),
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
    
    ## Restructure dataframe for the contributors affiliation output
    to_download <- reactive({
      print_title_page(infosheet = input_data())
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
      print_title_page(infosheet = input_data(), text_format = "raw")
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
# mod_title_page_ui("title_page")
    
## To be copied in the server
# mod_title_page_server("title_page")
 
