# Add automatic labels from dictionary to a gtsummary table

Applies variable labels from a dictionary or label attributes to
`tbl_summary`, `tbl_svysummary`, or `tbl_regression` objects. Preserves
manual label overrides set in the original table call. The dictionary
can be passed explicitly or will be searched for in the calling
environment. If no dictionary is found, the function reads label
attributes from the underlying data.

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

  A data frame or tibble with columns named `variable` and `description`
  (column name matching is case-insensitive). If not provided (missing),
  the function will search for a `dictionary` object in the environment.
  If no dictionary is found, the function will attempt to read label
  attributes from the data. Set to `NULL` explicitly to skip dictionary
  search and only use attributes.

## Value

A gtsummary table object with labels applied. Manual labels set via
`label = list(...)` in the original table call are always preserved.

## Details

### Label Priority Hierarchy

The function applies labels according to this priority (highest to
lowest):

1.  **Manual labels** – Labels set via `label = list(...)` in
    [`tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html)
    etc. are always preserved

2.  **Attribute labels** – Labels from `attr(data$var, "label")`

3.  **Dictionary labels** – Labels from the dictionary data frame

4.  **Default** – If no label source is available, uses variable name

Set `options(sumExtras.prefer_dictionary = TRUE)` to swap priorities 2
and 3 so that dictionary labels take precedence over attribute labels.
See
[`vignette("options")`](https://www.kyleGrealis.com/sumExtras/articles/options.md)
for details.

### Dictionary Format

The dictionary must be a data frame with columns (column names are
case-insensitive):

- `variable`: Character column with exact variable names from datasets

- `description`: Character column with human-readable labels

### Label Attributes

The function reads label attributes from data using
`attr(data$var, "label")`, following the same convention used by haven,
Hmisc, and ggplot2 4.0+. If your data already has labels (from imported
files, other packages, or manual assignment), this function picks them
up automatically.

### Implementation Note

**This function relies on internal gtsummary structures**
(`tbl$call_list`, `tbl$inputs`, `tbl$table_body`) to detect manually set
labels. Major updates to gtsummary may require corresponding updates to
sumExtras. Requires gtsummary \>= 1.7.0.

## See also

- [`gtsummary::modify_table_body()`](https://www.danieldsjoberg.com/gtsummary/reference/modify_table_body.html)
  for advanced table customization

## Examples

``` r
# \donttest{
# Create a dictionary
my_dict <- tibble::tribble(
  ~variable, ~description,
  "age", "Age at Enrollment",
  "trt", "Treatment Group",
  "grade", "Tumor Grade"
)

# Strip built-in labels so dictionary labels are visible
trial_data <- gtsummary::trial
for (col in names(trial_data)) attr(trial_data[[col]], "label") <- NULL

# Pass dictionary explicitly
trial_data |>
  gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
  add_auto_labels(dictionary = my_dict)


  

Characteristic
```
