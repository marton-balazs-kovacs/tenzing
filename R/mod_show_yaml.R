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

  moduleServer(id, function(input, output, session) {
    # waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    # Create YAML
    author_yaml <- reactive({
      # Table data validation
      req(input_data())
      
      # Create output
      print_yaml(infosheet = input_data())
    })
    
    ## Create preview
    output$papaja_yaml <- renderUI({
      tagList(
        tagAppendAttributes(
          tags$code(author_yaml()),
          class = "language-yaml"
        ),
        tags$script("Prism.highlightAll()")
      )
    })
    
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

    # Add clipboard buttons
    output$yaml_clip <- renderUI({
      rclipboard::rclipButton("yaml_clip_btn", "Copy YAML to clipboard", author_yaml(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$yaml_clip_btn, clipr::write_clip(author_yaml()))
    
    # Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3(HTML("<code>papaja</code>"), "YAML"),
        hr(),
        p(
          HTML("<code>papaja</code>"), "is an R package that provides document formats to produce complete APA manuscripts from R Markdown in PDF- and DOCX-format. The package also provides helper functions that facilitate reporting statistics, tables, and plots.",
          a("Find out more about ", HTML("<code>papaja</code>"), href = "https://github.com/crsh/papaja")
        ),
        p(
          "You can copy the YAML code below and paste it into the YAML front matter of a ", HTML("<code>papaja</code>"), "-R Markdown file to populate the author metadata. ", HTML("<code>papaja</code>"), " will automatically add the contributorship information to the author note."
        ),
        uiOutput(NS(id, "papaja_yaml"), container = pre),
        easyClose = TRUE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("yaml_clip"))
          ),
          downloadButton(
            NS(id, "report"),
            label = "Download YAML file",
            class = "download-report"
          ), 
          modalButton("Close")
        )
      )
    }
    
    observeEvent(input$show_yaml, {
      # waitress$notify()
      showModal(modal())
      # waitress$close()
      })
    
  })
}

## To be copied in the UI
# mod_show_yaml_ui("show_yaml_ui_1")

## To be copied in the server
# mod_show_yaml_server("show_yaml_ui_1")

