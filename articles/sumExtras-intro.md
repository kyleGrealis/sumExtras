# Introduction to sumExtras

``` r
library(sumExtras)
library(gtsummary)
library(dplyr)

use_jama_theme()
```

*All examples in this vignette use the JAMA compact theme via
[`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md).
See
[`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
to set this up.* {.small}

## The `extras()` Function

If you’ve worked with gtsummary before, you’re familiar with the typical
workflow of building summary tables: creating a base table with
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
then progressively adding features like overall columns, p-values, and
formatting tweaks. While gtsummary’s modular approach provides
flexibility, the same sequence of functions appears repeatedly in
analysis scripts.

[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
consolidates the most common gtsummary formatting steps into one call:
bold labels, a clean header, an overall column, p-values, and missing
value cleanup.

#### Standard gtsummary workflow

``` r
trial |>
  tbl_summary(by = trt) |>
  add_overall() |>
  add_p() |>
  bold_labels() |>
  modify_header(label ~ "")
```

#### With extras()

``` r
trial |>
  tbl_summary(by = trt) |>
  extras()
```

[TABLE]

[TABLE]

### Customizing Output

You can control which features are applied:

``` r
# Without p-values
trial |>
  tbl_summary(by = trt) |>
  extras(pval = FALSE)
```

[TABLE]

``` r
# Overall column last instead of first
trial |>
  tbl_summary(by = trt) |>
  extras(last = TRUE)
```

[TABLE]

``` r
# Custom header text
trial |>
  tbl_summary(by = trt) |>
  extras(header = "Variable")
```

[TABLE]

Or pass arguments as a list for reuse across tables:

``` r
my_args <- list(pval = TRUE, overall = TRUE, last = TRUE)

trial |>
  select(age, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras(.args = my_args)
```

[TABLE]

On non-stratified tables,
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
skips
[`add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html)
and
[`add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html)
and applies only the formatting that makes sense. It works the same way
with
[`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
— bold labels, bold significant p-values (from the model), clean header,
and missing value cleanup are applied automatically while irrelevant
options are silently ignored. It never breaks your pipeline.

``` r
# Regression tables work too
glm(response ~ age + grade, data = trial, family = binomial) |>
  tbl_regression(exponentiate = TRUE) |>
  extras()
```

[TABLE]

For merged tables, call
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
on each sub-table **before** merging. All formatting (bold labels,
p-values, missing symbols) carries through
[`tbl_merge()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_merge.html),
so there’s no need to call
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
again after:

``` r
t1 <- trial |>
  tbl_summary(by = trt, include = c(age, grade)) |>
  extras()

t2 <- trial |>
  tbl_summary(by = trt, include = c(marker, stage)) |>
  extras()

tbl_merge(list(t1, t2), tab_spanner = c("**Set A**", "**Set B**"))
```

## Cleaning Missing Values

[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
standardizes missing or zero-count representations (`"0 (NA%)"`,
`"NA (NA)"`, `"NA, NA"`, etc.) to `"---"`. It runs automatically inside
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md),
but you can also use it on its own. The `symbol` parameter controls the
replacement text (default `"---"`). You can also pass `symbol` through
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md).

#### Without cleaning

``` r
trial_missing |>
  tbl_summary(by = trt)
```

#### With clean_table()

``` r
trial_missing |>
  tbl_summary(by = trt) |>
  clean_table()
```

[TABLE]

[TABLE]

## Automatic Labeling

[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
applies human-readable variable labels from a dictionary. Manual labels
set in
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)
always take priority.

``` r
dictionary <- tibble::tribble(
  ~Variable,    ~Description,
  "trt",        "Chemotherapy Treatment",
  "age",        "Age at Enrollment (years)",
  "marker",     "Marker Level (ng/mL)",
  "stage",      "T Stage",
  "grade",      "Tumor Grade"
)

trial |>
  tbl_summary(by = trt, include = c(age, grade, marker)) |>
  add_auto_labels(dictionary = dictionary) |>
  extras()
```

[TABLE]

For more on label priority, pre-labeled data, and auto-discovery, see
[`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md).

## Pipeline Order

When combining with group headers and styling, order matters:

``` r
tbl_summary(by = ...) |>
  extras() |> # always first
  add_variable_group_header() |> # after extras()
  add_group_styling() |> # format group headers
  add_group_colors() # must be last (converts to gt)
```

[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
must come after
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md),
and
[`add_group_colors()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_colors.md)
must be last since it converts the table to gt.

## Other Vignettes

- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA compact themes for gtsummary and gt tables
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers, formatting, and background colors
- [`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
  – .Rprofile options for automatic labeling
