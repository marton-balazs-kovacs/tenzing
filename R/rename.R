#' Functions renamed in tenzing 0.2.0
#' 
#' @description
#' `r lifecycle::badge('deprecated')`
#' 
#' In `tenzing 0.2.0` we renamed the `infosheet` to `contributors_table`
#' in all functions, arguments, and documentation as the new name
#' better conveys the content and functionality of the table. We also
#' renamed some other functions as well because of the same reason.
#' 
#' * `validate_infosheet` -> `validate_contributors_table`
#' * `read_infosheet` -> `read_contributors_table`
#' * `infosheet_template` -> `contributors_table_template`
#' * `clean_infosheet` -> `clean_contributors_table`
#' * `print_roles_readable` -> `print_credit_roles`
#' * `print_contrib_affil` -> `print_title_page`
#' 
#' @keywords internal
#' @importFrom lifecycle deprecated
#' @name rename
#' @aliases NULL
NULL

#' @rdname rename
#' @export
validate_infosheet <- function(infosheet = deprecated()) {
  lifecycle::deprecate_warn("0.2.0", "validate_infosheet()", "validate_contributors_table()")
  
  if (lifecycle::is_present(infosheet)) {
    lifecycle::deprecate_warn("0.2.0", "validate_infosheet(infosheet)", "validate_contributors_table(contributors_table)")
    contributors_table <- infosheet
  }
  
  validate_contributors_table(contributors_table = contributors_table)
}

#' @rdname rename
#' @export
read_infosheet <- function(infosheet_path = deprecated()) {
  lifecycle::deprecate_warn("0.2.0", "read_infosheet()", "read_contributors_table()")
  
  if (lifecycle::is_present(infosheet_path)) {
    lifecycle::deprecate_warn("0.2.0", "read_infosheet(infosheet_path)", "read_contributors_table(contributors_table_path)")
    contributors_table_path <- infosheet_path
  }
  
  read_contributors_table(contributors_table_path = contributors_table_path)
}

#' @rdname rename
#' @export
clean_infosheet <- function(infosheet = deprecated()) {
  lifecycle::deprecate_warn("0.2.0", "clean_infosheet()", "clean_contributors_table()")
  
  if (lifecycle::is_present(infosheet)) {
    lifecycle::deprecate_warn("0.2.0", "clean_infosheet(infosheet)", "clean_contributors_table(contributors_table)")
    contributors_table <- infosheet
  }
  
  clean_contributors_table(contributors_table = contributors_table)
}

#' @rdname rename
#' @export
print_roles_readable <- function(infosheet = deprecated()) {
  lifecycle::deprecate_warn("0.2.0", "print_roles_readable()", "print_credit_roles()")
  
  if (lifecycle::is_present(infosheet)) {
    lifecycle::deprecate_warn("0.2.0", "print_roles_readable(infosheet)", "print_credit_roles(contributors_table)")
    contributors_table <- infosheet
  }
  
  print_credit_roles(contributors_table = contributors_table)
}

#' @rdname rename
#' @export
print_contrib_affil <- function(infosheet = deprecated()) {
  lifecycle::deprecate_warn("0.2.0", "print_contrib_affil()", "print_title_page()")
  
  if (lifecycle::is_present(infosheet)) {
    lifecycle::deprecate_warn("0.2.0", "print_contrib_affil(infosheet)", "print_title_page(contributors_table)")
    contributors_table <- infosheet
  }
  
  print_title_page(contributors_table = contributors_table)
}