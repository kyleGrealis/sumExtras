# sumExtras: Extra Functions for 'gtsummary' Table Styling

Provides additional convenience functions for gtsummary & gt tables,
including automatic variable labeling from dictionaries, standardized
missing value display, and consistent formatting helpers for streamlined
table styling workflows.

Provides additional convenience functions for gtsummary & gt tables,
including automatic variable labeling from dictionaries, standardized
missing value display, and consistent formatting helpers for streamlined
table styling workflows.

## Main Functions

- [`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md) -
  The signature function that adds overall columns, p-values, and clean
  styling

- [`clean_table()`](https://kyleGrealis.com/sumExtras/reference/clean_table.md) -
  Standardizes missing value display

- [`add_auto_labels()`](https://kyleGrealis.com/sumExtras/reference/add_auto_labels.md) -
  Smart automatic variable labeling from dictionaries or label
  attributes

- [`apply_labels_from_dictionary()`](https://kyleGrealis.com/sumExtras/reference/apply_labels_from_dictionary.md) -
  Set label attributes on data for cross-package workflows

- [`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  Apply JAMA compact theme to gtsummary tables

- [`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  JAMA-style compact themes for gt tables

- [`group_styling()`](https://kyleGrealis.com/sumExtras/reference/group_styling.md) -
  Enhanced formatting for grouped tables

## Important Notes on Package Dependencies

**gtsummary Internals:** This package depends on internal structures of
the gtsummary package (specifically `tbl$call_list`, `tbl$inputs`, and
`tbl$table_body`). While we make every effort to maintain compatibility,
major updates to gtsummary may require corresponding updates to
sumExtras.

**Minimum Versions:** Requires gtsummary \>= 1.7.0 and gt \>= 0.9.0.
These minimum versions ensure the necessary internal structures are
available.

**Testing:** We recommend testing your workflows after any gtsummary
updates, especially major version changes.

## See also

- gtsummary package: <https://www.danieldsjoberg.com/gtsummary/>

- Package website: <https://kyleGrealis.com/sumExtras/>

## Author

**Maintainer**: Kyle Grealis <kyleGrealis@proton.me>
([ORCID](https://orcid.org/0000-0002-9223-8854))

Other contributors:

- Raymond Balise <balise@miami.edu>
  ([ORCID](https://orcid.org/0000-0002-9856-5901)) \[contributor\]
