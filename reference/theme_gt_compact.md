# Apply compact JAMA-style theme to gt tables

Applies a compact table theme to gt tables that matches the 'jama' theme
from gtsummary, so gtsummary and plain gt tables look the same in one
document. Reduces padding, adjusts font sizes, and applies JAMA journal
styling.

## Usage

``` r
theme_gt_compact(tbl)
```

## Arguments

- tbl:

  A gt table object created with
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html)

## Value

A gt table object with compact JAMA-style formatting applied

## Details

This function replicates the visual appearance of
`gtsummary::theme_gtsummary_compact("jama")` for use with regular gt
tables. Key styling includes:

- Reduced font size (13px) for compact appearance

- Minimal padding (1px) on all row types

- Bold column headers and table titles

- Hidden top and bottom table borders

- Consistent spacing that matches JAMA journal standards

## See also

- [`gtsummary::theme_gtsummary_compact()`](https://www.danieldsjoberg.com/gtsummary/reference/theme_gtsummary.html)
  for gtsummary table themes

- [`gtsummary::set_gtsummary_theme()`](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)
  for setting global gtsummary themes

- [`gt::tab_options()`](https://gt.rstudio.com/reference/tab_options.html)
  for additional gt table styling options

## Examples

``` r
# Basic usage with a data frame
mtcars |>
  head() |>
  gt::gt() |>
  theme_gt_compact()


  

mpg
```

cyl

disp

hp

drat

wt

qsec

vs

am

gear

carb

21.0

6

160

110

3.90

2.620

16.46

0

1

4

4

21.0

6

160

110

3.90

2.875

17.02

0

1

4

4

22.8

4

108

93

3.85

2.320

18.61

1

1

4

1

21.4

6

258

110

3.08

3.215

19.44

1

0

3

1

18.7

8

360

175

3.15

3.440

17.02

0

0

3

2

18.1

6

225

105

2.76

3.460

20.22

1

0

3

1

\# Combine with other gt functions mtcars \|\>
[head](https://rdrr.io/r/utils/head.html)() \|\>
gt::[gt](https://gt.rstudio.com/reference/gt.html)() \|\>
gt::[tab_header](https://gt.rstudio.com/reference/tab_header.html)(title
= "Vehicle Data") \|\> theme_gt_compact()

| Vehicle Data |     |      |     |      |       |       |     |     |      |      |
|-------------:|----:|-----:|----:|-----:|------:|------:|----:|----:|-----:|-----:|
|          mpg | cyl | disp |  hp | drat |    wt |  qsec |  vs |  am | gear | carb |
|         21.0 |   6 |  160 | 110 | 3.90 | 2.620 | 16.46 |   0 |   1 |    4 |    4 |
|         21.0 |   6 |  160 | 110 | 3.90 | 2.875 | 17.02 |   0 |   1 |    4 |    4 |
|         22.8 |   4 |  108 |  93 | 3.85 | 2.320 | 18.61 |   1 |   1 |    4 |    1 |
|         21.4 |   6 |  258 | 110 | 3.08 | 3.215 | 19.44 |   1 |   0 |    3 |    1 |
|         18.7 |   8 |  360 | 175 | 3.15 | 3.440 | 17.02 |   0 |   0 |    3 |    2 |
|         18.1 |   6 |  225 | 105 | 2.76 | 3.460 | 20.22 |   1 |   0 |    3 |    1 |

\# Use alongside gtsummary tables for consistency \# Set gtsummary theme
first
gtsummary::[set_gtsummary_theme](https://www.danieldsjoberg.com/gtsummary/reference/set_gtsummary_theme.html)(gtsummary::[theme_gtsummary_compact](https://www.danieldsjoberg.com/gtsummary/reference/theme_gtsummary.html)("jama"))
\#\> Setting theme "Compact" \# Then both tables will have matching
appearance summary_table \<-
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)()
data_table \<-
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\> [head](https://rdrr.io/r/utils/head.html)() \|\>
gt::[gt](https://gt.rstudio.com/reference/gt.html)() \|\>
theme_gt_compact()
