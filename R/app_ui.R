#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    # Enabling shiny js functions
    shinyjs::useShinyjs(),
    
    # List the first level UI elements here 
    fluidPage(
      mod_about_modal_ui("about_modal_ui_1"),
      mod_show_spreadsheet_ui("show_spreadsheet_ui_1"),
      h1("tenzing"),
      fluidRow(
        # Sidebar panel
        column(4,
               wellPanel(
                 fluidRow(
                   mod_read_spreadsheet_ui("read_spreadsheet_ui_1")),
                 hr(),
                 fluidRow(
                   mod_human_readable_report_ui("human_readable_report_ui_1")),
                 hr(),
                 fluidRow(
                   mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1"))
                 )
               ),
        column(8)
        )
      ),
    
    # Enabling waiter js functions
    waiter::use_waiter(include_js = FALSE),
    
    # Add waiter load on start
    waiter::waiter_show_on_load()
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'tenzing')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon()
    # Add here all the external resources
    # If you have a custom.css in the inst/app/www
    # Or for example, you can add shinyalert::useShinyalert() here
    #tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
  )
}
