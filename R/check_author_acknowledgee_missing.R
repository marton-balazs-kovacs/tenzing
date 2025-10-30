#' Warn when 'Author/Acknowledgee' column is missing
#'
#' Emits a single warning informing users that, when the column is absent,
#' the app treats all rows as authors and that adding the column enables
#' a separate acknowledgee statement.
#'
#' @param contributors_table A dataframe of contributors.
#' @param context Optional named list (unused).
#' @return A standardized validation result list.
#' @export
check_author_acknowledgee_missing <- function(contributors_table, context = NULL) {
  if ("Author/Acknowledgee" %in% names(contributors_table)) {
    return(validation_success("'Author/Acknowledgee' column is present."))
  }
  validation_warning(
    "Column 'Author/Acknowledgee' is missing; all rows are treated as authors. Add this column to generate a separate acknowledgee statement."
  )
}


