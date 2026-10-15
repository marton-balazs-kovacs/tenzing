#' Keep only authors
#'
#' Drops contributors marked as "Acknowledgment only" (or anything else that is
#' not "Author", including blank values) in the `Author/Acknowledgee` column.
#' Tables without that column are returned unchanged for backward compatibility.
#'
#' @param contributors_table A contributors_table.
#' @param require_authors Logical. If `TRUE`, stop with an error when no authors
#'   remain. Use this in outputs that cannot be generated without authors.
#'
#' @return The contributors_table restricted to authors.
#' @noRd
filter_authors <- function(contributors_table, require_authors = FALSE) {
  if ("Author/Acknowledgee" %in% names(contributors_table)) {
    contributors_table <- contributors_table[
      contributors_table$`Author/Acknowledgee` %in% "Author", , drop = FALSE]
  }
  
  if (require_authors && nrow(contributors_table) == 0) {
    stop("No authors found in the contributors_table.")
  }
  
  contributors_table
}

#' Keep only acknowledgees
#'
#' Keeps contributors marked as "Acknowledgment only" in the
#' `Author/Acknowledgee` column. Tables without that column have no
#' acknowledgees (all rows are treated as authors), so zero rows are returned.
#'
#' @param contributors_table A contributors_table.
#'
#' @return The contributors_table restricted to acknowledgees.
#' @noRd
filter_acknowledgees <- function(contributors_table) {
  if (!"Author/Acknowledgee" %in% names(contributors_table)) {
    return(contributors_table[0, , drop = FALSE])
  }
  
  contributors_table[
    contributors_table$`Author/Acknowledgee` %in% "Acknowledgment only", , drop = FALSE]
}
