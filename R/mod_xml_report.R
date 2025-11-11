# Module UI
  
#' @title   mod_xml_report_ui and mod_xml_report_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#'
#' @rdname mod_xml_report
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList
#' @importFrom stringr str_detect str_locate str_sub 
mod_xml_report_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(NS(id, "show_report"),
                       label = "JATS-XML (for publisher use)",
                       class = "btn btn-primary btn-validate")
        ) %>% 
      tagAppendAttributes(
        # Track click event with Matomo
        onclick = "_paq.push(['trackEvent', 'Output', 'Click show', 'XML information'])"
        )
    )
  }
    
# Module Server
    
#' @rdname mod_xml_report
#' @export
#' @keywords internal
    
mod_xml_report_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # Setup ---------------------------
    ns <- session$ns
    
    # Reactive value to track modal state
    modal_open <- reactiveVal(FALSE)
    
    # Validation ---------------------------
    # Initialize ValidateOutput with the xml validation config
    validate_output_instance <- ValidateOutput$new(
      config_path = system.file("config/xml_validation.yaml", package = "tenzing")
    )
    
    # Initialize validation card logic only when modal is open
    # Use mod_validation_card_server to handle validation and get error status
    has_errors <- mod_validation_card_server(
      id = "validation_card",
      contributors_table = input_data,
      validate_output_instance = validate_output_instance,
      trigger = modal_open,
      context = reactive({
        # Get include_orcid toggle value, defaulting to TRUE if not initialized
        incl_orcid <- tryCatch(isTRUE(input$include_orcid), error = function(e) TRUE)
        list(
          include = "author",
          include_orcid = incl_orcid
        )
      })
    )
    
    observe({
      req(modal_open())
      # Safely check for errors, ensuring we get TRUE/FALSE, never NA
      errors <- tryCatch(isTRUE(has_errors()), error = function(e) FALSE)
      if (errors) {
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
    
    # Create XML
    to_print <- reactive({
      # Table data validation
      req(input_data(), modal_open())

      # Create output
      # Safely check for errors, ensuring we get TRUE/FALSE, never NA
      errors <- tryCatch(isTRUE(has_errors()), error = function(e) FALSE)
      
      if (errors) {
        "The output cannot be generated. See 'Table Validation' for more information."
      } else {
        # Get toggle values, defaulting to FALSE if not yet initialized
        full_doc <- tryCatch(isTRUE(input$full_document), error = function(e) FALSE)
        incl_ack <- tryCatch(isTRUE(input$include_acknowledgees), error = function(e) FALSE)
        incl_orcid <- tryCatch(isTRUE(input$include_orcid), error = function(e) TRUE)  # Default to TRUE
        
        # Wrap in tryCatch to handle any runtime errors gracefully
        result <- tryCatch({
          print_xml(
            contributors_table = input_data(), 
            full_document = full_doc,
            include_acknowledgees = incl_ack,
            include_orcid = incl_orcid
          )
        }, error = function(e) {
          paste0("Error generating XML: ", conditionMessage(e))
        })
        result
      } 
    })

    ## Create preview
    output$jats_xml <- renderUI({
      xml_output <- to_print()
      # Handle both XML nodeset and character strings
      if (inherits(xml_output, "xml_document") || inherits(xml_output, "xml_node")) {
        xml_str <- as.character(xml_output)
      } else {
        xml_str <- as.character(xml_output)
      }
      
      tagList(
        tagAppendAttributes(
          tags$code(xml_str),
          class = "language-xml"
        ),
        tags$script("Prism.highlightAll()")
      )
    })
    
    
    # Render output Rmd
    output$report <- downloadHandler(
      # Set filename
      filename = function() {
        paste("machine_readable_report_", Sys.Date(), ".xml", sep = "")
      },
      
      # Set content of the file
      content = function(file) {
        xml_output <- to_print()
        # Get toggle value to determine if DOCTYPE should be added
        full_doc <- tryCatch(isTRUE(input$full_document), error = function(e) FALSE)
        
        # Only write XML if it's actually an XML object
        if (inherits(xml_output, "xml_document") || inherits(xml_output, "xml_node")) {
          # Convert to character first
          xml_string <- as.character(xml_output)
          # Add DOCTYPE declaration only for full documents
          if (full_doc) {
            doctype <- paste0('<!DOCTYPE article\n',
                             '  PUBLIC \'-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.3 20210610//EN\'\n',
                             '  \'https://jats.nlm.nih.gov/publishing/1.3/JATS-journalpublishing1-3.dtd\'>\n')
            # Insert DOCTYPE after XML declaration
            if (stringr::str_detect(xml_string, '^<\\?xml')) {
              # Find the end of the XML declaration (first >)
              xml_decl_end <- stringr::str_locate(xml_string, '\\?>')[1, "end"]
              if (!is.na(xml_decl_end)) {
                xml_string <- paste0(
                  stringr::str_sub(xml_string, 1, xml_decl_end),
                  "\n",
                  doctype,
                  stringr::str_sub(xml_string, xml_decl_end + 1)
                )
              }
            }
          }
          writeLines(xml_string, file)
        } else {
          # If it's an error message, write it as text
          writeLines(as.character(xml_output), file)
        }
      }
    )
    
    clipboard_payload <- reactive({
      req(modal_open())
      xml_output <- to_print()
      xml_str <- if (inherits(xml_output, "xml_document") || inherits(xml_output, "xml_node")) {
        as.character(xml_output)
      } else {
        as.character(xml_output)
      }
      
      list(
        html = paste0(
          "<pre><code class=\"language-xml\">",
          htmltools::htmlEscape(xml_str),
          "</code></pre>"
        ),
        text = xml_str
      )
    })
    
    # Add clipboard buttons
    output$clip <- renderUI({
      actionButton(
        inputId = ns("clip_btn"),
        label = "Copy output to clipboard", 
        icon = icon("clipboard"),
        class = "btn-download"
      )
    })
    
    observeEvent(input$clip_btn, {
      req(modal_open())
      if (isTRUE(has_errors())) {
        return(NULL)
      }
      payload <- clipboard_payload()
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
        size = "l",
        h3("JATS XML"),
        hr(),
        p("The Journal Article Tag Suite (JATS) is an XML format used to describe scientific literature published online.", a("Find out more about JATS XML", href = "https://en.wikipedia.org/wiki/Journal_Article_Tag_Suite")),
        div(
          class = "toggle-row",
          toggle(ns, "full_document", "Generate full article", value = TRUE),
          toggle(ns, "include_acknowledgees", "Include acknowledgements", value = TRUE),
          toggle(ns, "include_orcid", "Include ORCID", value = TRUE)
        ),
        hr(style = "margin-top:5px; margin-bottom:10px;"),
        uiOutput(NS(id, "jats_xml"), container = pre),
        easyClose = FALSE,
        footer = tagList(
          mod_validation_card_ui(ns("validation_card")),
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ) %>%
            tagAppendAttributes(
            # Track click event with Matomo
            onclick = "_paq.push(['trackEvent', 'Output', 'Click clip', 'XML information'])"
            ),
          div(
            style = "display: inline-block",
            downloadButton(
              NS(id, "report"),
              label = "Download file",
              class = "btn-download"
              )
            ) %>% 
            tagAppendAttributes(
              # Track click event with Matomo
              onclick = "_paq.push(['trackEvent', 'Output', 'Click download', 'XML information'])"
            ),
          actionButton(ns("close_modal"), label = "Close", class = "btn btn-close")
        )
      )
    }
    
    ## Show preview modal
    observeEvent(input$show_report, {
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
# mod_xml_report_ui("xml_report")
    
## To be copied in the server
# mod_xml_report_server("xml_report")
 
