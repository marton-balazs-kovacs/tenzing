# Module UI

#' @title   mod_show_yaml_ui and mod_show_yaml_server
#' @description  A shiny Module.
#'
#' @param id shiny id
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
          label = HTML("<i>papaja</i> YAML"),
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
    # Setup ---------------------------
    ns <- session$ns
    
    # Reactive value to track modal state
    modal_open <- reactiveVal(FALSE)
    
    # Validation ---------------------------
    # Initialize ValidateOutput with the title validation config
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/yaml_validation.yaml", package = "tenzing")
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
    
    # Create YAML
    author_yaml <- reactive({
      # Table data validation
      req(input_data(), modal_open())
      
      # Create output
      if (has_errors()) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        print_yaml(contributors_table = input_data())
      } 
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
    yaml_clip_payload <- reactive({
      req(modal_open())
      yaml_text <- author_yaml()
      
      list(
        html = paste0(
          "<pre><code class=\"language-yaml\">",
          htmltools::htmlEscape(yaml_text),
          "</code></pre>"
        ),
        text = yaml_text
      )
    })
    
    output$yaml_clip <- renderUI({
      actionButton(
        inputId = ns("yaml_clip_btn"),
        label = "Copy YAML to clipboard",
        icon = icon("clipboard"),
        class = "btn-download")
    })
    
    observeEvent(input$yaml_clip_btn, {
      req(modal_open())
      if (has_errors()) {
        return(NULL)
      }
      
      payload <- yaml_clip_payload()
      copy_to_clipboard(
        session = session,
        html = payload$html,
        text = payload$text,
        status_input = ns("clipboard_status")
      )
    })
    
    # Build modal
    modal <- function() {
      modalDialog(
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
        easyClose = FALSE,
        footer = tagList(
          mod_validation_card_ui(ns("validation_card")),
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
              class = "btn-download"
              )
            ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'YAML information'])"
              ), 
          actionButton(ns("close_modal"), label = "Close", class = "btn btn-close")
        )
      )
    }
    
    ## Show preview modal
    observeEvent(input$show_yaml, {
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
# mod_show_yaml_ui("show_yaml")

## To be copied in the server
# mod_show_yaml_server("show_yaml")

