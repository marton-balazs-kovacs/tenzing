% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/validate_helpers.R
\name{check_affiliation}
\alias{check_affiliation}
\title{Check for Missing Affiliations}
\usage{
check_affiliation(contributors_table)
}
\arguments{
\item{contributors_table}{A dataframe containing the contributors' information.}
}
\value{
A list containing:
\item{type}{Type of validation result: "success" or "warning".}
\item{message}{An informative message indicating which rows have missing affiliations.}
}
\description{
This function checks whether at least one affiliation (either legacy
or numbered) is provided for each contributor. If a contributor is missing
all affiliation information, the function returns a warning.
}
