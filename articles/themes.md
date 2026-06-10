# Themes

``` r

library(sumExtras)
library(gtsummary)
library(gt)
```

## `use_jama_theme()`

[`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
sets the [gtsummary](https://github.com/ddsjoberg/gtsummary) theme to
JAMA compact styling for the rest of your session. It reduces padding,
tightens font sizes, and produces tables suited for publication or
reports.

``` r

use_jama_theme()

trial |>
  tbl_summary(by = trt) |>
  extras()
```

[TABLE]

This is equivalent to calling
`gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))`
but shorter to type.

To reset back to the default
[gtsummary](https://github.com/ddsjoberg/gtsummary) theme:

``` r

gtsummary::reset_gtsummary_theme()
```

## `theme_gt_compact()`

When you mix [gtsummary](https://github.com/ddsjoberg/gtsummary) tables
with plain [gt](https://gt.rstudio.com) tables in the same document, the
styling mismatch is noticeable.
[`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
applies the same JAMA compact look to [gt](https://gt.rstudio.com)
tables.

#### Default gt

``` r

trial |>
  select(trt, age, grade) |>
  head(10) |>
  gt::gt()
```

#### With theme_gt_compact()

``` r

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

You can layer additional [gt](https://gt.rstudio.com) styling on top:

``` r

trial |>
  dplyr::select(trt, age, grade, marker) |>
  head(8) |>
  gt::gt() |>
  theme_gt_compact() |>
  gt::tab_header(
    title = "Trial Patient Sample",
    subtitle = "First 8 patients"
  )
```

| Trial Patient Sample   |     |       |                      |
|------------------------|-----|-------|----------------------|
| First 8 patients       |     |       |                      |
| Chemotherapy Treatment | Age | Grade | Marker Level (ng/mL) |
| Drug A                 | 23  | II    | 0.160                |
| Drug B                 | 9   | I     | 1.107                |
| Drug A                 | 31  | II    | 0.277                |
| Drug A                 | NA  | III   | 2.067                |
| Drug A                 | 51  | III   | 2.767                |
| Drug B                 | 39  | I     | 0.613                |
| Drug A                 | 37  | II    | 0.354                |
| Drug A                 | 32  | I     | 1.739                |

## More Vignettes

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started with extras()
- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers and advanced formatting
- [`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
  – .Rprofile options for automatic labeling
