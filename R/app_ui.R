#' @import shiny
#' @import markdown
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    navbarPage(
      # Header
      header = ui_navbar_header(),
      # Title
      title = ui_app_title(),
      # Tenzing tab
      tabPanel(
        "tenzing",
        column(2),
        column(8,
               # First step
               ui_step_panel(
                 number = 1,
                 title = "Create your contributors table",
                 help_text = "Copy the contributors table template in Google Drive. Go to File -> Make a copy",
                 content = mod_create_table_ui("create_table")
               ),
               # Second step
               ui_step_panel(
                 number = 2,
                 title = "Load your contributors table",
                 help_text = "Use the share URL of the filled out contributors table and click on the upload button. OR upload your contributors table in a .csv, .tsv or .xlsx format.",
                 content = tagList(
                   mod_read_spreadsheet_ui("read_spreadsheet"),
                   mod_show_spreadsheet_ui("show_spreadsheet")
                 )
               ),
               # Third step
               ui_step_panel(
                 number = 3,
                 title = "Generate an output",
                 help_text = "You need a valid contributors table to generate the outputs. Once you have it, click on one of the output buttons to preview and download the output.",
                 content = tagList(
                   mod_credit_roles_ui("credit_roles"),
                   mod_title_page_ui("title_page"),
                   mod_xml_report_ui("xml_report"),
                   mod_show_yaml_ui("show_yaml"),
                   mod_funding_information_ui("funding_information"),
                   mod_conflict_statement_ui("conflict_statement")
                 )
               ),
               # Citation
               ui_citation_section(),
               # Privacy notice
               ui_privacy_notice()
        ),
        column(2)
        ),
      # How to use tab
      tabPanel(
        "How to use tenzing",
        wellPanel(
          id = "intro-panel",
          includeMarkdown(app_sys("app/www/introduction.Rmd"))
          )
        ),
      # About tab
      tabPanel(
        "About",
        wellPanel(
          id = "about-panel",
          includeMarkdown(app_sys("app/www/about.Rmd"))
          )
        )
      ),
    
    # Enabling waiter JS functions
    waiter::use_waiter(),
    waiter::use_waitress(color = "#D45F68"),
    
    # Add waiter load on start
    waiter::waiter_show_on_load(html =  tagList(
      tags$img(src = "www/favicon.png", height = "250px"),
      h4("The app is loading...")), color = "#D45F68")
  )
}

#' @import shiny
golem_add_external_resources <- function(){
  
  setup_resource_paths()
 
  tags$head(
    golem::activate_js(),
    golem::favicon(ext = "png"),
    add_css_resources(),
    add_js_libraries(),
    add_custom_js_files(),
    shinyjs::useShinyjs(), #To create pop-up, in app_server.R
    # Matomo analytics
    # includeHTML(app_sys("app/www/usage_tracker.html"))
    add_analytics_script()
  )
}
