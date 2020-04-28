# Module UI
  
#' @title   mod_about_modal_ui and mod_about_modal_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_about_modal
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_about_modal_ui <- function(id){
  
  tagList(
      shinyWidgets::actionBttn(inputId = NS(id, "open_about"),
                               label = "About",
                               style = "bordered",
                               color = "primary",
                               size = "md")
  )
}
    
# Module Server
    
#' @rdname mod_about_modal
#' @export
#' @keywords internal
    
mod_about_modal_server <- function(id){
  moduleServer(id, function(input, output, session) {
    modal <- function() {
      
      modalDialog(
        easyClose = TRUE,
        footer = modalButton("Close"),
        includeMarkdown("inst/app/www/about.Rmd"))
    }
    
    observeEvent(input$open_about, {
      showModal(modal())})
  })
}
    
## To be copied in the UI
# mod_about_modal_ui("about_modal_ui_1")
    
## To be copied in the server
# mod_about_modal_server("about_modal_ui_1")
 
