#' @import shiny
#' @import shinyjs
app_server <- function(input, output,session) {
  observe({
  if (is.null(session$userData$app_open_count)) {
    session$userData$app_open_count <- shiny::reactiveVal(0)
  }
  
  app_open_count <- session$userData$app_open_count()
  session$userData$app_open_count(app_open_count + 1)
  
  # if ((session$userData$app_open_count() %% 4) == 0) {
  #   shiny::showModal(
  #     shiny::modalDialog(
  #       title = "Support the development of Tenzing!",
  #       easyClose = TRUE,
  #       footer = modalButton("Close"),
  #       tagList(
  #         p("Consider donating to support future development!"),
  #         tags$a(href = "https://opencollective.com/tenzing", "Click here to donate!", target = "_blank")
  #       )
  #     )
  #   )
  # }

if ((session$userData$app_open_count() %% 4) == 0) {
    # Show a non-aggressive pop-up notification using shinyjs
    shinyjs::runjs("
      const div = document.createElement('div');
      div.innerHTML = '<strong>Support the App!</strong><br>Consider donating <a href=\"https://your-donation-link.com\" target=\"_blank\">here</a>!';
      div.style.position = 'fixed';
      div.style.bottom = '20px';
      div.style.right = '20px';
      div.style.padding = '10px';
      div.style.background = 'lightblue';
      div.style.border = '1px solid gray';
      div.style.borderRadius = '5px';
      div.style.zIndex = 9999;
      document.body.appendChild(div);

      // Remove the notification after 10 seconds
      setTimeout(function() { div.remove(); }, 10000);
    ")
          }
 })
  
  # Read in the contributors_table
  ## Save the read data as a reactive object
  read_out <- mod_read_spreadsheet_server("read_spreadsheet")
  
  # Output generating button activation
  ## Disable button on start and add tooltip
  ### Buttons that need a validated contributors_table
  golem::invoke_js("disable", ".btn-validate")
  golem::invoke_js("add_tooltip",
                   list(
                     where = ".out-btn",
                     message = "Please upload a valid contributors_table"))

  ## Toggle logic for multiple uploads
  observeEvent(read_out$upload(), {
    if(read_out$is_valid()) {
      golem::invoke_js("reable", ".btn-validate")
      golem::invoke_js("remove_tooltip", ".out-btn")
      } else{
        golem::invoke_js("disable", ".btn-validate")
        golem::invoke_js("add_tooltip",
                         list(
                           where = ".out-btn",
                           message = "Please upload a valid contributors_table"))
        }
    })
  
  # Show the spreadsheet in viewer window
  mod_show_spreadsheet_server("show_spreadsheet", input_data = read_out$data)
  
  # Show a human readable report in viewer window
  mod_credit_roles_server("credit_roles", input_data = read_out$data)
  
  # Show the first page with contributors affiliation in viewer window
  mod_title_page_server("title_page", input_data = read_out$data)
  
  # Show a JATS XML report in viewer window
  mod_xml_report_server("xml_report", input_data = read_out$data)
  
  # Show papaja YAML in viewer window
  mod_show_yaml_server("show_yaml", input_data = read_out$data)
  
  # Show funding information in viewer window
  mod_funding_information_server("funding_information", input_data = read_out$data)
  
  # Show conflict of interest statement
  mod_conflict_statement_server("conflict_statement", input_data = read_out$data)
  
  # Hide on launch waiter screen
  waiter::waiter_hide()
}
