# UI Fragment Components
# 
# Reusable UI components extracted from app_ui.R for better maintainability.
# All UI text is kept inline within functions for easier editing.

#' Create a help icon widget
#' 
#' @param help_text Tooltip text to display
#' @return HTML tag for help icon
ui_help_icon <- function(help_text) {
  div(
    class = "help-icon-container",
    title = help_text,
    fontawesome::fa_i(name = "fas fa-circle-question", style = "color: #D45F68; font-size: 2em;")
  )
}

#' Create a step panel
#' 
#' @param number Step number (1, 2, or 3)
#' @param title Step title text
#' @param help_text Help text for tooltip
#' @param content Panel content (UI elements)
#' @return HTML tag for step panel
ui_step_panel <- function(number, title, help_text, content) {
  div(
    class = "main-steps-container",
    div(
      class = "main-steps-title-container",
      h1(
        paste0(number, "."),
        class = "main-steps-title-number"
      ),
      h3(
        title,
        class = "main-steps-title"
      ),
      ui_help_icon(help_text)
    ),
    wellPanel(
      class = "main-steps-panel",
      content
    )
  )
}

#' Create citation section
#' 
#' Citation HTML is kept inline for easy editing.
#' 
#' @return HTML tag for citation section
ui_citation_section <- function() {
  HTML(
    "<p><b>Citation:</b></br>
    Kovacs, M., Holcombe, A., Aust, F., & Aczel, B. (2021). <a href='https://doi.org/10.3233/ISU-210109'; target='_blank'; class='link'>Tenzing and the importance of tool development for research efficiency.</a> <i>Information Services & Use, 41</i>, 123-130.
    <BR>
    Holcombe, A. O., Kovacs, M., Aust, F., & Aczel, B. (2020). <a href='https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0244611'; target='_blank'; class='link'>Documenting contributions to scholarly articles using CRediT and tenzing.</a> <i>PLOS ONE, 15</i>(12), e0244611.</p>"
  )
}

#' Create privacy notice section
#' 
#' Privacy notice HTML is kept inline for easy editing.
#' 
#' @return HTML tag for privacy notice
ui_privacy_notice <- function() {
  HTML(
    "<p><b>Privacy:</b><BR>
    To get a sense of how many use tenzing, we log a masked version of IP addresses. You are not identifiable by the logged information.</p>"
  )
}

#' Create navbar header
#' 
#' @return HTML tag for navbar header
ui_navbar_header <- function() {
  tagList(
    div(
      id = "support-div",
      a(
        id = "support-btn",
        class = "btn",
        href = "https://opencollective.com/tenzing",
        target = "_blank",
        "Support us"
      )
    )
  )
}

#' Create app title section
#' 
#' @return HTML tag for app title
ui_app_title <- function() {
  list(
    div(
      id = "title-container",
      h2(id = "title", "tenzing"),
      h4(id = "sub-title", "Documenting contributorship with CRediT")
    )
  )
}

