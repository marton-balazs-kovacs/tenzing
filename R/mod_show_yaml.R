# Module UI

#' @title   mod_show_yaml_ui and mod_show_yaml_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_show_yaml
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 

mod_show_yaml_ui <- function(id) {
  
  tagList(
    div(class = "out-btn",
    actionButton(inputId = NS(id, "show_yaml"),
                 label = HTML("Show <code>papaja</code> YAML"),
                 class = "btn btn-primary")
    )
  )
}

# Module Server

#' @rdname mod_show_yaml
#' @export
#' @keywords internal

mod_show_yaml_server <- function(id, input_data) {
  stopifnot(is.reactive(input_data))

  moduleServer(id, function(input, output, session) {
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    # Clean data for table output
    author_yaml <- reactive({
      # Table data validation
      req(input_data())
      
      # Create output
      print_yaml(infosheet = input_data())
    })
    
    yaml_path <- reactive({
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed)
      yamlReport <- file.path("inst/app/www/", "yaml.Rmd")
      file.copy("yaml.Rmd", yamlReport, overwrite = TRUE)
      tempReportRender <- tempfile(fileext = ".html")
      
      # Set up parameters to pass to Rmd document
      params <- list(param_1 = author_yaml())
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(yamlReport, output_file = tempReportRender, params = params, quiet = TRUE)
      
      tempReportRender
    })
    
    # Add clipboard buttons
    output$yaml_clip <- renderUI({
      rclipboard::rclipButton("yaml_clip_btn", "Copy YAML to clipboard", author_yaml(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$yaml_clip_btn, clipr::write_clip(author_yaml()))
    
    # Generate YAML file
    output$report <- downloadHandler(
      
      # Set filename
      filename = function() {
        paste("machine_readable_report_", Sys.Date(), ".yml", sep = "")
      },
      
      # Set content of the file
      content = function(file) {
        yaml::write_yaml(author_yaml(), file)}
    )
    
    # Build modal
    modal <- function() {
      
      modalDialog(
        rclipboard::rclipboardSetup(),
        # div(
        #   style = "float:right; margin-top: 15px; margin-right: 15px;",
        #   uiOutput(session$ns("yaml_clip"))
        # ),
        includeHTML(yaml_path()),
        easyClose = TRUE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("yaml_clip"))
          ),
          downloadButton(
            NS(id, "report"),
            label = "Download YAML file"
          ), 
          modalButton("Close")
        )
      )
    }
    
    observeEvent(input$show_yaml, {
      waitress$notify()
      showModal(modal())
      waitress$close()
      })
    
  })
}

## To be copied in the UI
# mod_show_yaml_ui("show_yaml_ui_1")

## To be copied in the server
# mod_show_yaml_server("show_yaml_ui_1")

