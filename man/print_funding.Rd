% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print_funding.R
\name{print_funding}
\alias{print_funding}
\title{Generate human readable report of the funding information}
\usage{
print_funding(infosheet, initials = FALSE)
}
\arguments{
\item{infosheet}{validated infosheet}

\item{initials}{Logical. If true initials will be included instead of full
names in the output}
}
\value{
The function returns a string.
}
\description{
The functions generates the funding information section of the manuscript.
The output is generated from an infosheet validated with
the \code{\link{validate_infosheet}} function.
The infosheet must be based on the \code{\link{infosheet_template}}.
}
\seealso{
Other output functions: 
\code{\link{print_credit_roles}()},
\code{\link{print_title_page}()},
\code{\link{print_xml}()},
\code{\link{print_yaml}()}
}
\concept{output functions}
