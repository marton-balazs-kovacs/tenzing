#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    # List the first level UI elements here 
    fluidPage(
      
      mod_about_modal_ui("about_modal_ui_1"),
      titlePanel(
        fluidRow(
          column(1),
          column(4, h2("Project Tenzing", style = "color: #D45F68; font-weight: 700;"))
        )
      ),
      fluidRow(
        # Sidebar panel
        column(1),
        column(4,
               wellPanel(
                 h3("Input", style = "font-weight: 500; line-height: 1.1; margin-top: 0; color: #D45F68;"),
                 fluidRow(
                   mod_read_spreadsheet_ui("read_spreadsheet_ui_1"),
                   mod_show_spreadsheet_ui("show_spreadsheet_ui_1")),
                 style = "background-color: #b2dcce; box-shadow: none; border: none;"),
               wellPanel(
                 h3("Output", style = "font-weight: 500; line-height: 1.1; margin-top: 0;  color: #D45F68;"),
                 fluidRow(
                   mod_human_readable_report_ui("human_readable_report_ui_1")),
                 hr(),
                 fluidRow(
                   mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1")),
                 style = "background-color: #b2dcce; box-shadow: none; border: none;"
                 )
               ),
        column(6,
               wellPanel(
                   includeMarkdown("inst/app/www/introduction.Rmd"),
                   style = "background-color: #ffec9b; box-shadow: none; border: none;")),
        column(1)
        )
      ),
    
    # Enabling waiter js functions
    waiter::use_waiter(include_js = FALSE),
    
    # Add waiter load on start
    waiter::waiter_show_on_load(html =  tagList(
      waiter::spin_4(),
      h4("The app is loading...")), color = "#D45F68")
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'tenzing')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon(),
    # Add here all the external resources
    # If you have a custom.css in the inst/app/www
    # Or for example, you can add shinyalert::useShinyalert() here
    # tags$link(rel="stylesheet", type="text/css", href="www/bootstrap.min.css"),
    # Enabling shiny js functions
    shinyjs::useShinyjs(),
    tags$style(".progress-bar{background-color:#7ec4ad;}"),
    tags$style(".form-control:focus {
      border-color: #7ec4ad;
        box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(84, 200, 155, 1);
    }"),
    tags$style(".bttn-bordered.bttn-primary{color: #326F5E; border-color: #326F5E;}"),
    tags$style(".bttn-bordered.bttn-primary:hover{border-color: #7ec4ad;}"),
    tags$style(".bttn-bordered.bttn-primary:active {border-color: #224C40;}"),
    tags$style(".bttn-bordered.bttn-primary:visited {border-color: #326F5E;}"),
    tags$style(".bttn-bordered.bttn-primary:focus {border-color: #193B30;}"),
    tags$style("#about_modal_ui_1-open_about{color: #D45F68; border-color: #D45F68;}"),
    tags$style(".form-control{border-color: #7ec4ad;}"),
    tags$style(".form-control[readonly]{background-color: #F8FCFB;}"),
    tags$style(HTML("a {color: #326F5E}")),
    tags$style(HTML("a:hover {color: #7ec4ad}")),
    tags$style("#contribs_affiliation_page_ui_1-report[disabled] {color: currentColor; display: inline-block; pointer-events: none; text-decoration: none;}"),
    tags$style("#human_readable_report_ui_1-report[disabled] {color: currentColor; display: inline-block; pointer-events: none; text-decoration: none;}"),
    tags$style(".btn:focus{outline: none !important;}")
  )
}
