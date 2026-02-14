# sumExtras <img src="man/figures/logo.png" align="right" height="130" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/kyleGrealis/sumExtras/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kyleGrealis/sumExtras/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![CRAN status](https://www.r-pkg.org/badges/version/sumExtras)](https://CRAN.R-project.org/package=sumExtras)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/sumExtras)](https://cran.r-project.org/package=sumExtras)
<!-- badges: end -->

> **sumExtras**: "**SUM**mary table **EXTRAS**"

## Overview

`{sumExtras}` reduces the repetitive boilerplate in `{gtsummary}` workflows. One function replaces five. Stop copy-pasting `add_overall()`, `add_p()`, `bold_labels()`, and `modify_header()` on every table. Call `extras()` once. The package also handles missing value cleanup, automatic variable labeling from data dictionaries, group header styling, and JAMA compact theming.

## Installation

### CRAN

```r
install.packages("sumExtras")
```

### Development version

```r
# install.packages("pak")
pak::pak("kyleGrealis/sumExtras")
```

## Quick Start

```r
library(sumExtras)
library(gtsummary)
```

<table>
<tr>
<td width="50%" valign="top">

**Standard `{gtsummary}`**

```r
theme_gtsummary_compact("jama")

trial |>
  tbl_summary(by = trt) |>
  add_overall() |>
  add_p() |>
  bold_labels() |>
  bold_p() |>
  modify_header(label = "")
```

</td>
<td width="50%" valign="top">

**With `{sumExtras}`**

```r
use_jama_theme()

trial |>
  tbl_summary(by = trt) |>
  extras()
```

</td>
</tr>
</table>

<p align="center">
  <img src="man/figures/readme-example.png" alt="Table produced by extras()" width="500">
</p>

That single `extras()` call replaces `add_overall()`, `add_p()`, `bold_labels()`, `bold_p()`, and `modify_header()`. It also standardizes missing values via `clean_table()`.

## Functions

* `extras()` -- overall column, p-values (bolded), bold labels, clean styling
* `clean_table()` -- standardize missing value display
* `add_auto_labels()` -- automatic labeling from dictionaries or data attributes
* `use_jama_theme()` / `theme_gt_compact()` -- JAMA compact themes
* `add_group_styling()` -- bold/italic formatting for group headers
* `add_group_colors()` -- background colors for group headers (converts to `{gt}`)
* `get_group_rows()` -- extract group header row indices

## Options

* `options(sumExtras.auto_labels = TRUE)` -- add labels through the project without needing `add_auto_labels()` for each table
* `options(sumExtras.prefer_dictionary = TRUE)` -- change the labeling priority

## More Info

**[Full documentation](https://www.kyleGrealis.com/sumExtras/)**

* `vignette("sumExtras-intro")` -- getting started
* `vignette("labeling")` -- dictionary-based labeling
* `vignette("themes")` -- JAMA themes for `{gtsummary}` and `{gt}`
* `vignette("styling")` -- group headers and advanced formatting
* `vignette("options")` -- .Rprofile options for auto-labeling
* [Bug reports & feature requests](https://github.com/kyleGrealis/sumExtras/issues)

## FAQ

**Why not just use `{gtsummary}` directly?**
You can. `{sumExtras}` wraps the formatting steps you repeat on every table. If you only make one or two tables, you don't need this package.

**What happens if something fails inside `extras()`?**
It warns and continues. Your table always renders. See the warn-and-continue design in `vignette("sumExtras-intro")`.

**Why didn't my dictionary labels show up?**
Your data likely has label attributes that take priority. Set `options(sumExtras.prefer_dictionary = TRUE)` or see `vignette("labeling")`.

**Does `extras()` work with survey data?**
Yes. `tbl_svysummary` tables get the same treatment as `tbl_summary`.

## Contributing

Bug reports, feature requests, and feedback are welcome at <https://github.com/kyleGrealis/sumExtras/issues>.

## License

[MIT](https://github.com/kyleGrealis/sumExtras/blob/main/LICENSE)
