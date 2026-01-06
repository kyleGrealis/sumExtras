#' Apply compact JAMA-style theme to gt tables
#'
#' @description Applies a compact table theme to gt tables that matches the
#'   'jama' theme from gtsummary. This ensures visual consistency when mixing
#'   gtsummary tables (using `theme_gtsummary_compact("jama")`) with regular
#'   gt tables in the same document. The theme reduces padding, adjusts font
#'   sizes, and applies JAMA journal styling conventions.
#'
#' @param tbl A gt table object created with `gt::gt()`
#'
#' @returns A gt table object with compact JAMA-style formatting applied
#'
#' @details This function replicates the visual appearance of
#'   `gtsummary::theme_gtsummary_compact("jama")` for use with regular gt tables.
#'   Key styling includes:
#'   * Reduced font size (13px) for compact appearance
#'   * Minimal padding (1px) on all row types
#'   * Bold column headers and table titles
#'   * Hidden top and bottom table borders
#'   * Consistent spacing that matches JAMA journal standards
#'
#' @importFrom gt px tab_options
#' @importFrom rlang abort
#'
#' @examples
#' # Basic usage with a data frame
#' mtcars |>
#'   head() |>
#'   gt::gt() |>
#'   theme_gt_compact()
#'
#' # Combine with other gt functions
#' mtcars |>
#'   head() |>
#'   gt::gt() |>
#'   gt::tab_header(title = "Vehicle Data") |>
#'   theme_gt_compact()
#'
#' # Use alongside gtsummary tables for consistency
#' # Set gtsummary theme first
#' gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))
#'
#' # Then both tables will have matching appearance
#' summary_table <- gtsummary::trial |>
#'   gtsummary::tbl_summary()
#'
#' data_table <- gtsummary::trial |>
#'   head() |>
#'   gt::gt() |>
#'   theme_gt_compact()
#'
#' @seealso
#' * `gtsummary::theme_gtsummary_compact()` for gtsummary table themes
#' * `gtsummary::set_gtsummary_theme()` for setting global gtsummary themes
#' * `gt::tab_options()` for additional gt table styling options
#'
#' @export
theme_gt_compact <- function(tbl) {
  # Validate tbl is a gt object
  if (!inherits(tbl, "gt_tbl")) {
    rlang::abort(
      c(
        "`tbl` must be a gt table object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gt table using `gt::gt()` or convert a gtsummary table with `gtsummary::as_gt()`."
      ),
      class = "theme_gt_compact_invalid_input"
    )
  }

  tbl |>
   gt::tab_options(
     table.font.size = gt::px(13),
     data_row.padding = gt::px(1),
     summary_row.padding = gt::px(1),
     grand_summary_row.padding = gt::px(1),
     footnotes.padding = gt::px(1),
     source_notes.padding = gt::px(1),
     row_group.padding = gt::px(1),
     heading.title.font.weight = "bold",
     column_labels.font.weight = "bold",
     table.border.top.style = "hidden",
     table.border.bottom.style = "hidden"
   )
}




#' Apply styling to variable group headers in gtsummary tables
#'
#' @description Adds customizable formatting to variable group headers in
#'   gtsummary tables. Variable groups are created using
#'   `gtsummary::add_variable_group_header()` to organize variables into sections.
#'   This function enhances table readability by making group headers visually
#'   distinct from individual variable labels.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param format Character vector specifying text formatting. Options include
#'   `"bold"`, `"italic"`, or both. Default is `c("bold", "italic")`.
#' @param indent_labels Integer specifying indentation level (in spaces) for
#'   variable labels under group headers. Default is `0L` (left-aligned).
#'   Set to `4L` to preserve gtsummary's default group indentation, or use
#'   any non-negative integer for custom spacing.
#'
#' @returns A gtsummary table object with specified formatting applied to
#'   variable group headers
#'
#' @details The function targets rows where `row_type == 'variable_group'` and
#'   applies the specified text formatting to the label column. This is
#'   particularly useful for tables with multiple sections or stratified analyses
#'   where clear visual hierarchy improves interpretation.
#'
#'   By default, variable labels are left-aligned (`indent_labels = 0L`) to
#'   distinguish them from categorical levels and statistics. Use `indent_labels = 4L`
#'   to preserve the default gtsummary behavior where grouped variables are
#'   indented under their group headers.
#'
#' @importFrom gtsummary modify_table_styling modify_indent tbl_strata tbl_summary
#'
#' @examples
#' \donttest{
#' # Default formatting (bold and italic)
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker, grade)) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Patient Characteristics",
#'     variables = age:grade
#'   ) |>
#'   add_group_styling()
#'
#' # Bold only
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Demographics",
#'     variables = age:marker
#'   ) |>
#'   add_group_styling(format = "bold")
#'
#' # Multiple group headers
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Demographics",
#'     variables = age
#'   ) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Clinical Measures",
#'     variables = marker:response
#'   ) |>
#'   add_group_styling()
#'
#' # Custom indentation for grouped variables
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker)) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Patient Measures",
#'     variables = age:marker
#'   ) |>
#'   add_group_styling(indent_labels = 4L)  # Variables indented under header
#' }
#'
#' @seealso
#' * `gtsummary::modify_table_styling()` for general table styling options
#' * `gtsummary::add_variable_group_header()` for creating variable group headers
#'
#' @export
add_group_styling <- function(tbl, format = c('bold', 'italic'), indent_labels = 0L) {
  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "group_styling_invalid_input"
    )
  }

  # Validate format parameter
  if (!is.character(format)) {
    rlang::abort(
      c(
        "`format` must be a character vector.",
        "x" = sprintf("You supplied an object of class: %s", class(format)[1]),
        "i" = "Use a character vector like `c('bold', 'italic')` or `'bold'`."
      ),
      class = "group_styling_invalid_format_type"
    )
  }

  valid_formats <- c("bold", "italic")
  invalid_formats <- setdiff(format, valid_formats)

  if (length(invalid_formats) > 0) {
    rlang::abort(
      c(
        "`format` contains invalid formatting options.",
        "x" = sprintf("Invalid option(s): %s", paste(invalid_formats, collapse = ", ")),
        "i" = sprintf("Valid options are: %s", paste(valid_formats, collapse = ", "))
      ),
      class = "group_styling_invalid_format_value"
    )
  }

  # Validate indent_labels parameter
  if (!is.numeric(indent_labels) || length(indent_labels) != 1) {
    rlang::abort(
      c(
        "`indent_labels` must be a single integer.",
        "x" = sprintf("You supplied an object of class: %s with length %d",
                     class(indent_labels)[1], length(indent_labels)),
        "i" = "Use a single non-negative integer like `0L` or `4L`."
      ),
      class = "group_styling_invalid_indent_type"
    )
  }

  if (indent_labels < 0) {
    rlang::abort(
      c(
        "`indent_labels` must be non-negative.",
        "x" = sprintf("You supplied: %d", indent_labels),
        "i" = "Use a non-negative integer like `0L`, `2L`, or `4L`."
      ),
      class = "group_styling_invalid_indent_value"
    )
  }

  tbl |>
    modify_table_styling(
      columns = label,
      rows = row_type == 'variable_group',
      text_format = format
    ) |>
    # Modify the indentation of grouped variables. By default, gtsummary indents
    # all grouped variables by 4 spaces, which causes the variable label and
    # categorical levels to be aligned vertically. Setting indent_labels = 0L
    # (default) restores the original variable label indentation, distinguishing
    # variable labels from categorical levels. Use indent_labels = 4L to preserve
    # the default gtsummary grouping behavior.
    modify_indent(
      columns = "label",
      rows = row_type %in% 'label',
      indent = as.integer(indent_labels)
    )
}


#' Get row numbers of variable group headers for gt styling
#'
#' @description Extracts the row indices of variable group headers from a
#'   gtsummary table. This is useful for applying background colors or other
#'   gt-specific styling after converting a gtsummary table to gt with `as_gt()`.
#'
#' @param tbl A gtsummary table object with variable group headers created by
#'   `gtsummary::add_variable_group_header()`
#'
#' @returns An integer vector of row numbers where variable_group headers are located
#'
#' @details Variable group headers are identified by `row_type == 'variable_group'`
#'   in the table body. The returned row numbers can be used with `gt::tab_style()`
#'   to apply styling like background colors after converting to a gt table.
#'
#'   This function should be called BEFORE converting the table with `as_gt()`,
#'   as the row type information is only available in gtsummary table objects.
#'
#' @examples
#' \donttest{
#' # Create table with variable groups
#' my_tbl <- gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Demographics",
#'     variables = age
#'   ) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Clinical",
#'     variables = marker:stage
#'   ) |>
#'   add_group_styling()
#'
#' # Get group row numbers before conversion
#' group_rows <- get_group_rows(my_tbl)
#'
#' # Convert to gt and apply gray background
#' my_tbl |>
#'   gtsummary::as_gt() |>
#'   gt::tab_style(
#'     style = gt::cell_fill(color = "#E8E8E8"),
#'     locations = gt::cells_body(rows = group_rows)
#'   )
#' }
#'
#' @seealso
#' * `add_group_styling()` for applying text formatting to group headers
#' * `gtsummary::add_variable_group_header()` for creating variable groups
#' * `gt::tab_style()` for applying gt-specific styling
#'
#' @export
get_group_rows <- function(tbl) {
  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "get_group_rows_invalid_input"
    )
  }

  # Validate that table_body exists
  if (is.null(tbl$table_body)) {
    rlang::abort(
      c(
        "The gtsummary object does not contain a `table_body` component.",
        "i" = "This function requires a properly structured gtsummary table."
      ),
      class = "get_group_rows_missing_table_body"
    )
  }

  # Validate that row_type column exists
  if (!"row_type" %in% names(tbl$table_body)) {
    rlang::abort(
      c(
        "The table body does not contain a `row_type` column.",
        "i" = "This function requires a gtsummary table with row type information."
      ),
      class = "get_group_rows_missing_row_type"
    )
  }

  which(tbl$table_body$row_type == 'variable_group')
}


#' Add background colors to group headers with automatic gt conversion
#'
#' @description Convenience function that adds background colors to variable group
#'   headers and converts the table to gt. This is a terminal operation that combines
#'   `get_group_rows()`, `gtsummary::as_gt()`, and `gt::tab_style()` into a single
#'   pipeable function.
#'
#'   For text formatting (bold/italic), use `add_group_styling()` before calling this
#'   function. This composable design keeps each function focused on doing one thing well.
#'
#' @param tbl A gtsummary table object with variable group headers created by
#'   `gtsummary::add_variable_group_header()`
#' @param color Background color for group headers. Default `"#E8E8E8"` (light gray).
#'   Can be any valid CSS color (hex code, color name, rgb(), etc.).
#'
#' @returns A gt table object with colored group headers.
#'   **Note:** This is a terminal operation that converts to gt. You cannot pipe
#'   to additional gtsummary functions after calling this function.
#'
#' @details This function:
#'   1. Identifies group header rows with `get_group_rows()`
#'   2. Converts the table to gt with `gtsummary::as_gt()`
#'   3. Applies background color using `gt::tab_style()`
#'
#'   Since this function converts to gt, it should be used as the final styling
#'   step in your pipeline. Apply all gtsummary functions (like `modify_caption()`,
#'   `modify_footnote()`, etc.) and text formatting with `add_group_styling()`
#'   before calling `add_group_colors()`.
#'
#' @importFrom gtsummary as_gt
#' @importFrom gt tab_style cell_fill cells_body
#'
#' @examples
#' \donttest{
#' # Basic usage - text formatting then color
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras() |>
#'   gtsummary::add_variable_group_header(
#'     header = "Patient Characteristics",
#'     variables = age:stage
#'   ) |>
#'   add_group_styling() |>
#'   add_group_colors()
#'
#' # Custom color - light blue
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras() |>
#'   gtsummary::add_variable_group_header(
#'     header = "Baseline Characteristics",
#'     variables = age:marker
#'   ) |>
#'   add_group_styling() |>
#'   add_group_colors(color = "#E3F2FD")
#'
#' # Bold only formatting with custom color
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras() |>
#'   gtsummary::add_variable_group_header(
#'     header = "Clinical Measures",
#'     variables = marker:stage
#'   ) |>
#'   add_group_styling(format = "bold") |>
#'   add_group_colors(color = "#FFF9E6")
#'
#' # Multiple group headers
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras() |>
#'   gtsummary::add_variable_group_header(
#'     header = "Demographics",
#'     variables = age
#'   ) |>
#'   gtsummary::add_variable_group_header(
#'     header = "Disease Measures",
#'     variables = marker:response
#'   ) |>
#'   add_group_styling() |>
#'   add_group_colors(color = "#E8E8E8")
#' }
#'
#' @seealso
#' * `add_group_styling()` for text formatting only (stays gtsummary)
#' * `get_group_rows()` for identifying group header rows
#' * `gtsummary::add_variable_group_header()` for creating variable groups
#' * `gt::tab_style()` for additional gt-specific styling
#'
#' @export
add_group_colors <- function(tbl, color = "#E8E8E8") {
  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "add_group_colors_invalid_input"
    )
  }

  # Validate color is a character string
  if (!is.character(color) || length(color) != 1) {
    rlang::abort(
      c(
        "`color` must be a single character string.",
        "x" = sprintf("You supplied an object of class: %s with length %d",
                     class(color)[1], length(color)),
        "i" = "Use a valid CSS color like \"#E8E8E8\", \"lightgray\", or \"rgb(200,200,200)\"."
      ),
      class = "add_group_colors_invalid_color"
    )
  }

  # Get group rows while still gtsummary
  group_rows <- get_group_rows(tbl)

  # Convert to gt and apply background color
  tbl |>
    gtsummary::as_gt() |>
    gt::tab_style(
      style = gt::cell_fill(color = color),
      locations = gt::cells_body(rows = group_rows)
    )
}
