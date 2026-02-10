# sumExtras

> *One function replaces five. Stop chaining
> [`add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html),
> [`add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html),
> [`bold_labels()`](https://www.danieldsjoberg.com/gtsummary/reference/bold_italicize_labels_levels.html),
> [`bold_p()`](https://www.danieldsjoberg.com/gtsummary/reference/bold_p.html),
> and
> [`modify_header()`](https://www.danieldsjoberg.com/gtsummary/reference/modify.html)
> on every table.*

## Overview

**sumExtras** reduces the repetitive boilerplate in gtsummary workflows.
Instead of chaining
[`add_overall()`](https://www.danieldsjoberg.com/gtsummary/reference/add_overall.html),
[`add_p()`](https://www.danieldsjoberg.com/gtsummary/reference/add_p.html),
[`bold_labels()`](https://www.danieldsjoberg.com/gtsummary/reference/bold_italicize_labels_levels.html),
and
[`modify_header()`](https://www.danieldsjoberg.com/gtsummary/reference/modify.html)
on every table, call
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
once. The package also handles missing value cleanup, automatic variable
labeling from data dictionaries, group header styling, and JAMA compact
theming.

## Installation

### CRAN

``` r
install.packages("sumExtras")
```

### Development version

``` r
# install.packages("pak")
pak::pak("kyleGrealis/sumExtras")
```

## See the Difference

[TABLE]

[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
also standardizes missing values via
[`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
– something you’d have to build yourself otherwise.

## Quick Start

``` r
library(sumExtras)
library(gtsummary)

use_jama_theme()

trial |>
  tbl_summary(by = trt) |>
  extras()
```

That single
[`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
call adds the overall column, p-values, bold labels, bold significant
p-values, a clean header, and standardized missing value display.

## Functions

- [`extras()`](https://www.kyleGrealis.com/sumExtras/reference/extras.md)
  – overall column, p-values (bolded), bold labels, clean styling
- [`clean_table()`](https://www.kyleGrealis.com/sumExtras/reference/clean_table.md)
  – standardize missing value display
- [`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
  – automatic labeling from dictionaries or data attributes
- [`use_jama_theme()`](https://www.kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
  /
  [`theme_gt_compact()`](https://www.kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
  – JAMA compact themes
- [`add_group_styling()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_styling.md)
  – bold/italic formatting for group headers
- [`add_group_colors()`](https://www.kyleGrealis.com/sumExtras/reference/add_group_colors.md)
  – background colors for group headers (converts to gt)
- [`get_group_rows()`](https://www.kyleGrealis.com/sumExtras/reference/get_group_rows.md)
  – extract group header row indices

## The Name

**sumExtras** = “**SUM**mary table **EXTRAS**” + “**SOME EXTRAS** for
gt**SUMMARY**”

## More Info

**[Full documentation](https://www.kyleGrealis.com/sumExtras/)**

- [`vignette("sumExtras-intro")`](https://www.kyleGrealis.com/sumExtras/articles/sumExtras-intro.md)
  – getting started
- [`vignette("labeling")`](https://www.kyleGrealis.com/sumExtras/articles/labeling.md)
  – dictionary-based labeling
- [`vignette("themes")`](https://www.kyleGrealis.com/sumExtras/articles/themes.md)
  – JAMA themes for gtsummary and gt
- [`vignette("styling")`](https://www.kyleGrealis.com/sumExtras/articles/styling.md)
  – group headers and advanced formatting
- [`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
  – .Rprofile options for auto-labeling
- [Bug reports & feature
  requests](https://github.com/kyleGrealis/sumExtras/issues)

## Contributing

Bug reports, feature requests, and feedback are welcome at
<https://github.com/kyleGrealis/sumExtras/issues>.

## License

[MIT](https://github.com/kyleGrealis/sumExtras/blob/main/LICENSE)

------------------------------------------------------------------------

sumExtras adds some extras to your summary tables!
