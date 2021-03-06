% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print_xml.R
\name{print_xml}
\alias{print_xml}
\title{Generate an XML document of the contributions}
\usage{
print_xml(infosheet)
}
\arguments{
\item{infosheet}{validated infosheet}
}
\value{
The function returns an xml nodeset containing the contributors
  listed for each CRediT role they partake in.
}
\description{
The function generates an XML nodeset that contains the contributors' name,
affiliation, and their CRediT roles with a structure outlined in the
JATS 1.2 DTD specifications (eLife). The output is generated from an 
infosheet validated with the \code{\link{validate_infosheet}} function.
The infosheet must be based on the \code{\link{infosheet_template}}.
}
\section{Warning}{

The function is primarily developed to be the part of a shiny app. As the
  validation is handled inside of the app separately, the function can
  break with non-informative errors if running locally without first
  validating it.
}

\examples{
example_infosheet <- read_infosheet(infosheet = system.file("extdata", "infosheet_template_example.csv", package = "tenzing", mustWork = TRUE))
validate_infosheet(infosheet = example_infosheet)
print_xml(infosheet = example_infosheet)
}
\seealso{
Other output functions: 
\code{\link{print_credit_roles}()},
\code{\link{print_funding}()},
\code{\link{print_title_page}()},
\code{\link{print_yaml}()}
}
\concept{output functions}
