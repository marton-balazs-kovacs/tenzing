# Module UI
  
#' @title   mod_credit_roles_ui and mod_credit_roles_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_credit_roles
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_credit_roles_ui <- function(id){

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
    
#' @rdname mod_credit_roles
#' @export
#' @keywords internal
    
mod_credit_roles_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    # Preview ---------------------------
    ## Render preview
    output$preview <- renderText({
      if (all(input_data()[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for either of the contributors."
        } else {
          print_credit_roles(infosheet = input_data(), text_format = "html", initials = input$initials, order_by = order())
          }
    })
    
    ## Build preview modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        h3("Author contributions"),
        # Toggle between initials and full names
        div(
          style = "display:inline-block; width:100%; padding-bottom:0px; margin-bottom:0px;",
          div(
            style = "display:inline-block; float:left;",
            shinyWidgets::materialSwitch(
              NS(id, "initials"),
              label = "Full names",
              inline = TRUE),
            span("Initials")
          ),
          div(
            style = "display:inline-block; float:right;",
            shinyWidgets::materialSwitch(
              NS(id, "order_by"),
              label = "Contributor names",
              inline = TRUE),
            span("Roles")
            )
          ),
        hr(style= "margin-top:5px; margin-bottom:10px;"),
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
    
    ## Switch for order_by input
    order <- reactive({
      ifelse(input$order_by, "contributor", "role")
    })
    
    # Download ---------------------------
    ## Set up loading bar
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)
    
    ## Restructure dataframe for the human readable output
    to_download <- reactive({
      if (all(input_data()[dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)] == FALSE)) {
        "There are no CRediT roles checked for any of the contributors."
        } else {
          print_credit_roles(infosheet = input_data(), initials = input$initials, order_by = order())
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
          print_credit_roles(infosheet = input_data(), text_format = "raw", initials = input$initials, order_by = order())
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
# mod_credit_roles_ui("credit_roles")
    
## To be copied in the server
# mod_credit_roles_server("credit_roles")
 
