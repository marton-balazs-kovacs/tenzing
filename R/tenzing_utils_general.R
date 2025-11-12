#' Collapse a character vector with oxford comma
#' 
#' Collapses a character vector into a length 1 vector,
#' by using ", " as a separator and adding the oxford comma
#' if there original character vector length is longer than 3.
#' The function is from the cli package: https://github.com/jonocarroll/cli/blob/2d3fbc4b41327df82df1102cdfc0a5c99822809b/R/inline.R
#' 
#' @param x character, the vector to be collapsed
#' 
#' @return The function returns a vector of length 1.
#' 
#' @keywords internal
glue_oxford_collapse <- function(x) {
  if (length(x) >= 3) {
    glue::glue_collapse(x, sep = ", ", last = ", and ")
  } else {
    glue::glue_collapse(x, sep = ", ", last = " and ")
  }
}

#' Normalize ORCID ID to full URI format
#'
#' Converts ORCID IDs to the standard format:
#' https://orcid.org/0000-0002-1825-0097
#'
#' Handles various input formats:
#' - Just the ID: `"0000-0002-1825-0097"` -> `"https://orcid.org/0000-0002-1825-0097"`
#' - Already full URL: `"https://orcid.org/0000-0002-1825-0097"` -> unchanged
#' - HTTP instead of HTTPS: `"http://orcid.org/0000-0002-1825-0097"` -> `"https://orcid.org/0000-0002-1825-0097"`
#'
#' @param orcid_id character. ORCID ID in any format.
#'
#' @return character. Normalized ORCID ID(s) as full URI.
#'
#' @keywords internal
normalize_orcid_id <- function(orcid_id) {
  if (is.null(orcid_id)) {
    return(orcid_id)
  }
  
  # Preserve NA/empty values
  out <- orcid_id
  out <- stringr::str_trim(out)
  
  # Normalize URLs to ID portion
  has_prefix <- stringr::str_detect(out, "^https?://orcid\\.org/")
  out[has_prefix & !is.na(out)] <- stringr::str_replace(
    out[has_prefix & !is.na(out)],
    "^https?://orcid\\.org/",
    ""
  )
  
  # Remove trailing slash
  out <- stringr::str_replace(out, "/$", "")
  
  # Rebuild as HTTPS URIs, skipping NA / empty strings
  needs_uri <- !is.na(out) & out != ""
  out[needs_uri] <- paste0("https://orcid.org/", out[needs_uri])
  
  out
}


