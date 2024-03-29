#' funding_information UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_funding_information_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Show funding information",
          class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'Funding information'])"
        )
  )
}
    
#' funding_information Server Function
#'
#' @noRd 
mod_funding_information_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # Preview ---------------------------
    ## Render preview
    output$preview <- renderUI({
      if(all(is.na(input_data()[["Funding"]]))) {
        "There is no funding information provided for either of the contributors."
        } else {
          HTML(print_funding(contributors_table = input_data(), initials = input$initials))
          }
    })
    
    ## Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Funding information"),
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
              onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'Funding information'])"
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
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'Funding information'])"
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
        "There is no funding information provided for either of the contributors."
      } else {
        print_funding(contributors_table = input_data(), initials = input$initials)
      }
    })
    
    ## Set up parameters to pass to Rmd document
    params <- reactive({
      list(funding_information = to_download_and_clip())
    })
    
    ## Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste0("funding_information_", Sys.Date(), ".doc")
      },
      # Set content of the file
      content = function(file) {
        # Start progress bar
        waitress$notify()
        # Copy the report file to a temporary directory before processing it
        file_path <- file.path("inst/app/www/", "funding_information.Rmd")
        file.copy("funding_information.Rmd", file_path, overwrite = TRUE)
        
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
# mod_funding_information_ui("funding_information")
    
## To be copied in the server
# mod_funding_information_server("funding_information")
 
