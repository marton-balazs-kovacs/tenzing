#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    tags$head(
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/prism.min.js"),
      tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/components/prism-yaml.min.js"),
      tags$link(rel = "stylesheet", type = "text/css",
                href = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/themes/prism.min.css")
    ),
    
    fluidPage(
      # Title
      fluidRow(
        column(11, offset = 1,
               tags$div(
                 h2(id = "title", "Tenzing"),
                 h4(id = "sub-title", "Documenting contributorship with CRediT"),
               style = "margin-bottom: 10px; margin-top: 10px;"))),
      # Body
      fluidRow(
        column(4, offset = 1,
               wellPanel(
                 class = "main-steps-panel",
                 h3("1. Create your infosheet", class = "main-steps-title"),
                 tags$p("First copy and then fill out this ", style = "display: inline;"),
                 tags$a(href="https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing",
                        "infosheet template",
                        target="_blank",
                        style = "display: inline;")),
               wellPanel(
                 class = "main-steps-panel",
                 h3("2. Upload your infosheet", class = "main-steps-title"),
                 mod_read_spreadsheet_ui("read_spreadsheet_ui_1"),
                 mod_show_spreadsheet_ui("show_spreadsheet_ui_1")),
               wellPanel(
                 class = "main-steps-panel",
                 h3("3. Download the output", class = "main-steps-title"),
                 mod_human_readable_report_ui("human_readable_report_ui_1"),
                 mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1"),
                 mod_xml_report_ui("xml_report_ui_1"),
                 mod_show_yaml_ui("show_yaml_ui_1"))
               ),
        column(6,
               wellPanel(
                 id = "intro-panel",
                 includeMarkdown(app_sys("app/www/introduction.Rmd")),
                 br(),
                 fluidRow(
                   align = "right",
                   mod_about_modal_ui("about_modal_ui_1")))
               ),
        column(1)
        )
      ),
    
    # Enabling waiter JS functions
    waiter::use_waiter(include_js = FALSE),
    waiter::use_waitress(color = "#D45F68"),
    
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
    # golem::favicon(),
    # Add sweetalert2 JS library
    tags$script(src = "https://cdn.jsdelivr.net/npm/sweetalert2@9.14.0/dist/sweetalert2.all.min.js"),
    # Add custom css stylesheet
    tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css"),
    # Add custom JS functions
    tags$script(src = "www/sweet_alert.js"),
    tags$script(src = "www/tooltip.js")
  )
}
