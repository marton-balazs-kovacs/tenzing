# Inverted versions of in, is.null and is.na
`%not_in%` <- Negate(`%in%`)

not_null <- Negate(is.null)

not_na <- Negate(is.na)

# Removes the null from a vector
drop_nulls <- function(x){
  x[!sapply(x, is.null)]
}

# If x is null, return y, otherwise return x
"%||%" <- function(x, y){
  if (is.null(x)) {
    y
  } else {
    x
  }
}
# If x is NA, return y, otherwise return x
"%|NA|%" <- function(x, y){
  if (is.na(x)) {
    y
  } else {
    x
  }
}

# typing reactiveValues is too long
rv <- shiny::reactiveValues
rvtl <- shiny::reactiveValuesToList

# The function is from the cli package: https://github.com/jonocarroll/cli/blob/2d3fbc4b41327df82df1102cdfc0a5c99822809b/R/inline.R
glue_oxford_collapse <- function(x) {
  if (length(x) >= 3) {
    glue::glue_collapse(x, sep = ", ", last = ", and ")
    } else {
      glue::glue_collapse(x, sep = ", ", last = " and ")
    }
}
