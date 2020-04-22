#' @import shiny
app_server <- function(input, output,session) {
  
  # Show about modal
  mod_about_modal_server("about_modal_ui_1")
  
  # Read in the data based on the provided url string
  # Save the read data as a reactive object
  read_out <- mod_read_spreadsheet_server("read_spreadsheet_ui_1")
  
  # Show the spreadsheet in viewer window
  mod_show_spreadsheet_server("show_spreadsheet_ui_1", input_data = read_out$data, uploaded = read_out$uploaded)
  
  # Generate a human readable report
  mod_human_readable_report_server("human_readable_report_ui_1", input_data = read_out$data, uploaded = read_out$uploaded)
  
  # Generate the first page with contributors affiliation
  mod_contribs_affiliation_page_server("contribs_affiliation_page_ui_1", input_data = read_out$data, uploaded = read_out$uploaded)
  
  # Hide on launch waiter screen
  waiter::waiter_hide()
}
