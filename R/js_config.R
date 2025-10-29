#' JavaScript Resource Configuration
#' 
#' Functions for managing JavaScript resources and external libraries.
#'
#' @keywords internal
#' @noRd
#' @importFrom shiny tagList tags HTML addResourcePath

#' Add external JavaScript libraries
#' 
#' Adds SweetAlert2 and Prism.js libraries.
#' 
#' @return HTML tags for JavaScript libraries
add_js_libraries <- function() {
  tagList(
    # SweetAlert2
    tags$script(src = "https://cdn.jsdelivr.net/npm/sweetalert2@9.14.0/dist/sweetalert2.all.min.js"),
    # Prism.js (code syntax highlighting)
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/prism.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/components/prism-yaml.min.js"),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/themes/prism.min.css"
    )
  )
}

#' Add custom JavaScript files
#' 
#' Adds application-specific JavaScript files.
#' 
#' @return HTML tags for custom JavaScript files
add_custom_js_files <- function() {
  tagList(
    tags$script(src = "www/sweet_alert.js"),
    tags$script(src = "www/tooltip.js"),
    tags$script(src = "www/custom.js"),
    tags$script(src = "www/collapsible.js"),
    tags$script(src = "www/update_card_styles.js"),
    # Change window title
    tags$script("document.title = 'tenzing';")
  )
}

#' Add CSS resources
#' 
#' Adds application CSS stylesheet.
#' 
#' @return HTML tags for CSS files
add_css_resources <- function() {
  tags$link(
    rel = "stylesheet",
    type = "text/css",
    href = "www/custom.css"
  )
}

#' Add analytics script
#' 
#' Adds Matomo analytics tracking script.
#' 
#' @return HTML tags for analytics script
add_analytics_script <- function() {
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
}

#' Setup resource paths
#' 
#' Sets up resource paths for www directory.
#' 
#' @return No return value, called for side effects
setup_resource_paths <- function() {
  addResourcePath(
    'www',
    system.file('app/www', package = 'tenzing')
  )
  invisible(NULL)
}

