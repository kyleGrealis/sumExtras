# Table Styling and Formatting

``` r
library(sumExtras)
library(gtsummary)
library(dplyr)
library(gt)

# Apply the recommended JAMA theme
use_jama_theme()
```

## Overview

While
[`extras()`](https://kyleGrealis.com/sumExtras/reference/extras.md)
handles basic table formatting, sumExtras provides additional tools for
creating visually polished, publication-ready tables. This vignette
covers advanced styling techniques that go beyond the basics.

You’ll learn how to:

1.  Create visually organized tables with group headers
2.  Style group headers with text formatting
3.  Add background colors for visual emphasis
4.  Work with theme management across gtsummary and gt
5.  Combine techniques for professional table presentation

For basic table creation and labeling, see:

- [`vignette("sumExtras-intro")`](https://kyleGrealis.com/sumExtras/articles/sumExtras-intro.md) -
  Getting started with sumExtras
- [`vignette("labeling")`](https://kyleGrealis.com/sumExtras/articles/labeling.md) -
  Automatic variable labeling workflows

## Group Headers: Organizing Table Sections

When tables contain many variables, organizing them into logical
sections improves readability. The
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
function from gtsummary creates section headers, and sumExtras provides
tools to style them effectively.

### Basic Group Headers

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  )
```

[TABLE]

This creates section headers but they don’t stand out much from regular
variables. Let’s fix that.

## Styling Group Headers with `add_group_styling()`

The
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
function adds visual emphasis to group headers, making section breaks
clear and improving table readability.

### Default Styling: Bold and Italic

By default,
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
applies both bold and italic formatting:

#### Without add_group_styling()

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  )
```

#### With add_group_styling()

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  ) |>
  add_group_styling()
```

[TABLE]

[TABLE]

Notice how the group headers now stand out with bold italic text,
creating clear visual breaks between table sections.

### Customizing Text Formatting

You can control the text formatting using the `format` argument:

#### Bold Only

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling(format = "bold")
```

[TABLE]

#### Italic Only

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling(format = "italic")
```

[TABLE]

#### Both (Explicit)

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Characteristics",
    variables = age:stage
  ) |>
  add_group_styling(format = c("bold", "italic"))
```

[TABLE]

### Important: Indentation Restoration

Using
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
also restores the original left-justified variable label indentation.
The default behavior of
[`add_variable_group_header()`](https://www.danieldsjoberg.com/gtsummary/reference/add_variable_group_header.html)
aligns variable labels with categorical levels or “Unknown” display,
which can look unbalanced.
[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)
fixes this automatically.

Compare these two approaches:

#### Without add_group_styling()

*Indentation may look off*

``` r
trial |>
  select(age, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Variables",
    variables = age:stage
  )
```

#### With add_group_styling()

*Proper indentation restored*

``` r
trial |>
  select(age, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Variables",
    variables = age:stage
  ) |>
  add_group_styling()
```

[TABLE]

[TABLE]

## Background Colors: Enhanced Visual Distinction

For additional visual emphasis, you can add background colors to group
headers using the
[`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)
convenience function.

### Basic Background Color Styling

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Clinical Measures",
    variables = marker:response
  ) |>
  add_group_styling() |> 
  add_group_colors()  # Default light gray background
```

[TABLE]

This applies text formatting (bold/italic) with a light gray background
(#E8E8E8) to create clear visual separation between table sections.

### Understanding `get_group_rows()`

The
[`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md)
function identifies which rows in your gtsummary table contain group
headers:

``` r
# Create a table with groups
grouped_table <- trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Disease Measures",
    variables = marker:stage
  )

# Get row numbers
group_rows <- get_group_rows(grouped_table)
group_rows
#> [1] 1 4
```

These row numbers correspond to the body rows in the resulting gt table,
which you can then target with
[`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html).

### Custom Background Colors

You can specify any color with the `color` argument:

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Baseline Characteristics",
    variables = age:stage
  ) |>
  add_group_styling() |> 
  add_group_colors(color = "#E3F2FD")  # Light blue
```

[TABLE]

### Manual Pattern vs. Convenience Function

For most use cases,
[`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)
provides the simplest approach. However, understanding the manual
pattern helps when you need complex gt styling beyond simple background
colors.

#### Manual Pattern

``` r
my_table <- trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Baseline Characteristics",
    variables = age:stage
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E3F2FD"),
    locations = gt::cells_body(rows = group_rows)
  )
```

#### With add_group_colors()

``` r
trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Baseline Characteristics",
    variables = age:stage
  ) |>
  add_group_styling() |> 
  add_group_colors(color = "#E3F2FD")
```

[TABLE]

[TABLE]

Both approaches produce identical results, but
[`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)
is significantly cleaner—no intermediate objects, no manual
[`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md)
call, fully pipeable.

#### When to Use Which Approach

**Use
[`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)**
when:

- You want a simple, clean workflow with text formatting and background
  colors
- The default light gray (#E8E8E8) or a single custom color works for
  your needs
- You’re creating straightforward publication-ready tables

**Use the manual pattern** when:

- You need complex gt styling beyond background colors
- You want alternating row colors or row-specific styling
- You’re applying multiple different
  [`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
  operations
- You need fine-grained control over every styling detail

## Combining Styling Techniques

The most effective tables often combine multiple styling approaches.
Here are some common patterns.

### Pattern 1: Subtle Section Breaks

For tables in manuscripts where minimalist design is preferred:

``` r
trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt, missing = "no") |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Tumor Characteristics",
    variables = grade:response
  ) |>
  add_group_styling(format = "bold")  # Bold only, no italic
```

[TABLE]

### Pattern 2: Prominent Section Headers

For presentations or reports where visual clarity is paramount:

``` r
my_table <- trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt, missing = "no") |>
  extras() |>
  add_variable_group_header(
    header = "DEMOGRAPHICS",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "TUMOR CHARACTERISTICS",
    variables = grade:response
  ) |>
  add_group_styling()  # Bold + italic

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = list(
      gt::cell_fill(color = "#E8E8E8"),
      gt::cell_text(weight = "bold")
    ),
    locations = gt::cells_body(rows = group_rows)
  )
```

[TABLE]

### Pattern 3: Multi-Section Tables

For complex tables with many grouped sections:

``` r
# Create a more complex grouping
my_table <- trial |>
  select(trt, age, marker, grade, stage, response, death) |>
  tbl_summary(by = trt, missing = "no") |>
  extras() |>
  add_variable_group_header(
    header = "Baseline Demographics",
    variables = age
  ) |>
  add_variable_group_header(
    header = "Biomarkers",
    variables = marker
  ) |>
  add_variable_group_header(
    header = "Disease Characteristics",
    variables = grade:stage
  ) |>
  add_variable_group_header(
    header = "Outcomes",
    variables = response:death
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#F5F5F5"),
    locations = gt::cells_body(rows = group_rows)
  )
```

[TABLE]

## Theme Management

Consistent styling across tables in a document or project requires
thoughtful theme management. sumExtras provides tools for both gtsummary
and gt tables.

### gtsummary Theme: `use_jama_theme()`

The
[`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
function applies the JAMA compact theme to all gtsummary tables in your
session:

``` r
# Apply JAMA compact theme (typically done once at the beginning)
use_jama_theme()

# Now all gtsummary tables use this theme
trial |>
  tbl_summary(by = trt) |>
  extras()
```

[TABLE]

This is equivalent to:

``` r
gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))
```

But
[`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md)
is more concise and memorable.

### Benefits of the JAMA Theme

The JAMA compact theme provides:

- Reduced cell padding for space-efficient tables
- Clean, professional appearance suitable for publication
- Consistent with JAMA style guidelines
- Better information density than default themes

### Resetting to Default

To return to gtsummary’s default theme:

``` r
gtsummary::reset_gtsummary_theme()
```

### gt Table Theme: `theme_gt_compact()`

When mixing gtsummary tables with regular gt tables in the same
document, visual consistency matters. The
[`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
function applies JAMA-style compact formatting to gt tables, matching
the appearance of the JAMA compact theme used by gtsummary.

#### Without theme_gt_compact()

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

The compact theme creates visual consistency with gtsummary tables,
resulting in a more professional, cohesive document.

### Customizing gt Tables Further

[`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)
provides a solid foundation, but you can customize further:

``` r
trial |>
  select(trt, age, grade, marker) |>
  head(8) |>
  gt::gt() |>
  theme_gt_compact() |>
  gt::tab_header(
    title = "Trial Patient Sample",
    subtitle = "First 8 patients"
  ) |>
  gt::tab_style(
    style = gt::cell_fill(color = "#F0F0F0"),
    locations = gt::cells_body(rows = seq(2, 8, 2))  # Zebra striping
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

## Advanced Styling Patterns

### Alternating Row Colors with Groups

Combine group headers with zebra striping for maximum readability:

``` r
my_table <- trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Demographics",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Disease",
    variables = grade:stage
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

# Convert to gt and get the actual number of body rows
gt_table <- my_table |> as_gt()
n_body_rows <- nrow(gt_table$`_data`)

gt_table |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E8E8E8"),
    locations = gt::cells_body(rows = group_rows)
  ) |>
  gt::tab_style(
    style = gt::cell_fill(color = "#F9F9F9"),
    locations = gt::cells_body(rows = !seq_len(n_body_rows) %in% group_rows)
  )
```

[TABLE]

### Highlighting Specific Variables

You can combine group styling with highlighting of specific variables of
interest:

``` r
my_table <- trial |>
  select(age, marker, grade, stage, response, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Baseline",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Disease & Outcome",
    variables = grade:response
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#E8E8E8"),
    locations = gt::cells_body(rows = group_rows)
  ) |>
  gt::tab_style(
    style = list(
      gt::cell_fill(color = "#FFF9E6"),
      gt::cell_text(weight = "bold")
    ),
    locations = gt::cells_body(
      columns = label,
      rows = label == "Tumor Response"  # Highlight primary outcome
    )
  )
```

[TABLE]

### Borders and Dividers

Add subtle borders between groups for additional visual separation:

``` r
my_table <- trial |>
  select(age, marker, grade, stage, trt) |>
  tbl_summary(by = trt) |>
  extras() |>
  add_variable_group_header(
    header = "Patient Factors",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "Tumor Factors",
    variables = grade:stage
  ) |>
  add_group_styling()

group_rows <- get_group_rows(my_table)

my_table |>
  as_gt() |>
  gt::tab_style(
    style = gt::cell_fill(color = "#F5F5F5"),
    locations = gt::cells_body(rows = group_rows)
  ) |>
  gt::tab_style(
    style = gt::cell_borders(
      sides = "bottom",
      color = "#CCCCCC",
      weight = gt::px(2)
    ),
    locations = gt::cells_body(rows = max(group_rows))
  )
```

[TABLE]

## Complete Example: Publication-Ready Table

Here’s a comprehensive example combining all the styling techniques:

``` r
# Create dictionary for labeling (see vignette("labeling") for details)
dictionary <- tibble::tribble(
  ~Variable,    ~Description,
  "trt",        "Treatment Assignment",
  "age",        "Age at Baseline (years)",
  "marker",     "Biomarker Level (ng/mL)",
  "stage",      "Clinical Stage",
  "grade",      "Tumor Grade",
  "response",   "Treatment Response",
  "death",      "Patient Died"
)

# Build the styled table
trial |>
  select(trt, age, marker, grade, stage, response, death) |>
  tbl_summary(by = trt, missing = "no") |>
  add_auto_labels(dictionary = dictionary) |>
  extras() |>
  add_variable_group_header(
    header = "BASELINE CHARACTERISTICS",
    variables = age:marker
  ) |>
  add_variable_group_header(
    header = "DISEASE CHARACTERISTICS",
    variables = grade:stage
  ) |>
  add_variable_group_header(
    header = "OUTCOMES",
    variables = response:death
  ) |>
  add_group_styling() |> 
  add_group_colors(color = "#E8E8E8") |> 
  gt::tab_header(
    title = "Patient Characteristics and Outcomes by Treatment",
    subtitle = "Clinical Trial Dataset"
  ) |>
  gt::tab_source_note(
    source_note = "Data from gtsummary package trial dataset"
  )
```

[TABLE]

This table demonstrates professional formatting suitable for
publication:

- Clear section headers with visual emphasis  
- Automatic variable labeling from dictionary  
- Clean display of missing values  
- Consistent styling throughout  
- Informative title and subtitle  
- Source note for transparency

## Best Practices

### Do’s

1.  **Use group headers thoughtfully** - Group related variables
    logically
2.  **Be consistent** - Apply the same styling approach across all
    tables in a document
3.  **Keep it readable** - Don’t over-style; subtle is often better
4.  **Test in context** - View tables in your final output format (HTML,
    PDF, Word)
5.  **Match document style** - Align table styling with overall document
    design

### Don’ts

1.  **Don’t overuse colors** - Too many colors create visual noise  
2.  **Don’t make headers too large** - Group headers should organize,
    not dominate  
3.  **Don’t mix styling approaches** - Be consistent within a document  
4.  **Don’t forget accessibility** - Ensure sufficient color contrast  
5.  **Don’t sacrifice readability** - Style should enhance, not hinder,
    comprehension

## Summary

sumExtras provides powerful tools for creating visually polished tables:

- **[`add_group_styling()`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md)** -
  Add text formatting (bold/italic) to group headers  
- **[`add_group_colors()`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md)** -
  Convenience function for group colors with automatic gt conversion  
- **[`get_group_rows()`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md)** -
  Identify group header rows for further styling  
- **[`use_jama_theme()`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md)** -
  Apply JAMA compact theme to gtsummary tables  
- **[`theme_gt_compact()`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md)** -
  Match gt table styling to gtsummary theme

Combine these with gt’s styling functions for complete control over
table appearance.

For more information:

- [`vignette("sumExtras-intro")`](https://kyleGrealis.com/sumExtras/articles/sumExtras-intro.md) -
  Getting started with sumExtras  
- [`vignette("labeling")`](https://kyleGrealis.com/sumExtras/articles/labeling.md) -
  Automatic variable labeling workflows  
- [`?add_group_styling`](https://kyleGrealis.com/sumExtras/reference/add_group_styling.md) -
  Function documentation  
- [`?add_group_colors`](https://kyleGrealis.com/sumExtras/reference/add_group_colors.md) -
  Function documentation  
- [`?get_group_rows`](https://kyleGrealis.com/sumExtras/reference/get_group_rows.md) -
  Function documentation  
- [`?use_jama_theme`](https://kyleGrealis.com/sumExtras/reference/use_jama_theme.md) -
  Function documentation  
- [`?theme_gt_compact`](https://kyleGrealis.com/sumExtras/reference/theme_gt_compact.md) -
  Function documentation

The styling system is designed to create professional tables
efficiently. Start with simple formatting, then add visual elements as
needed to enhance clarity and readability.
