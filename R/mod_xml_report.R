# Module UI
  
#' @title   mod_xml_report_ui and mod_xml_report_server
#' @description  A shiny Module.
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#'
#' @rdname mod_xml_report
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_xml_report_ui <- function(id){

  tagList(
    div(id = "dwnbutton3",
        downloadButton(NS(id, "report"),
                       label = "Generate XML file (for publisher use)",
                       class = "btn btn-primary",
                       disabled = "disabled")
        )
    )
  }
    
# Module Server
    
#' @rdname mod_xml_report
#' @export
#' @keywords internal
    
mod_xml_report_server <- function(id, input_data, valid_infosheet){
  
  moduleServer(id, function(input, output, session) {
   
     # Disable download button if the gs is not printed
    observe({
      if(!is.null(valid_infosheet())){
        shinyjs::enable("report")
        shinyjs::runjs("$('#dwnbutton3').removeAttr('title');")
      } else{
        shinyjs::disable("report")
        shinyjs::runjs("$('#dwnbutton3').attr('title', 'Please upload the infosheet');")
      }
    })
    
    # Prepare the spreadsheet data
    contrib_data <- reactive(
      
      input_data() %>%
        dplyr::mutate(`Given-names` = dplyr::if_else(is.na(`Middle name`),
                                       Firstname,
                                       paste(Firstname, `Middle name`))) %>% 
        dplyr::select(`Given-names`,
               Surname,
               dplyr::pull(credit_taxonomy, `CRediT Taxonomy`)) %>%
        tidyr::gather(key = "CRediT Taxonomy", value = "Included", -`Given-names`, -Surname) %>%
        dplyr::filter(Included == TRUE) %>%
        dplyr::select(-Included) %>%
        dplyr::mutate(group_id = dplyr::group_indices(., Surname, `Given-names`)) %>%
        dplyr::left_join(., credit_taxonomy, by = "CRediT Taxonomy")
      
    )
    
    # Create a new xml document
    contrib_group <- reactive({
      
      temp <- xml2::xml_new_root(.value = "contrib-group")
      
      # Create a function with the srtucture of the JATS 1.2 DTD specifications (eLife) for the affiliation, author and contribution information
      # Idea from: https://stackoverflow.com/questions/44635312/how-do-i-use-an-r-for-loop-to-repeatedly-fill-out-template-with-each-loop-using
      
      for(i in 1:length(unique(contrib_data()$group_id))){
        
        # Temporarily save the data of one contributor
        contributor <- contrib_data() %>%
          dplyr::filter(group_id == i)
        
        # Save the name of the chosen contributor
        surname <- unique(contributor$Surname)
        given_names <- unique(contributor$`Given-names`)
        
        # Create a node for each contributor
        contributor_node <- xml2::xml_new_root(.value = "contrib")
        
        # Add a name child node to the contributor
        contributor_node %>%
          xml2::xml_add_child(xml2::xml_new_root(.value = "name")) %>%
          xml2::xml_set_attrs(c(surname = surname,
                          `given-names` = given_names))
        
        for(i in 1:nrow(contributor)){
          
          # Save each credit taxonomy statement
          credit_taxonomy_statement <- contributor$`CRediT Taxonomy`[i]
          credit_url <- contributor$url[i]
          
          # Create a role node for each credit statement
          role <- xml2::xml_new_root(.value = "role")
          
          # Set the attributes of the role
          role %>%
            xml2::xml_set_attrs(c(vocab = "credit",
                            `vocab-identifier` = "http://dictionary.casrai.org/Contributor_Roles",
                            `vocab-term` = credit_taxonomy_statement,
                            `vocab-term-identifier` = credit_url))
          
          # Add the role to the contributor node as a child
          contributor_node %>%
            xml2::xml_add_child(role)
          
        }
        
        # Add the contributor node to the contributor group node
        temp %>%
          xml2::xml_add_child(contributor_node)
        
      }
      
      return(temp)
      
    })
    
    # Render output Rmd
    output$report <- downloadHandler(
      
      # Set filename
      filename = function() {
        paste("machine_readable_report_", Sys.Date(), ".xml", sep = "")
      },
      
      # Set content of the file
      content = function(file) {
        xml2::write_xml(contrib_group(), file, options = "format")}
      )
    })
}
    
## To be copied in the UI
# mod_xml_report_ui("xml_report_ui_1")
    
## To be copied in the server
# mod_xml_report_server("xml_report_ui_1")
 
