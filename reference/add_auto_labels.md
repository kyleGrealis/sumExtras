# Add automatic labels from dictionary to a gtsummary table

Automatically apply variable labels from a dictionary or label
attributes to `tbl_summary`, `tbl_svysummary`, or `tbl_regression`
objects. Intelligently preserves manual label overrides set in the
original table call while applying dictionary labels or reading label
attributes from data. The dictionary can be passed explicitly or will be
searched for in the calling environment. If no dictionary is found, the
function will attempt to read label attributes from the underlying data.

## Usage

``` r
add_auto_labels(tbl, dictionary)
```

## Arguments

- tbl:

  A gtsummary table object created by
  [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html),
  [`tbl_svysummary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_svysummary.html),
  or
  [`tbl_regression()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_regression.html).

- dictionary:

  A data frame or tibble with `Variable` and `Description` columns. If
  not provided (missing), the function will search for a `dictionary`
  object in the calling environment. If no dictionary is found, the
  function will attempt to read label attributes from the data. Set to
  `NULL` explicitly to skip dictionary search and only use attributes.

## Value

A gtsummary table object with labels applied. Manual labels set via
`label = list(...)` in the original table call are always preserved.

## Details

### Label Priority Hierarchy

The function applies labels according to this priority (highest to
lowest):

1.  **Manual labels** - Labels set via `label = list(...)` in
    [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)
    etc. are always preserved

2.  **Dictionary vs Attributes** - Controlled by
    `options(sumExtras.preferDictionary)`:

    - If `TRUE`: Dictionary labels take precedence over attribute labels

    - If `FALSE` (default): Attribute labels take precedence over
      dictionary labels

3.  **Default** - If no label source is available, uses variable name

### Dictionary Format

The dictionary must be a data frame with columns:

- `Variable`: Character column with exact variable names from datasets

- `Description`: Character column with human-readable labels

### Label Attributes

The function reads label attributes from data using
`attr(data$var, "label")`, following the same label convention used by
**haven**, **Hmisc**, and **ggplot2 4.0+**.

Your data may already have labels from various sources - imported from
statistical software packages, set by other R packages, added manually,
or from collaborative projects. This function discovers and applies them
seamlessly within gtsummary tables.

Because sumExtras uses native R's attribute storage, labels work across
any package that respects the `"label"` attribute convention, including:

- **ggplot2 4.0+** - automatic axis and legend labels

- **gt** - table label support

- **Hmisc** - label utilities and display functions

This approach requires zero package dependencies and is fully compatible
with the labelled package if you choose to use it, but does not require
it.

### Implementation Note

**This function relies on internal gtsummary structures**
(`tbl$call_list`, `tbl$inputs`, `tbl$table_body`) to detect manually set
labels. While robust error handling is implemented, major updates to
gtsummary may require corresponding updates to sumExtras. Requires
gtsummary \>= 1.7.0.

## Options

Set `options(sumExtras.preferDictionary = TRUE)` to prioritize
dictionary labels over label attributes when both are available. Default
is `FALSE`, which prioritizes attributes over dictionary labels.

## See also

- [`apply_labels_from_dictionary()`](https://kyleGrealis.com/sumExtras/reference/apply_labels_from_dictionary.md)
  for setting label attributes on data for ggplot2/other packages

- [`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
  for advanced table customization

Other labeling functions:
[`apply_labels_from_dictionary()`](https://kyleGrealis.com/sumExtras/reference/apply_labels_from_dictionary.md)

## Examples

``` r
# \donttest{
# Create a dictionary
my_dict <- tibble::tribble(
  ~Variable, ~Description,
  "age", "Age at Enrollment",
  "trt", "Treatment Group",
  "grade", "Tumor Grade"
)

# Basic usage: pass dictionary explicitly
gtsummary::trial |>
  gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
  add_auto_labels(dictionary = my_dict)


  

Characteristic
```

**Drug A**  
N = 98¹

**Drug B**  
N = 102¹

Age

46 (37, 60)

48 (39, 56)

    Unknown

7

4

Grade

  

  

    I

35 (36%)

33 (32%)

    II

32 (33%)

36 (35%)

    III

31 (32%)

33 (32%)

¹ Median (Q1, Q3); n (%)

\# Automatic dictionary search (dictionary in environment) dictionary
\<- my_dict
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(by
= trt, include = [c](https://rdrr.io/r/base/c.html)(age, grade)) \|\>
add_auto_labels() \# Finds dictionary automatically \#\> Auto-labeling
from 'dictionary' object in your environment (this message will only
show once per session)

[TABLE]

\# Working with pre-labeled data (no dictionary needed) labeled_data \<-
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
[attr](https://rdrr.io/r/base/attr.html)(labeled_data\$age, "label") \<-
"Patient Age (years)"
[attr](https://rdrr.io/r/base/attr.html)(labeled_data\$marker, "label")
\<- "Marker Level (ng/mL)" labeled_data \|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(include
= [c](https://rdrr.io/r/base/c.html)(age, marker)) \|\>
add_auto_labels() \# Reads from label attributes

| **Characteristic**   |   **N = 200**¹    |
|:---------------------|:-----------------:|
| Patient Age (years)  |    47 (38, 57)    |
|     Unknown          |        11         |
| Marker Level (ng/mL) | 0.64 (0.22, 1.41) |
|     Unknown          |        10         |
| ¹ Median (Q1, Q3)    |                   |

\# Manual overrides always win
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(
by = trt, include = [c](https://rdrr.io/r/base/c.html)(age, grade),
label = [list](https://rdrr.io/r/base/list.html)(age ~ "Custom Age
Label") \# Manual override ) \|\> add_auto_labels(dictionary = my_dict)
\# grade gets dict label, age keeps manual

[TABLE]

\# Control priority with options
[options](https://rdrr.io/r/base/options.html)(sumExtras.preferDictionary
= TRUE) \# Dictionary over attributes \# Data has both dictionary and
attributes labeled_trial \<-
gtsummary::[trial](https://www.danieldsjoberg.com/gtsummary/reference/trial.html)
[attr](https://rdrr.io/r/base/attr.html)(labeled_trial\$age, "label")
\<- "Age from Attribute" dictionary \<-
tibble::[tribble](https://tibble.tidyverse.org/reference/tribble.html)(
~Variable, ~Description, "age", "Age from Dictionary" ) labeled_trial
\|\>
gtsummary::[tbl_summary](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)(include
= age) \|\> add_auto_labels() \# Uses "Age from Dictionary" (option =
TRUE)

| **Characteristic**  | **N = 200**¹ |
|:--------------------|:------------:|
| Age from Dictionary | 47 (38, 57)  |
|     Unknown         |      11      |
| ¹ Median (Q1, Q3)   |              |

\# }
