# Automatic Variable Labeling

``` r
library(sumExtras)
library(gtsummary)
library(dplyr)

use_jama_theme()
```

Raw variable names like `trt`, `marker`, and `grade` don’t belong in a
publication table. If you’re building 20+ tables across an analysis,
manually relabeling the same variables in every
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)
call is time consuming.
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
lets you define labels once and apply them everywhere.

## Creating a Data Dictionary

A dictionary is a data frame with two columns: `variable` (exact
variable names) and `description` (the labels you want displayed).
Column names are case-insensitive.

``` r
dictionary <- tibble::tribble(
  ~variable,    ~description,
  "trt",        "Chemotherapy Treatment",
  "age",        "Age at Enrollment (years)",
  "marker",     "Marker Level (ng/mL)",
  "stage",      "T Stage",
  "grade",      "Tumor Grade",
  "response",   "Tumor Response",
  "death",      "Patient Died"
)

dictionary
#> # A tibble: 7 × 2
#>   variable description              
#>   <chr>    <chr>                    
#> 1 trt      Chemotherapy Treatment   
#> 2 age      Age at Enrollment (years)
#> 3 marker   Marker Level (ng/mL)     
#> 4 stage    T Stage                  
#> 5 grade    Tumor Grade              
#> 6 response Tumor Response           
#> 7 death    Patient Died
```

In practice, you could load this from a CSV or define it once at the top
of your analysis script.

## Labeling gtsummary Tables

### Pass the Dictionary Explicitly

``` r
trial |>
  tbl_summary(by = trt, include = c(age, grade, marker)) |>
  extras() |> 
  add_auto_labels(dictionary = dictionary)
```

[TABLE]

### Automatic Discovery

If a `dictionary` object exists in your environment,
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
finds it without you passing it:

``` r
# dictionary already exists from above
trial |>
  tbl_summary(by = trt, include = c(age, stage, response)) |>
  extras() |> 
  add_auto_labels()
```

[TABLE]

### Pre-Labeled Data

If your data already has label attributes (e.g., from
[`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html)
or manual assignment),
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
reads those directly:

``` r
labeled_trial <- trial
attr(labeled_trial$age, "label") <- "Patient Age at Baseline"
attr(labeled_trial$marker, "label") <- "Biomarker Concentration (ng/mL)"

labeled_trial |>
  tbl_summary(by = trt, include = c(age, marker)) |>
  extras() |> 
  add_auto_labels()
```

[TABLE]

### Manual Overrides Always Win

Labels set via `label = list(...)` in
[`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)
always take priority over dictionary or attribute labels:

``` r
trial |>
  tbl_summary(
    by = trt,
    include = c(age, grade, marker),
    label = list(age ~ "Age (from tbl_summary function)")
  ) |>
  extras() |> 
  add_auto_labels(dictionary = dictionary)
```

[TABLE]

### Regression Tables

Works with
[`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html)
the same way:

``` r
lm(marker ~ age + grade + stage, data = trial) |>
  tbl_regression() |>
  add_auto_labels()
```

[TABLE]

## Label Priority

When both dictionary labels and attribute labels exist for the same
variable, attribute labels take priority by default:

1.  **Manual labels** (from `label = list(...)` in
    [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html))
    always win
2.  **Attribute labels** (from `attr(data$var, "label")`) take priority
    over dictionary
3.  **Dictionary labels** are used as a fallback

We recommend setting `options(sumExtras.prefer_dictionary = TRUE)` so
dictionary labels take priority over attribute labels. This is
especially useful when your imported data has generic attribute labels
but your dictionary has the labels you actually want in publication
tables. See
[`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
for details.

``` r
trial_both <- trial
attr(trial_both$age, "label") <- "Age from Attribute"

dictionary_conflict <- tibble::tribble(
  ~variable, ~description,
  "age", "Age from Dictionary"
)

# Attribute wins over dictionary
trial_both |>
  tbl_summary(by = trt, include = age) |>
  add_auto_labels(dictionary = dictionary_conflict) |>
  extras()
```

[TABLE]

## Automatic Labeling via Options

If you always keep a `dictionary` in your environment, you can skip
calling
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
entirely. Set this once per session (or put it in your `.Rprofile`):

``` r
options(sumExtras.auto_labels = TRUE)
```

Now every
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
call picks up the dictionary automatically:

``` r
dictionary <- tibble::tribble(
  ~variable,    ~description,
  "age",        "Age at Enrollment (years)",
  "marker",     "Marker Level (ng/mL)",
  "grade",      "Tumor Grade"
)

# No add_auto_labels() needed
trial |>
  tbl_summary(by = trt) |>
  extras()
```

If no dictionary is found and the data has no label attributes,
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
continues normally. If something goes wrong, it warns and moves on. You
can still call
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
explicitly whenever you need per-table control.

See
[`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
for more on `.Rprofile` setup.

## More Vignettes

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started with extras()
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers and advanced formatting
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA compact themes for
  [gtsummary](https://github.com/ddsjoberg/gtsummary) and
  [gt](https://gt.rstudio.com)
