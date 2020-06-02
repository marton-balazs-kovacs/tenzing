#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    fluidPage(
      fluidRow(
        column(11, offset = 1,
               tags$div(
                 h2("Tenzing", style = "color: #D45F68; font-weight: 700; display: inline;"),
                 h4("Documenting contributorship with CRediT", style = "color: #b2dcce; font-weight: 500; display: inline;"),
               style = "margin-bottom: 10px; margin-top: 10px;"))),
      # Body
      fluidRow(
        column(4, offset = 1,
               wellPanel(
                 h3("1. Create your infosheet", style = "font-weight: 500; line-height: 1.1; margin-top: 0; color: #D45F68;"),
                 tags$p("First copy and then fill out this ", style = "display: inline;"),
                 tags$a(href="https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing",
                        "infosheet template",
                        style = "display: inline;"),
                 style = "background-color: #b2dcce; box-shadow: none; border: none; margin-bottom: 15px;"),
               wellPanel(
                 h3("2. Upload your infosheet", style = "font-weight: 500; line-height: 1.1; margin-top: 0; color: #D45F68;"),
                 mod_read_spreadsheet_ui("read_spreadsheet_ui_1"),
                 mod_show_spreadsheet_ui("show_spreadsheet_ui_1"),
                 style = "background-color: #b2dcce; box-shadow: none; border: none; margin-bottom: 15px;"),
               wellPanel(
                 h3("3. Download the output", style = "font-weight: 500; line-height: 1.1; margin-top: 0;  color: #D45F68;"),
                 mod_human_readable_report_ui("human_readable_report_ui_1"),
                 mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1"),
                 mod_xml_report_ui("xml_report_ui_1"),
                 mod_show_yaml_ui("show_yaml_ui_1"),
                 style = "background-color: #b2dcce; box-shadow: none; border: none; margin-bottom: 15px;"
                 )
               ),
        column(6,
               wellPanel(
                   includeMarkdown("inst/app/www/introduction.Rmd"),
                   br(),
                   fluidRow(
                     mod_about_modal_ui("about_modal_ui_1"),
                     align = "right"),
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
    tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css"),
    tags$style(".progress-bar{background-color:#7ec4ad;}"),
    tags$style(".form-control:focus {
      border-color: #7ec4ad;
        box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(84, 200, 155, 1);
    }"),
    tags$style("#about_modal_ui_1-open_about{color: #D45F68; border-color: #D45F68;}"),
    tags$style(".form-control{border-color: #7ec4ad;}"),
    tags$style(".form-control[readonly]{background-color: #F8FCFB;}"),
    tags$style(HTML("a {color: #326F5E}")),
    tags$style(HTML("a:hover {color: #7ec4ad}")),
    tags$style(".btn:focus{outline: none !important;}"),
    tags$style(".form-group{margin-bottom: 0px !important;}"),
    tags$style(".well{padding: 17px;}")
  )
}
