#' Generate an XML document of the contributions
#' 
#' The function generates an XML nodeset that contains the contributors' name,
#' affiliation, and their CRediT roles with a structure outlined in the
#' JATS 1.2 DTD specifications (eLife). The output is generated from an 
#' `contributors_table` validated with the \code{\link{validate_contributors_table}} function.
#' The `contributors_table` must be based on the \code{\link{contributors_table_template}}.
#' 
#' @section Warning:
#' The function is primarily developed to be the part of a shiny app. As the
#'   validation is handled inside of the app separately, the function can
#'   break with non-informative errors if running locally without first
#'   validating it.
#'   
#' @family output functions
#'
#' @param contributors_table validated contributors_table
#' 
#' @return The function returns an xml nodeset containing the contributors
#'   listed for each CRediT role they partake in.
#' @export
#' @examples 
#' example_contributors_table <- read_contributors_table(
#' contributors_table = system.file("extdata",
#' "contributors_table_example.csv", package = "tenzing", mustWork = TRUE))
#' validate_contributors_table(contributors_table = example_contributors_table)
#' print_xml(contributors_table = example_contributors_table)
#' 
#' @importFrom rlang .data
print_xml <-  function(contributors_table) {
  # Defining global variables
  . = NULL
  
  # Prepare the contributors_table data
  contrib_data <- 
    contributors_table %>%
      abbreviate_middle_names_df() %>%
      dplyr::mutate(`Given-names` = dplyr::if_else(is.na(.data$`Middle name`),
                                                   .data$Firstname,
                                                   paste(.data$Firstname, .data$`Middle name`))) %>% 
      dplyr::select(.data$`Given-names`,
                    .data$Surname,
                    dplyr::pull(credit_taxonomy, .data$`CRediT Taxonomy`)) %>%
      tidyr::gather(key = "CRediT Taxonomy", value = "Included",
                    -.data$`Given-names`, -.data$Surname) %>%
      dplyr::filter(.data$Included == TRUE) %>%
      dplyr::select(-.data$Included) %>%
      dplyr::mutate(group_id = dplyr::group_indices(., .data$Surname, .data$`Given-names`)) %>%
      dplyr::left_join(., credit_taxonomy, by = "CRediT Taxonomy")
  
  # Generate XML document
  contrib_group(contrib_data = contrib_data)
}

#' Function to create the XML document
#' 
#' This function generates an XML document from the preformatted
#' `contributors_table`.
#' 
#' @param contrib_data preformatted contributors_table
#' 
#' @return The function returns an XML document from the contributors
#' table formatted according the JATS 1.2 DTD specifications.
contrib_group <- function(contrib_data) {
  # Create a new XML root
  root <- xml2::xml_new_root(.value = "contrib-group")
  
  # Create a function with the structure of the JATS 1.2 DTD specifications (eLife) for the affiliation, author and contribution information
  # Idea from: https://stackoverflow.com/questions/44635312/how-do-i-use-an-r-for-loop-to-repeatedly-fill-out-template-with-each-loop-using
  
  for (i in 1:length(unique(contrib_data$group_id))) {
    # Temporarily save the data of one contributor
    contributor <- dplyr::filter(contrib_data, .data$group_id == i)
    
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
                              `vocab-identifier` = "http://credit.niso.org/contributor-roles/",
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
