#' @import shiny
app_server <- function(input, output,session) {
  # Show about modal
  mod_about_modal_server("about_modal_ui_1")
  
  # Read in the infosheet
  ## Save the read data as a reactive object
  read_out <- mod_read_spreadsheet_server("read_spreadsheet_ui_1")
  
  # Output generating button activation
  ## Disable button on start and add tooltip
  golem::invoke_js("disable", ".btn-primary")
  golem::invoke_js("add_tooltip", ".out-btn")
  ## Logic for multiple uploads
  observeEvent(read_out$uploaded(), {
    if(!is.null(read_out$valid_infosheet())){
      golem::invoke_js("reable", ".btn-primary")
      golem::invoke_js("remove_tooltip", ".out-btn")
    } else{
      golem::invoke_js("disable", ".btn-primary")
      golem::invoke_js("add_tooltip", ".out-btn")
    }
  })
  
  # Show the spreadsheet in viewer window
  mod_show_spreadsheet_server("show_spreadsheet_ui_1", input_data = read_out$data)
  
  # Show a human readable report in viewer window
  mod_human_readable_report_server("human_readable_report_ui_1", input_data = read_out$data)
  
  # Show the first page with contributors affiliation in viewer window
  mod_contribs_affiliation_page_server("contribs_affiliation_page_ui_1", input_data = read_out$data)
  
  # Show a JATS XML report in viewer window
  mod_xml_report_server("xml_report_ui_1", input_data = read_out$data)
  
  # Show papaja YAML in viewer window
  mod_show_yaml_server("show_yaml_ui_1", input_data = read_out$data)
  
  # Show grant infromation in viewer window
  mod_grant_information_server("grant_information", input_data = read_out$data)
  
  # Hide on launch waiter screen
  waiter::waiter_hide()
}
