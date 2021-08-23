# tenzing 0.2.0

## Renamed functions
* We changed the name of the input table from _infosheet_ to _contributors_table_ throughout the R package and the Shiny application. Functions containing the term _infosheet_ are now deprecated.

## New features
* New output option is added. The new option allows users to generate the funding acknowledgment section of their manuscript. For this output it is possible to use initials or full names.
* For the contributor list output option now it is possible to use initials instead of full names. Users can also choose to list the contributions according to the CRediT taxonomy after the names of the contributors.
* `tenzing` now allows users to read the contributors_table directly from Google sheets by providing the share URL of the spreadsheet.
* The app allows users to review their contributors_table within the app even if it does not pass the validation checks.
* There are two new columns added to the contributors_table template: ORCiD iD and Funding.
* The name of the CRediT taxonomy roles in the contributors_table are now fixed as well their URLs directing to each role in the taxonomy's documentation.
* The contributors_table template is now empty. However, a filled out example template is added to the package as an external datafile. See the local_use vignette on how to load this example file.
* The title page output option now allows users to add multiple first authors and prints an additional text listing the names of the shared first authors and the email address of the corresponding author.
* The app got a new, cleaner look.

## Bug fixes
* The functions that transform full names to initials are updated and now can handle most names correctly.
* The oxford comma is now added to the output options.
