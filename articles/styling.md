# Table Styling and Formatting

``` r

library(sumExtras)
library(gtsummary)
library(dplyr)
library(gt)

use_jama_theme()
```

## Group Headers

[`gtsummary::add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
creates section headers in your table.
[sumExtras](https://github.com/kyleGrealis/sumExtras) provides functions
to style them.

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
  )
```

[TABLE]

The headers are there, but they don’t stand out. That’s where
[`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)
comes in.

## `add_group_styling()`

Adds bold and/or italic formatting to group headers. Also restores
left-justified variable label indentation that
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
changes.

#### Without styling

``` r

trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Variables",
    variables = age:stage
  )
```

#### With add_group_styling()

``` r

trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Variables",
    variables = age:stage
  ) |>
  add_group_styling()
```

[TABLE]

[TABLE]

The `format` argument controls the text style:

``` r

# Bold only
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling(format = "bold")
```

[TABLE]

Options are `"bold"`, `"italic"`, or `c("bold", "italic")` (the
default).

## `add_group_colors()`

Adds a background color to group header rows. This is a terminal
operation in that it converts the table to [gt](https://gt.rstudio.com).
It must be the **last step** in your pipeline.

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
  add_group_styling() |>
  add_group_colors(color = "#E3F2FD")
```

[TABLE]

The default color is `"#E8E8E8"` (light gray). Pass any CSS color
string, or a vector of colors (one per group):

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
  add_group_styling() |>
  add_group_colors(color = c("#E3F2FD", "#FFF9E6"))
```

[TABLE]

## `get_group_rows()`

If you need more control than
[`add_group_colors()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_colors.md)
provides,
[`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md)
returns the row indices of group headers. You can then use those with
[`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
directly:

``` r

my_table <- trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Disease",
    variables = grade:stage
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = list(
      gt::cell_fill(color = "#E8E8E8"),
      gt::cell_text(weight = "bold")
    ),
    locations = gt::cells_body(rows = group_rows)
  )
```

[TABLE]

## Matching gt Tables with `theme_gt_compact()`

If you mix [gtsummary](https://github.com/ddsjoberg/gtsummary) tables
with plain [gt](https://gt.rstudio.com) tables in the same document,
they won’t match visually.
[`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
applies the same JAMA compact look to [gt](https://gt.rstudio.com)
tables so everything is consistent:

#### gtsummary with extras()

``` r

trial |>
  tbl_summary(
    by = trt,
    include = c(age, grade, marker)
  ) |>
  extras()
```

#### gt with theme_gt_compact()

``` r

trial |>
  select(trt, age, grade, marker) |>
  head(10) |>
  gt() |>
  theme_gt_compact()
```

[TABLE]

| Chemotherapy Treatment | Age | Grade | Marker Level (ng/mL) |
|------------------------|-----|-------|----------------------|
| Drug A                 | 23  | II    | 0.160                |
| Drug B                 | 9   | I     | 1.107                |
| Drug A                 | 31  | II    | 0.277                |
| Drug A                 | NA  | III   | 2.067                |
| Drug A                 | 51  | III   | 2.767                |
| Drug B                 | 39  | I     | 0.613                |
| Drug A                 | 37  | II    | 0.354                |
| Drug A                 | 32  | I     | 1.739                |
| Drug A                 | 31  | II    | 0.144                |
| Drug B                 | 34  | I     | 0.205                |

See
[`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
for more on theming.

## Complete Example

``` r

dictionary <- tibble::tribble(
  ~variable,    ~description,
  "trt",        "Treatment Assignment",
  "age",        "Age at Baseline (years)",
  "marker",     "Biomarker Level (ng/mL)",
  "stage",      "Clinical Stage",
  "grade",      "Tumor Grade",
  "response",   "Treatment Response",
  "death",      "Patient Died"
)

trial |>
  select(trt, age, marker, grade, stage, response, death) |>
  tbl_summary(by = trt, missing = "no") |>
  add_auto_labels(dictionary = dictionary) |>
  extras() |>
  add_variable_group_header(
    header = "BASELINE CHARACTERISTICS",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "DISEASE CHARACTERISTICS",
    variables = grade:stage
  ) |>
  add_variable_group_header(
    header = "OUTCOMES",
    variables = response:death
  ) |>
  add_group_styling() |>
  add_group_colors(color = "#E8E8E8")
```

[TABLE]

## More Vignettes

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started with extras()
- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA compact themes for
  [gtsummary](https://github.com/ddsjoberg/gtsummary) and
  [gt](https://gt.rstudio.com) tables
- [`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
  – .Rprofile options for automatic labeling
