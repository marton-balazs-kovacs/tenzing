#' Read the filled out infosheet
#' 
#' Then function reads the infosheet given the path if the
#' file is a csv, tsv or an xlsx.
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
  
  # Read infosheet based on the extension
  infosheet <- switch(ext,
                       csv = vroom::vroom(infosheet_path, delim = ","),
                       tsv = vroom::vroom(infosheet_path, delim = "\t"),
                       xlsx = readxl::read_xlsx(infosheet_path, sheet = 1),
                       stop("Invalid file; Please upload a .csv, a .tsv or a .xlsx file."))
  
  return(infosheet)
}