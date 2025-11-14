# Changelog

## tenzing 0.4.1

### Bug fixes

- Fixed a rendering bug with the spreadsheet view module
- Meaningful error message regarding “Conflict of interest” - “Declares”
  column renaming

## tenzing 0.4.0

### New features

- Added the option to include acknowledged contributors and those who do
  not want to be named in the paper to the contributors table.
- Contributor statements are now generated separately for acknowledgees
  and authors.
- Acknowledgees are now listed in the JATS 1.3 XML output with
  affiliations and CRediT roles.
- Funding and conflict of interest statements are now included in the
  JATS 1.3 XML output.
- Full article JATS 1.3 XML can optionally be generated with mock data
  so the output can be validated with the J4R Validator:
  <https://jats4r-validator.niso.org/>.
- ORCID iDs can be included with an unauthorized ORCID badge (with
  hyperlink) or as plain text in the contributors statement, title page,
  and JATS 1.3 XML outputs.
- Added additional conditional validators for the new outputs.
- Added additional validation helpers for creating and exploring
  validation config files.
- Added more opportunities to customize the outputs with toggle
  switches.

### Bug fixes

- Superscript formatting in the downloaded title page output has been
  fixed.
- The app now produces valid JATS 1.3 XML.

## tenzing 0.2.0

### Renamed functions

- We changed the name of the input table from *infosheet* to
  *contributors_table* throughout the R package and the Shiny
  application. Functions containing the term *infosheet* are now
  deprecated.

### New features

- New output option is added. The new option allows users to generate
  the funding acknowledgment section of their manuscript. For this
  output it is possible to use initials or full names.
- For the contributor list output option now it is possible to use
  initials instead of full names. Users can also choose to list the
  contributions according to the CRediT taxonomy after the names of the
  contributors.
- `tenzing` now allows users to read the contributors_table directly
  from Google sheets by providing the share URL of the spreadsheet.
- The app allows users to review their contributors_table within the app
  even if it does not pass the validation checks.
- There are two new columns added to the contributors_table template:
  ORCiD iD and Funding.
- The name of the CRediT taxonomy roles in the contributors_table are
  now fixed as well their URLs directing to each role in the taxonomy’s
  documentation.
- The contributors_table template is now empty. However, a filled out
  example template is added to the package as an external datafile. See
  [`vignette("local_use")`](https://marton-balazs-kovacs.github.io/tenzing/articles/local_use.md)
  on how to load this example file.
- The title page output option now allows users to add multiple first
  authors and prints an additional text listing the names of the shared
  first authors and the email address of the corresponding author.
- The app got a new, cleaner look.

### Bug fixes

- The functions that transform full names to initials are updated and
  now can handle most names correctly.
- The oxford comma is now added to the output options.
