#' Generate an XML document of the contributions
#' 
#' The function generates an XML nodeset that contains the contributors' name,
#' affiliation, and their CRediT roles with a structure outlined in the
#' JATS 1.2 DTD specifications (eLife). The output is generated from an 
#' infosheet validated with the \code{\link{validate_infosheet}} function.
#' The infosheet must be based on the \code{\link{infosheet_template}}.
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param infosheet validated infosheet
#' 
#' @return The function returns an xml nodeset containing the contributors
#'   listed for each CRediT role they partake in.
#' @export
#' @examples 
#' example_infosheet <- read_infosheet(infosheet = system.file("extdata", "infosheet_template_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_infosheet(infosheet = example_infosheet)
#' print_xml(infosheet = example_infosheet)
print_xml <-  function(infosheet) {
  # Prepare the infosheet data
  contrib_data <- 
    infosheet %>%
      abbreviate_middle_names_df() %>%
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
  
  # Function to create the XML document
  contrib_group <- function(x) {
    # Create a new XML root
    root <- xml2::xml_new_root(.value = "contrib-group")
    
    # Create a function with the structure of the JATS 1.2 DTD specifications (eLife) for the affiliation, author and contribution information
    # Idea from: https://stackoverflow.com/questions/44635312/how-do-i-use-an-r-for-loop-to-repeatedly-fill-out-template-with-each-loop-using
    
    for (i in 1:length(unique(x$group_id))) {
      # Temporarily save the data of one contributor
      contributor <- dplyr::filter(x, group_id == i)
      
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
      
      for (i in 1:nrow(contributor)) {
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
      root %>%
        xml2::xml_add_child(contributor_node)
    }
    
    return(root)
  }
  
  contrib_group(x = contrib_data)
}
