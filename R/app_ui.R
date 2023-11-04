#' @import shiny
app_ui <- function() {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    navbarPage(
      # Header
      header = tagList(
          div(id = "support-div",
              a(id = "support-btn",
                class = "btn",
                href = "https://opencollective.com/tenzing",
                target = "_blank",
                "Support us",
                )
              )
      ),
      # Title
      title = list(
        div(
          id = "title-container",
          h2(id = "title", "tenzing"),
          h4(id = "sub-title", "Documenting contributorship with CRediT")
          )
        ),
      # Tenzing tab
      tabPanel(
        "tenzing",
        column(2),
        column(8,
               # First step
               div(
                 class = "main-steps-container",
                 div(
                   class = "main-steps-title-container",
                   h1("1.",
                      class = "main-steps-title-number"),
                   h3("Create your contributors table",
                      class = "main-steps-title"),
                   div(
                     class = "help-icon-container",
                     title = "Copy the contributors table template in Google Drive. Go to File -> Make a copy",
                     fontawesome::fa_i(name = "fas fa-circle-question", style = "color: #D45F68; font-size: 2em;")
                     )
                   ),
                 wellPanel(
                   class = "main-steps-panel",
                   tags$p("Duplicate and edit the ",
                          style = "display: inline; margin-bottom: 0;"),
                   tags$a(href = "https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing",
                          "contributors table template",
                          target="_blank",
                          style = "display: inline; color: #ffdf57; text-decoration: underline;",
                          class = "link")
                   )
                 ),
               # Second step
               div(
                 class = "main-steps-container",
                 div(
                   class = "main-steps-title-container",
                   h1("2.",
                      class = "main-steps-title-number"),
                   h3("Load your contributors table",
                      class = "main-steps-title"),
                   div(
                     class = "help-icon-container",
                     title = "Use the share URL of the filled out contributors table and click on the upload button. OR upload your contributors table in a .csv, .tsv or .xlsx format.",
                     fontawesome::fa_i(name = "fas fa-circle-question", style = "color: #D45F68; font-size: 2em;")
                     )
                   ),
                 wellPanel(
                   class = "main-steps-panel",
                   mod_read_spreadsheet_ui("read_spreadsheet"),
                   mod_show_spreadsheet_ui("show_spreadsheet")
                   )
                 ),
               # Third step
               div(
                 class = "main-steps-container",
                 div(
                   class = "main-steps-title-container",
                   h1("3.",
                      class = "main-steps-title-number"),
                   h3("Download the output",
                      class = "main-steps-title"),
                   div(
                     class = "help-icon-container",
                     title = "You need a valid contributors table to generate the outputs. Once you have it, click on one of the output buttons to preview and download the output.",
                     fontawesome::fa_i(name = "fas fa-circle-question", style = "color: #D45F68; font-size: 2em;")
                     )
                   ),
                 wellPanel(
                   class = "main-steps-panel",
                   mod_credit_roles_ui("credit_roles"),
                   mod_title_page_ui("title_page"),
                   mod_xml_report_ui("xml_report"),
                   mod_show_yaml_ui("show_yaml"),
                   mod_funding_information_ui("funding_information"),
                   mod_conflict_statement_ui("conflict_statement")
                   )
                 ),
               # Citation
               HTML(
               "<p><b>Citation:</b></br>
               Kovacs, M., Holcombe, A., Aust, F., & Aczel, B. (2021). <a href='https://doi.org/10.3233/ISU-210109'; target='_blank'; class='link'>Tenzing and the importance of tool development for research efficiency.</a> <i>Information Services & Use, 41</i>, 123-130.
               <BR>
               Holcombe, A. O., Kovacs, M., Aust, F., & Aczel, B. (2020). <a href='https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0244611'; target='_blank'; class='link'>Documenting contributions to scholarly articles using CRediT and tenzing.</a> <i>PLOS ONE, 15</i>(12), e0244611.</p>"
                    ),
               # Privacy notice
               HTML("<p><b>Privacy:</b><BR>
                    To get a sense of how many users we have, we log a masked version of IP addresses. You are not identifiable by the logged information.</p>")
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
  
  addResourcePath(
    'www', system.file('app/www', package = 'tenzing')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon(ext = "png"),
    # Add sweetalert2 JS library
    tags$script(src = "https://cdn.jsdelivr.net/npm/sweetalert2@9.14.0/dist/sweetalert2.all.min.js"),
    # Add custom css stylesheet
    tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css"),
    # Add custom JS functions
    tags$script(src = "www/sweet_alert.js"),
    # Change window title
    tags$script("document.title = 'tenzing';"),
    tags$script(src = "www/tooltip.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/prism.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/components/prism-yaml.min.js"),
    tags$link(rel = "stylesheet", type = "text/css",
              href = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/themes/prism.min.css"),
    # Matomo analytics
    # includeHTML(app_sys("app/www/usage_tracker.html"))
    HTML("<script>
  var _paq = window._paq = window._paq || [];
  _paq.push(['disableCookies']);
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u='https://tenzingclub.matomo.cloud/';
    _paq.push(['setTrackerUrl', u+'matomo.php']);
    _paq.push(['setSiteId', '1']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.async=true; g.src='//cdn.matomo.cloud/tenzingclub.matomo.cloud/matomo.js'; s.parentNode.insertBefore(g,s);
  })();
</script>")
  )
}
