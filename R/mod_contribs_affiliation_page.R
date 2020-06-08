# Module UI
  
#' @title   mod_contribs_affiliation_page_ui and mod_contribs_affiliation_page_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_contribs_affiliation_page
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_contribs_affiliation_page_ui <- function(id){

  tagList(
    div(class = "out-btn",
        actionButton(
          NS(id, "show_report"),
          label = "Show author list with affiliations",
          class = "btn btn-primary")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_contribs_affiliation_page
#' @export
#' @keywords internal
    
mod_contribs_affiliation_page_server <- function(id, input_data){
  
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    waitress <- waiter::Waitress$new(theme = "overlay", infinite = TRUE)

    # Restructure dataframe for the contributors affiliation output
    contrib_affil_data <- reactive(
      input_data() %>% 
        dplyr::mutate(`Middle name` = dplyr::if_else(is.na(`Middle name`),
                                       NA_character_,
                                       paste0(stringr::str_sub(`Middle name`, 1, 1), ".")),
               Names = dplyr::if_else(is.na(`Middle name`),
                               paste(Firstname, Surname),
                               paste(Firstname, `Middle name`, Surname))) %>% 
        dplyr::select(`Order in publication`, Names, `Primary affiliation`, `Secondary affiliation`) %>%
        tidyr::gather(key = "affiliation_type", value = "affiliation", -Names, -`Order in publication`) %>% 
        dplyr::arrange(`Order in publication`) %>% 
        dplyr::mutate(affiliation_no = dplyr::case_when(!is.na(affiliation) ~ dplyr::group_indices(., factor(affiliation, levels = unique(affiliation))),
                                          is.na(affiliation) ~ NA_integer_))
    )
    
    # Modify data for printing contributor information
    contrib_data <- reactive({
      data <- 
        contrib_affil_data() %>% 
        dplyr::select(-affiliation) %>% 
        tidyr::spread(key = affiliation_type, value = affiliation_no)
      
      # Based on: https://stackoverflow.com/questions/36674824/use-loop-to-generate-section-of-text-in-rmarkdown
      # Add contributors and their affiliation id two the C-style formatted tempaltes
      paste_contrib_data <- function(a, b, c){
        if(is.na(c)){
          sprintf("%s^%d^", a, b)
        } else{
          sprintf("%s^%d,%d^", a, b, c)
        }
      }
      
      # Iterate through each contributor and add them to the templates
      contrib_print <-
        data %>% 
        dplyr::transmute(contrib = purrr::pmap_chr(.l = list(Names, `Primary affiliation`, `Secondary affiliation`),
                                                   .f = paste_contrib_data)) %>% 
        dplyr::pull(contrib)
      
      # Paste and print the corresponding statement and names
      stringr::str_c(contrib_print, collapse = ", ")
    })
    
    # Modify data for printing the affiliations
    affil_data <- reactive({
      affil_print <- contrib_affil_data() %>% 
        dplyr::select(affiliation_no, affiliation) %>% 
        tidyr::drop_na(affiliation) %>% 
        dplyr::distinct(affiliation, .keep_all = TRUE) %>% 
        # Iterate through each affiliation and add them to the C-style template
        dplyr::transmute(affil = purrr::map2_chr(affiliation_no, affiliation,
                                                 ~ sprintf("^%d^%s", .x, .y))) %>% 
        dplyr::pull(affil)
      
      # Paste and print the affiliations and the corresponding numbers
      stringr::str_c(affil_print, collapse = ", ")
    })
    
    # Set up parameters to pass to Rmd document
    params <- reactive({
      list(contrib_data = contrib_data(),
           affil_data = affil_data())
    })
    
    report_path <- reactive({
      file_path <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
      file.copy("contribs_affiliation.Rmd", file_path, overwrite = TRUE)
      tempReportRender <- tempfile(fileext = ".html")

      callr::r(
        render_report,
        list(input = file_path, output = tempReportRender, format = "html_document", params = params())
      )
      
      tempReportRender
    })
    
    # Render output Rmd
    output$report <- downloadHandler(
      filename = function() {
        paste0("contributors_affiliation_", Sys.Date(), ".doc")
      },
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed)
        file_path <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
        file.copy("contribs_affiliation.Rmd", file_path, overwrite = TRUE)

        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        callr::r(
          render_report,
          list(input = file_path, output = file, format = "word_document", params = params())
        )
      }
    )
    
    to_clip <- reactive({
      paste(contrib_data(), affil_data(), sep = "/n")
    })
    
    # Add clipboard buttons
    output$clip <- renderUI({
      rclipboard::rclipButton("clip_btn", "Copy output to clipboard", to_clip(), icon("clipboard"), modal = TRUE)
    })
    
    ## Workaround for execution within RStudio version < 1.2
    observeEvent(input$clip_btn, clipr::write_clip(report_path()))
    
    # Build modal
    modal <- function() {
      modalDialog(
        rclipboard::rclipboardSetup(),
        includeHTML(report_path()),
        easyClose = TRUE,
        footer = tagList(
          div(
            style = "display: inline-block",
            uiOutput(session$ns("clip"))
          ),
          downloadButton(
            NS(id, "report"),
            label = "Download file"
          ),
          modalButton("Close")
        )
      )
    }
    
    observeEvent(input$show_report, {
      waitress$notify()
      showModal(modal())
      waitress$close()
      })
  })
}
    
## To be copied in the UI
# mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1")
    
## To be copied in the server
# mod_contribs_affiliation_page_server("contribs_affiliation_page_ui_1")
 
