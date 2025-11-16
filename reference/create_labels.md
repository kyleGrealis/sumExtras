# Create a list of variable labels from a dataset using a dictionary

Creates a list of formula objects for variable labeling compatible with
[`gtsummary::tbl_summary()`](https://www.danieldsjoberg.com/gtsummary/reference/tbl_summary.html).
Matches dataset variable names against a dictionary tibble to generate
labels. The dictionary can be passed explicitly as a parameter or will
be searched for in the calling environment.

## Usage

``` r
create_labels(data, dictionary = NULL)
```

## Arguments

- data:

  A data frame or tibble containing variables to be labeled

- dictionary:

  Optional. A data frame or tibble with `Variable` and `Description`
  columns. If not provided, the function will search for a `dictionary`
  object in the calling environment.

## Value

A list of formula objects in the format `variable ~ "Description"`
suitable for use in `gtsummary::tbl_summary(label = )`

## Details

The dictionary must be structured as a data frame with columns:

- `Variable`: Character column with exact variable names from datasets

- `Description`: Character column with human-readable labels

Only variables present in both the input data and dictionary will be
included in the output. Missing variables are silently ignored.

## See also

[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)
for automatic application to existing tbl_summary objects

Other labeling functions:
[`add_auto_labels()`](https://www.kyleGrealis.com/sumExtras/reference/add_auto_labels.md)

## Examples

``` r
# \donttest{
# Create a dictionary
my_dict <- tibble::tribble(
  ~Variable, ~Description,
  "age", "Age at Enrollment",
  "marker", "Marker Level (ng/mL)",
  "trt", "Treatment Group"
)

# Pass dictionary explicitly (recommended)
my_labels <- create_labels(gtsummary::trial, dictionary = my_dict)

# Or use without passing (searches calling environment)
dictionary <- my_dict
my_labels <- create_labels(gtsummary::trial)

# Use directly in tbl_summary
gtsummary::trial |>
  gtsummary::tbl_summary(
    include = c(age, marker, trt),
    label = create_labels(gtsummary::trial, dictionary = my_dict)
  )


  

Characteristic
```

**N = 200**¹

Age at Enrollment

47 (38, 57)

    Unknown

11

Marker Level (ng/mL)

0.64 (0.22, 1.41)

    Unknown

10

Treatment Group

  

    Drug A

98 (49%)

    Drug B

102 (51%)

¹ Median (Q1, Q3); n (%)

\# }
