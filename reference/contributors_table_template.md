# Template for the contributors table

Dataset that represents the data structure that the tenzing package
functions require to run without error. The dataset is filled with
example values and based on the online spreadsheet provided in the shiny
app.

## Usage

``` r
contributors_table_template
```

## Format

A dataframe with 3 rows and 22 variables:

- 'Author/Acknowledgee':

  character, whether the contributor is an 'Author', 'Acknowledgment
  only', or 'Don't agree to be named'

- 'Order in publication':

  numeric, used to order the contributors for all outputs, shared first
  authorship is allowed

- Firstname:

  character, first name of the contributor, must be provided

- 'Middle name':

  character, middle name of the contributor, blank if not applicable

- Surname:

  character, surname of the contributor, must be provided

- Conceptualization:

  logical, CREdiT role

- 'Data curation':

  logical, CREdiT role

- 'Formal analysis':

  logical, CREdiT role

- 'Funding acquisition':

  logical, CREdiT role

- Investigation:

  logical, CREdiT role

- Methodology:

  logical, CREdiT role

- 'Project administration':

  logical, CREdiT role

- Resources:

  logical, CREdiT role

- Software:

  logical, CREdiT role

- Supervision:

  logical, CREdiT role

- Validation:

  logical, CREdiT role

- Visualization:

  logical, CREdiT role

- 'Writing - original draft':

  logical, CREdiT role

- 'Writing - review & editing':

  logical, CREdiT role

- Note:

  character, optional comments for the contributor

- 'Email address':

  character, email address of the correspondign author, optional

- 'Affiliation 1':

  character, primary affiliation of the contributor

- 'Affiliation 2':

  character, secondary affiliation of the contributor, blank if not
  applicable

- 'Affiliation 3':

  character, tertiary affiliation of the contributor, blank if not
  applicable, more affiliation columns can be added following the
  "Affiliation {n}" pattern

- Funding:

  character, name of the funds, blank if not applicable

- ORCID iD:

  character, ORCID iD of the contributor

- 'Corresponding author?':

  logical, TRUE for contributor who is the corresponding author,
  multiple corresponding authors are allowed

- 'Declares':

  character, conflict of interest statement of the contributor

## Source

<https://docs.google.com/spreadsheets/d/1Gl0cwqN_nTsdFH9yhSvi9NypBfDCEhViGq4A3MnBrG8/edit?usp=sharing>

## Remark

Each row contains the contributorship information for one contributor.
In the template there are 3 contributors added as an example but there
is no limit to the number of contributors while using the package.
