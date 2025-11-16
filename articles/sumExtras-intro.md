# Introduction to sumExtras

``` r
library(sumExtras)
#> 
#> sumExtras loaded.
#> Tip: Use `use_jama_theme()` to apply the JAMA compact theme to {gtsummary}
library(gtsummary)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# Apply the recommended JAMA theme
use_jama_theme()
#> Setting theme "Compact"
#> Applied JAMA compact theme to {gtsummary}
```

## Overview

If you’ve worked with gtsummary before, you’re familiar with the typical
workflow of building summary tables: creating a base table with
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
then progressively adding features like overall columns, p-values, and
formatting tweaks. While gtsummary’s modular approach provides
flexibility, the same sequence of functions appears repeatedly in
analysis scripts.

sumExtras streamlines this process by providing convenience functions
that apply commonly-used formatting patterns in a single step. The
package handles three main pain points:

1.  **Repetitive styling workflows** - Combining multiple formatting
    steps into one function call
2.  **Inconsistent missing value displays** - Standardizing how NA
    values appear across tables
3.  **Manual variable labeling** - Automating label assignment from data
    dictionaries

## The `extras()` Function

The signature function of this package,
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md),
consolidates the most common table enhancements into a single step. At
minimum, it adds bold labels, removes the “Characteristic” header, and
standardizes missing value display. With default settings, it also adds
an overall column and p-values.

### Basic Usage

``` r
# Standard gtsummary workflow
trial |>
  tbl_summary(by = trt) |>
  add_overall() |>
  add_p() |>
  bold_labels() |>
  modify_header(label ~ "")
```

[TABLE]

``` r

# Equivalent using extras()
trial |>
  tbl_summary(by = trt) |>
  extras()
```

[TABLE]

Both approaches produce the same result, but
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
requires less code and ensures consistency across your analysis.

### Customizing Output

You can control which features are applied using the function arguments:

``` r
# Table without p-values
trial |>
  tbl_summary(by = trt) |>
  extras(pval = FALSE)
```

[TABLE]

``` r

# Table without overall column
trial |>
  tbl_summary(by = trt) |>
  extras(overall = FALSE)
```

[TABLE]

``` r

# Overall column as last column (default is to set it as first)
trial |>
  tbl_summary(by = trt) |>
  extras(last = TRUE)
```

[TABLE]

For projects with consistent table formatting requirements, you can
define styling parameters once and reuse them:

``` r
# Define standard table settings for a project
standard_table_args <- list(
  pval = TRUE,
  overall = TRUE,
  last = TRUE
)

# Apply consistently across multiple tables
trial |>
  select(age, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras(.args = standard_table_args)
```

[TABLE]

## Cleaning Missing Values

One subtle but important aspect of table presentation is how missing or
undefined values are displayed. gtsummary tables can show various
representations of missing data: “0 (NA%)”, “NA (NA)”, “NA, NA”, etc.
These inconsistencies create visual clutter and make tables harder to
scan.

The
[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
function (which is called automatically by
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md))
standardizes all zero (`0 (0%)`) or missing value representations to
“—”:

``` r
# Create data with some missing patterns
trial_missing <- trial |>
  mutate(
    age = if_else(trt == 'Drug B', NA_real_, age),
    marker = if_else(trt == 'Drug A', NA_real_, marker)
  )

# Without cleaning
trial_missing |>
  tbl_summary(by = trt)
```

[TABLE]

``` r

# With clean_table()
trial_missing |>
  tbl_summary(by = trt) |>
  clean_table()
```

[TABLE]

You can also use
[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
independently if you prefer to build tables step-by-step:

``` r
trial_missing |>
  tbl_summary(by = trt) |>
  add_overall() |>
  add_p() |>
  clean_table()
```

[TABLE]

## Automatic Variable Labeling

For projects with many variables, manually specifying labels for each
one becomes tedious and error-prone. The
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
function automates this process by pulling labels from a data
dictionary.

### Setting Up a Dictionary

The function expects a dictionary object in your global environment with
two columns: `Variable` (exact variable names) and `Description`
(human-readable labels):

``` r
# Create a dictionary for the trial dataset
dictionary <- tibble::tribble(
  ~Variable,    ~Description,
  "trt",        "Chemotherapy Treatment",
  "age",        "Age at Enrollment",
  "marker",     "Marker Level (ng/mL)",
  "stage",      "T Stage",
  "grade",      "Tumor Grade",
  "response",   "Tumor Response"
)
```

In practice, you would typically maintain this dictionary as a CSV file
or within a data management script, loading it once at the beginning of
your analysis.

### Applying Automatic Labels

Once your dictionary is defined, pipe any gtsummary table through
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md):

``` r
trial |>
  tbl_summary(by = trt) |>
  add_auto_labels() |>
  extras()
#> Warning: Failed to add overall column.
#> ✖ Error: An error occured in `add_overall()`, and the overall statistic cannot be
#> added.
#> Have variable labels changed since the original call to `tbl_summary()`?
#> ℹ Continuing without overall column.
```

[TABLE]

The function intelligently handles several scenarios:

- Variables not in the dictionary are left unlabeled (showing the
  variable name)
- Variables not included in the table are ignored
- Manual label overrides specified in `tbl_summary(label = ...)` take
  precedence over dictionary labels

``` r
# Manual override takes precedence
trial |>
  tbl_summary(
    by = trt,
    label = list(age ~ "Patient Age (years)")  # This overrides dictionary
  ) |>
  add_auto_labels() |>
  extras()
#> Warning: Failed to add overall column.
#> ✖ Error: An error occured in `add_overall()`, and the overall statistic cannot be
#> added.
#> Have variable labels changed since the original call to `tbl_summary()`?
#> ℹ Continuing without overall column.
```

[TABLE]

### Working with Regression Tables

The labeling system also works with regression tables:

``` r
lm(marker ~ age + grade + stage, data = trial) |>
  tbl_regression() |>
  add_auto_labels()
```

[TABLE]

## Styling Group Headers

When you organize variables into sections using
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html),
the
[`group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md)
function adds visual emphasis to make those section headers stand out:

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  ) |>
  group_styling()
```

[TABLE]

By default, this applies both bold and italic formatting to group
headers. You can customize the text formatting:

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  group_styling(format = "bold")  # Bold only
```

[TABLE]

Using
[`group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md)
also restores the original left-justified variable label indentation.
The default behavior of
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
is to align the variable label with categorical levels or “Unknown”
display.

### Adding Background Color to Group Headers

For additional visual distinction, you can add a gray background to
group headers after converting to a gt table. Use the
[`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md)
helper function to identify which rows contain group headers:

``` r
# Create table with groups and styling
my_table <- trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  ) |>
  group_styling()

# Get group row numbers before converting to gt
group_rows <- get_group_rows(my_table)

# Convert to gt and apply gray background
my_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E8E8E8"),
    locations = gt::cells_body(rows = group_rows)
  )
```

[TABLE]

This pattern combines text formatting (bold/italic) with background
color (#E8E8E8, a light gray) to create clear visual separation between
table sections.

## Theme Management

### Applying the JAMA Theme

sumExtras is designed to work best with the JAMA compact theme. Use
[`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
to apply this theme to all gtsummary tables in your session:

``` r
# Apply JAMA compact theme (typically done once at the beginning)
use_jama_theme()
#> Setting theme "Compact"
#> Applied JAMA compact theme to {gtsummary}
```

This is equivalent to calling
`gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))`
but provides a more convenient interface. You can reset to the default
gtsummary theme at any time with
[`gtsummary::reset_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html).

### Compact Themes for gt Tables

When mixing gtsummary tables with regular gt tables in the same
document, visual consistency matters. The
[`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
function applies JAMA-style compact formatting to gt tables, matching
the appearance of the JAMA compact theme:

``` r
# gtsummary table (uses the theme set with use_jama_theme())
trial |>
  select(trt, age, grade) |>
  tbl_summary() |>
  extras()
#> Warning: This table is not stratified (missing `by` argument).
#> ℹ Overall column and p-values require stratification.
#> ℹ Applying only `bold_labels()` and `modify_header(label ~ '')`.
```

[TABLE]

``` r

# Regular gt table with matching compact style
trial |>
  select(trt, age, grade) |>
  head(10) |>
  gt::gt() |>
  theme_gt_compact()
```

| Chemotherapy Treatment | Age | Grade |
|------------------------|-----|-------|
| Drug A                 | 23  | II    |
| Drug B                 | 9   | I     |
| Drug A                 | 31  | II    |
| Drug A                 | NA  | III   |
| Drug A                 | 51  | III   |
| Drug B                 | 39  | I     |
| Drug A                 | 37  | II    |
| Drug A                 | 32  | I     |
| Drug A                 | 31  | II    |
| Drug B                 | 34  | I     |

## Putting It All Together

Here’s a complete workflow demonstrating how these functions work
together:

``` r
# 1. Define your dictionary (typically done once per project)
dictionary <- tibble::tribble(
  ~Variable,    ~Description,
  "trt",        "Chemotherapy Treatment",
  "age",        "Age at Enrollment (years)",
  "marker",     "Marker Level (ng/mL)",
  "stage",      "T Stage",
  "grade",      "Tumor Grade",
  "response",   "Tumor Response",
  "death",      "Patient Died"
)

# 2. Set the recommended theme
use_jama_theme()
#> Setting theme "Compact"
#> Applied JAMA compact theme to {gtsummary}

# 3. Create a table with automatic labels and standard formatting
trial |>
  select(trt, age, marker, stage, grade, response) |>
  tbl_summary(
    by = trt,
    missing = "no"
  ) |>
  add_auto_labels() |>
  extras()
#> Warning: Failed to add overall column.
#> ✖ Error: An error occured in `add_overall()`, and the overall statistic cannot be
#> added.
#> Have variable labels changed since the original call to `tbl_summary()`?
#> ℹ Continuing without overall column.
```

[TABLE]

``` r

# 4. Table with grouped variables, styling, and gray background
final_table <- trial |>
  select(trt, age, marker, grade, stage, response) |>
  tbl_summary(by = trt, missing = "no") |>
  add_auto_labels() |>
  extras() |>
  add_variable_group_header(
    header = "Baseline Characteristics",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Disease Characteristics",
    variables = grade:response
  ) |>
  group_styling()
#> Warning: Failed to add overall column.
#> ✖ Error: An error occured in `add_overall()`, and the overall statistic cannot be
#> added.
#> Have variable labels changed since the original call to `tbl_summary()`?
#> ℹ Continuing without overall column.

# Get group rows and apply gray background
group_rows <- get_group_rows(final_table)

final_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E8E8E8"),
    locations = gt::cells_body(rows = group_rows)
  )
```

[TABLE]

## Next Steps

This vignette covered the core functionality of sumExtras. For detailed
information about individual functions, see their help documentation:

- [`?extras`](https://www.kyleGrealis.com/sumExtras/reference/extras.md) -
  Main styling function
- [`?clean_table`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md) -
  Missing value standardization
- [`?add_auto_labels`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md) -
  Automatic variable labeling
- [`?create_labels`](https://www.kyleGrealis.com/sumExtras/reference/create_labels.md) -
  Manual label list creation
- [`?use_jama_theme`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  Apply JAMA compact theme
- [`?group_styling`](https://www.kyleGrealis.com/sumExtras/reference/group_styling.md) -
  Group header formatting
- [`?get_group_rows`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md) -
  Get row numbers of variable group headers
- [`?theme_gt_compact`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  Compact gt table themes

The package is designed to reduce repetitive code while maintaining the
flexibility of gtsummary’s modular approach. Use as much or as little as
fits your workflow.
