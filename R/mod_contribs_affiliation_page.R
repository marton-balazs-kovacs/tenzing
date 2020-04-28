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
    downloadButton(
      NS(id, "report"),
      label = "Generate author list with affiliations",
      class = "btn btn-primary")
  )
}
    
# Module Server
    
#' @rdname mod_contribs_affiliation_page
#' @export
#' @keywords internal
    
mod_contribs_affiliation_page_server <- function(id, input_data, uploaded){
  
  moduleServer(id, function(input, output, session) {

    # Disable download button if the gs is not printed
    observe({
      if(!is.null(uploaded())){
        shinyjs::enable("report")
      } else{
        shinyjs::disable("report")
      }
    })
    
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
    contrib_data <- reactive(
      
      contrib_affil_data() %>% 
        dplyr::select(-affiliation) %>% 
        tidyr::spread(key = affiliation_type, value = affiliation_no)
      
    )
    
    # Modify data for printing the affiliations
    affil_data <- reactive(
      
      contrib_affil_data() %>% 
        dplyr::select(affiliation_no, affiliation) %>% 
        tidyr::drop_na(affiliation) %>% 
        dplyr::distinct(affiliation, .keep_all = TRUE)
      
    )
    
    # Render output Rmd
    output$report <- downloadHandler(
      
      filename = function() {
        paste("contributors_affiliation_", Sys.Date(), ".html", sep="")
      },
      content = function(file) {
        
        # Copy the report file to a temporary directory before processing it, in
        # case we don't have write permissions to the current working dir (which
        # can happen when deployed)
        tempReport <- file.path("inst/app/www/", "contribs_affiliation.Rmd")
        file.copy("contribs_affiliation.Rmd", tempReport, overwrite = TRUE)
        
        # Set up parameters to pass to Rmd document
        params <- list(param_1 = contrib_data(),
                       param_2 = affil_data())
        
        # Knit the document, passing in the `params` list, and eval it in a
        # child of the global environment (this isolates the code in the document
        # from the code in this app).
        rmarkdown::render(tempReport, output_file = file, params = params)
      }
    )
  })
}
    
## To be copied in the UI
# mod_contribs_affiliation_page_ui("contribs_affiliation_page_ui_1")
    
## To be copied in the server
# mod_contribs_affiliation_page_server("contribs_affiliation_page_ui_1")
 
