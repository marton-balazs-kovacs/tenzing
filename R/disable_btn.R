# TODO: Solve this with remove and add class
disable_btn <- function(trigger, btn_id_shiny, btn_id_css) {
  if(trigger){
    shinyjs::enable(btn_id_shiny)
    shinyjs::runjs("$('#dwnbutton1').removeAttr('title');")
  } else{
    shinyjs::disable(btn_id_shiny)
    shinyjs::runjs("$('#dwnbutton1').attr('title', 'Please upload the infosheet');")
  }
}