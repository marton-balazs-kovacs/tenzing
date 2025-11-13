# Functions renamed in tenzing 0.2.0

**\[deprecated\]**

In `tenzing 0.2.0` we renamed the `infosheet` to `contributors_table` in
all functions, arguments, and documentation as the new name better
conveys the content and functionality of the table. We also renamed some
other functions as well because of the same reason.

- `validate_infosheet` -\> `validate_contributors_table`

- `read_infosheet` -\> `read_contributors_table`

- `infosheet_template` -\> `contributors_table_template`

- `clean_infosheet` -\> `clean_contributors_table`

- `print_roles_readable` -\> `print_credit_roles`

- `print_contrib_affil` -\> `print_title_page`

## Usage

``` r
validate_infosheet(infosheet = deprecated())

read_infosheet(infosheet_path = deprecated())

clean_infosheet(infosheet = deprecated())

print_roles_readable(infosheet = deprecated())

print_contrib_affil(infosheet = deprecated())
```
