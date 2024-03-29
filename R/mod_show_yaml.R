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
        actionButton(
          inputId = NS(id, "show_yaml"),
          label = HTML("Show <i>papaja</i> YAML"),
          class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'YAML information'])"
        )
    )
}

# Module Server

#' @rdname mod_show_yaml
#' @export
#' @keywords internal

mod_show_yaml_server <- function(id, input_data) {

  moduleServer(id, function(input, output, session) {
    # Create YAML
    author_yaml <- reactive({
      # Table data validation
      req(input_data())
      
      # Create output
      print_yaml(contributors_table = input_data())
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
      rclipboard::rclipButton(
        inputId = "yaml_clip_btn",
        label = "Copy YAML to clipboard",
        clipText = author_yaml(),
        icon = icon("clipboard"),
        modal = TRUE)
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
          ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'YAML information'])"
            ),
          div(
            style = "display: inline-block",
            downloadButton(
              NS(id, "report"),
              label = "Download YAML file",
              class = "download-report"
              )
            ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'YAML information'])"
              ), 
          modalButton("Close")
        )
      )
    }
    
    observeEvent(input$show_yaml, {
      showModal(modal())
      })
    
  })
}

## To be copied in the UI
# mod_show_yaml_ui("show_yaml")

## To be copied in the server
# mod_show_yaml_server("show_yaml")

