#' Run the Shiny Application
#' 
#' This function allows users to run the application
#' locally from their computer.
#' 
#' @param ... Allows user to pass global arguments to the app on runtime
#' 
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(...) {
  with_golem_options(
    app = shinyApp(ui = app_ui, server = app_server), 
    golem_opts = list(...)
  )
}
