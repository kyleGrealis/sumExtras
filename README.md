# sumExtras <img src="man/figures/logo.png" align="right" height="130" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/kyleGrealis/sumExtras/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/kyleGrealis/sumExtras/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/sumExtras)](https://CRAN.R-project.org/package=sumExtras)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/sumExtras)](https://cran.r-project.org/package=sumExtras)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

<!-- badges: end -->

> *One function replaces five. Stop chaining `add_overall()`, `add_p()`, `bold_labels()`, `bold_p()`, and `modify_header()` on every table.*

## Overview

**sumExtras** reduces the repetitive boilerplate in gtsummary workflows. Instead of chaining `add_overall()`, `add_p()`, `bold_labels()`, and `modify_header()` on every table, call `extras()` once. The package also handles missing value cleanup, automatic variable labeling from data dictionaries, group header styling, and JAMA compact theming.

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

## See the Difference

<table>
<tr>
<td width="50%" valign="top">

**Standard gtsummary**

```r
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

**With sumExtras**

```r
trial |>
  tbl_summary(by = trt) |>
  extras()
```

</td>
</tr>
</table>

`extras()` also standardizes missing values via `clean_table()` -- something you'd have to build yourself otherwise.

## Quick Start

```r
library(sumExtras)
library(gtsummary)

use_jama_theme()

trial |>
  tbl_summary(by = trt) |>
  extras()
```

That single `extras()` call adds the overall column, p-values, bold labels, bold significant p-values, a clean header, and standardized missing value display.

## Functions

* `extras()` -- overall column, p-values (bolded), bold labels, clean styling
* `clean_table()` -- standardize missing value display
* `add_auto_labels()` -- automatic labeling from dictionaries or data attributes
* `use_jama_theme()` / `theme_gt_compact()` -- JAMA compact themes
* `add_group_styling()` -- bold/italic formatting for group headers
* `add_group_colors()` -- background colors for group headers (converts to gt)
* `get_group_rows()` -- extract group header row indices

## The Name

**sumExtras** = "**SUM**mary table **EXTRAS**" + "**SOME EXTRAS** for gt**SUMMARY**"

## More Info

**[Full documentation](https://www.kyleGrealis.com/sumExtras/)**

* `vignette("sumExtras-intro")` -- getting started
* `vignette("labeling")` -- dictionary-based labeling
* `vignette("themes")` -- JAMA themes for gtsummary and gt
* `vignette("styling")` -- group headers and advanced formatting
* `vignette("options")` -- .Rprofile options for auto-labeling
* [Bug reports & feature requests](https://github.com/kyleGrealis/sumExtras/issues)

## Contributing

Bug reports, feature requests, and feedback are welcome at <https://github.com/kyleGrealis/sumExtras/issues>.

## License

[MIT](https://github.com/kyleGrealis/sumExtras/blob/main/LICENSE)

----

sumExtras adds some extras to your summary tables!
