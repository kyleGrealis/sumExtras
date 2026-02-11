# Package Options

## Quick read

Add these options to your `.Rprofile` for persistent use or add to the
beginning of your table building script for ease of sharing.

``` r
options(sumExtras.auto_labels = TRUE)
options(sumExtras.prefer_dictionary = TRUE)
```

## Auto-Labeling with `sumExtras.auto_labels`

If you keep a `dictionary` object in your environment (or your data
already has label attributes), you can skip calling
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
on every table. Set this once:

``` r
options(sumExtras.auto_labels = TRUE)
```

Now
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
handles labeling automatically:

``` r
# Define your dictionary once
dictionary <- tibble::tribble(
  ~variable,    ~description,
  "age",        "Age at Enrollment (years)",
  "marker",     "Marker Level (ng/mL)",
  "grade",      "Tumor Grade"
)

# Every extras() call picks it up
trial |>
  tbl_summary(by = trt) |>
  extras()
```

Put `options(sumExtras.auto_labels = TRUE)` in your `.Rprofile` to
enable this for every session. Another option is to add it at the
beginning of the script that creates your tables. If no dictionary is
found and the data has no label attributes,
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
continues normally. If something goes wrong, it warns and moves on.

You can still call
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
explicitly whenever you need per-table control.

## Dictionary Priority with `sumExtras.prefer_dictionary`

By default, attribute labels (from `attr(data$var, "label")`) take
priority over dictionary labels. If you maintain a centralized data
dictionary and want it to win over attribute labels, set:

``` r
options(sumExtras.prefer_dictionary = TRUE)
```

This changes the label priority to:

1.  **Manual labels** (from `label = list(...)` in
    [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html))
    – always win
2.  **Dictionary labels** – from the dictionary data frame
3.  **Attribute labels** – from `attr(data$var, "label")`

This is useful when your imported data has generic attribute labels
(e.g., from [haven](https://haven.tidyverse.org) or
[labelled](https://larmarange.github.io/labelled/)) but your dictionary
has the labels you actually want in publication tables.

Without the option (or with `sumExtras.prefer_dictionary = FALSE`), the
default priority is manual \> attributes \> dictionary.

## More Vignettes

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started with extras()
- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling and cross-package workflows
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA compact themes for
  [gtsummary](https://github.com/ddsjoberg/gtsummary) and
  [gt](https://gt.rstudio.com) tables
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers and advanced formatting
