# Module UI
  
#' @title   mod_human_readable_report_ui and mod_human_readable_report_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_human_readable_report
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_human_readable_report_ui <- function(id){

  tagList(
    downloadButton(NS(id, "report"), "Generate author contributions text")
  )
}
    
# Module Server
    
#' @rdname mod_human_readable_report
#' @export
#' @keywords internal
    
mod_human_readable_report_server <- function(id, input_data, submit){
  
  moduleServer(id, function(input, output, session) {
    
    # Disable download button if the gs is not printed
    observe({
      if(submit() && !is.null(input_data())){
        shinyjs::enable("report")
      } else{
        shinyjs::disable("report")
      }
    })
    
    # Restructure dataframe for the human readable output
    human_readable_data <- reactive(
      
      input_data() %>% 
        dplyr::mutate(Name = dplyr::if_else(is.na(`Middle name`),
                              paste(Firstname, Surname),
                              paste(Firstname, `Middle name`, Surname))) %>% 
        dplyr::select(Name,
                      dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>%  
        tidyr::gather(key = "CRediT Taxonomy", value = "Included", -Name) %>% 
        dplyr::filter(Included == TRUE) %>% 
        dplyr::select(-Included) %>% 
        dplyr::group_by(`CRediT Taxonomy`) %>% 
        dplyr::summarise(Names = stringr::str_c(Name, collapse = ", "))
      
    )
    
    # Render output Rmd
    output$report <- downloadHandler(
      
      filename = function() {
        paste("human_readable_report_", Sys.Date(), ".html", sep="")
      },
      content = function(file) {
        
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed)
        tempReport <- file.path("inst/app/www/", "human_readable_report.Rmd")
        file.copy("human_readable_report.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(param_1 = human_readable_data())
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file, params = params)
      }
    )
  })
}
    
## To be copied in the UI
# mod_human_readable_report_ui("human_readable_report_ui_1")
    
## To be copied in the server
# mod_human_readable_report_server("human_readable_report_ui_1")
 
