#' Read the filled out contributors_table
#' 
#' This function reads the `contributors_table` given the path if the
#' file is a csv, tsv or an xlsx. The function can read
#' googlesheets if share url is provided or local files if
#' path to the local folder is provided.
#' 
#' @section Warning:
#' If the file is an xlsx the function only reads the first sheet.
#' 
#' @param contributors_table_path the full path to the file with extension
#' @export
#' @return The function returns the contributors table as
#' a dataframe.
read_contributors_table <- function(contributors_table_path) {
  # Extract file extension
  ext <- tools::file_ext(contributors_table_path)
  if (grepl("https", contributors_table_path)) ext ="web"
  
  # Read contributors_table based on the extension
  contributors_table <- switch(ext,
                      csv = vroom::vroom(contributors_table_path, delim = ","),
                      tsv = vroom::vroom(contributors_table_path, delim = "\t"),
                      xlsx = readxl::read_xlsx(contributors_table_path, sheet = 1),
                      web = googlesheets4::range_read(contributors_table_path, sheet = 1),
                      stop("Invalid file; Please upload a .csv, a .tsv or a .xlsx file. Or provide a valid URL to the spreadsheet."))
  
  return(contributors_table)
}

#' Delete empty rows of the contributors_table
#' 
#' The function deletes any additional rows where all
#' of the name columns are empty.
#' 
#' @param contributors_table the imported contributors_table
#' @export
#' @return The function returns the contributors_table
#' without empty additional rows.
#' 
#' @importFrom rlang .data
#' @importFrom utils globalVariables
clean_contributors_table <- function(contributors_table) {
  
  contributors_table %>%
    tibble::as_tibble() %>%
    dplyr::filter_at(
      dplyr::vars(.data$Firstname, .data$`Middle name`, .data$Surname),
      dplyr::any_vars(!is.na(.))
      )
}
