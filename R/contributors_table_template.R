#' Template for the contributors table
#' 
#' Dataset that represents the data structure that the tenzing
#' package functions require to run without error. The dataset
#' is filled with example values and based on the online spreadsheet
#' provided in the shiny app.
#' 
#' @section Remark:
#'   Each row contains the contributorship information for
#'   one contributor. In the template there are 3 contributors
#'   added as an example but there is no limit to the number
#'   of contributors while using the package.
#' 
#' @format A dataframe with 3 rows and 22 variables:
#' \describe{
#'   \item{'Author/Acknowledgee'}{character, whether the contributor is an 'Author', 'Acknowledgment only', or 'Don't agree to be named'}
#'   \item{'Order in publication'}{numeric, used to order the contributors for all outputs, shared first authorship is allowed}
#'   \item{Firstname}{character, first name of the contributor, must be provided}
#'   \item{'Middle name'}{character, middle name of the contributor, blank if not applicable}
#'   \item{Surname}{character, surname of the contributor, must be provided}
#'   \item{Conceptualization}{logical, CREdiT role}
#'   \item{'Data curation'}{logical, CREdiT role}
#'   \item{'Formal analysis'}{logical, CREdiT role}
#'   \item{'Funding acquisition'}{logical, CREdiT role}
#'   \item{Investigation}{logical, CREdiT role}
#'   \item{Methodology}{logical, CREdiT role}
#'   \item{'Project administration'}{logical, CREdiT role}
#'   \item{Resources}{logical, CREdiT role}
#'   \item{Software}{logical, CREdiT role}
#'   \item{Supervision}{logical, CREdiT role}
#'   \item{Validation}{logical, CREdiT role}
#'   \item{Visualization}{logical, CREdiT role}
#'   \item{'Writing - original draft'}{logical, CREdiT role}
#'   \item{'Writing - review & editing'}{logical, CREdiT role}
#'   \item{Note}{character, optional comments for the contributor}
#'   \item{'Email address'}{character, email address of the correspondign author, optional}
#'   \item{'Affiliation 1'}{character, primary affiliation of the contributor}
#'   \item{'Affiliation 2'}{character, secondary affiliation of the contributor, blank if not applicable}
#'   \item{'Affiliation 3'}{character, tertiary affiliation of the contributor, blank if not applicable, more affiliation columns can be added following the "Affiliation {n}" pattern}
#'   \item{Funding}{character, name of the funds, blank if not applicable}
#'   \item{ORCID iD}{character, ORCID iD of the contributor}
#'   \item{'Corresponding author?'}{logical, TRUE for contributor who is the corresponding author, multiple corresponding authors are allowed}
#'   \item{'Declares'}{character, conflict of interest statement of the contributor}
#'}
#'@source <https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing>
"contributors_table_template"
