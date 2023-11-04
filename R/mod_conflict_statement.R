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
          label = "Show conflict of interest statement",
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
    ns <- session$ns
    # Preview ---------------------------
    ## Render preview
    output$preview <- renderUI({
      if(all(is.na(input_data()[["Conflict of interest"]]))) {
        "There are no conflict of interest statements provided for any of the contributors."
        } else {
          HTML(print_conflict_statement(contributors_table = input_data(), initials = input$initials))
          }
    })
    
    ## Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
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
        easyClose = TRUE,
        footer = tagList(
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
              class = "download-report"
              )
          ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Conflict information'])"
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
    
    ## Restructure dataframe for the output
    to_download_and_clip <- reactive({
      if(all(is.na(input_data()[["Funding"]]))) {
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
    output$clip <- renderUI({
      rclipboard::rclipButton(
        inputId = "clip_btn", 
        label = "Copy output to clipboard", 
        clipText =  to_download_and_clip(), 
        icon = icon("clipboard"),
        modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(to_download_and_clip()))
  })
 
}
    
## To be copied in the UI
# mod_conflict_statement_ui("conflict_statement")
    
## To be copied in the server
# mod_conflict_statement_server("conflict_statement")
 
