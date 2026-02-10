# Package Options

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
  ~Variable,    ~Description,
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
enable this for every session. If no dictionary is found and the data
has no label attributes,
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
continues normally. If something goes wrong, it warns and moves on.

You can still call
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
explicitly whenever you need per-table control.

## More Vignettes

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started with extras()
- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling and cross-package workflows
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA compact themes for gtsummary and gt tables
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers and advanced formatting
