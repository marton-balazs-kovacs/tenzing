#' Read the filled out infosheet
#' 
#' This function reads the infosheet given the path if the
#' file is a csv, tsv or an xlsx. The function can read
#' googlesheets if share url is provided or local files if
#' path to the local folder is provided.
#' 
#' @export
#' 
#' @section Warning:
#' If the file is an xlsx the function only reads the first sheet.
#' 
#' @param infosheet_path the full path to the file with extension
read_infosheet <- function(infosheet_path) {
  # Extract file extension
  ext <- tools::file_ext(infosheet_path)
  if (grepl("https", infosheet_path)) ext ="web"
  
  # Read infosheet based on the extension
  infosheet <- switch(ext,
                      csv = vroom::vroom(infosheet_path, delim = ","),
                      tsv = vroom::vroom(infosheet_path, delim = "\t"),
                      xlsx = readxl::read_xlsx(infosheet_path, sheet = 1),
                      web = googlesheets4::range_read(infosheet_path, sheet = 1),
                      stop("Invalid file; Please upload a .csv, a .tsv or a .xlsx file. Or provide a valid URL to the spreadsheet."))
  
  return(infosheet)
}

#' Delete empty rows of the infosheet
#' 
#' The function deletes any additional rows where all
#' of the name columns are empty.
#' 
#' @param infosheet the imported infosheet
#' 
#' @return sgllg
clean_infosheet <- function(infosheet) {
  infosheet %>%
    tibble::as_tibble() %>%
    dplyr::filter_at(
      dplyr::vars(Firstname, `Middle name`, Surname),
      dplyr::any_vars(!is.na(.)))
}
