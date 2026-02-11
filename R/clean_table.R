#' Standardize missing value display across all gtsummary table types
#'
#' @description Replaces various missing value representations
#'   with a consistent symbol (default `"---"`) so it is
#'   easier to tell actual data from missing or undefined values.
#'
#'   Works with all gtsummary table types, including stacked
#'   tables (`tbl_strata`) and survey-weighted summaries
#'   (`tbl_svysummary`). Handles tables with or without the
#'   standard `var_type` column.
#'
#' @param tbl A gtsummary table object (e.g., from
#'   `tbl_summary()`, `tbl_svysummary()`, `tbl_regression()`,
#'   or `tbl_strata()`)
#' @param symbol Character string to replace missing values
#'   with. Default is `"---"` (em-dash style). Common
#'   alternatives: `"\u2014"` (em-dash), `"\u2013"`
#'   (en-dash), `"--"`, or `"N/A"`.
#'
#' @returns A gtsummary table object with standardized missing value display
#'
#' @details The function uses `gtsummary::modify_table_body()` to transform
#'   character columns and replace missing, undefined, and zero-valued
#'   patterns with a consistent symbol. Matched patterns include:
#'   * Literal `NA` and `Inf` / `-Inf` values
#'   * Count/percent pairs: `"0 (0%)"`, `"0 (NA%)"`, `"0 (NA)"`, `"NA (0)"`,
#'     `"NA (NA)"`
#'   * Decimal variants: `"0.00 (0.00)"`, `"0.00% (0.00)"`, `"0% (0.000)"`
#'   * Paired values: `"NA, NA"`
#'   * Confidence intervals: `"NA (NA, NA)"`, `"0% (0.000) (0%, 0%)"`,
#'     `"0.00 (0.00) (0.00, 0.00)"`, and similar zero-CI patterns
#'
#'   Replacing these patterns with a single symbol keeps
#'   the table easier to read.
#'
#'   Note: The function checks for the presence of `var_type`
#'   column before applying `modify_missing_symbol()`. This
#'   allows it to work with `tbl_strata` objects which use
#'   `var_type_1`, `var_type_2`, etc. instead of `var_type`.
#'
#' @importFrom dplyr across if_else mutate
#' @importFrom gtsummary all_stat_cols modify_missing_symbol modify_table_body
#' @importFrom rlang abort
#'
#' @examples
#' \donttest{
#' # Basic usage - clean missing values in summary table
#' demo_trial <- gtsummary::trial |>
#'   dplyr::mutate(
#'     age = dplyr::if_else(trt == "Drug B", 0, age),
#'     marker = dplyr::if_else(trt == "Drug A", NA, marker)
#'   ) |>
#'   dplyr::select(trt, age, marker)
#'
#' demo_trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   clean_table()
#'
#' # Used inside extras() automatically
#' demo_trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras()
#'
#' # Custom missing symbol
#' demo_trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   clean_table(symbol = "???")
#' }
#'
#' @seealso
#' * `gtsummary::modify_table_body()` for general table body modifications
#' * `extras()` which includes `clean_table()` in its styling pipeline
#'
#' @export
clean_table <- function(tbl, symbol = "---") {
  # Validate symbol is a single character string
  if (!is.character(symbol) || length(symbol) != 1) {
    rlang::abort(
      c(
        "`symbol` must be a single character string.",
        "x" = sprintf(
          "You supplied %s of length %d.",
          class(symbol)[1], length(symbol)
        ),
        "i" = 'Use a string like `"---"` or `"\\u2014"`.'
      ),
      class = "clean_table_invalid_symbol"
    )
  }

  # Validate input is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a table with `tbl_summary()` or `tbl_regression()`."
      ),
      class = "clean_table_invalid_input"
    )
  }

  # Apply the NA pattern cleaning first
  tbl <- tbl |>
    modify_table_body(
      ~ .x |>
        mutate(across(all_stat_cols(), ~ {
          # Detect missing value patterns to replace with "--"
          # Uses explicit pattern matching to avoid false positives
          na_pattern <- paste(c(
            "\\bNA\\b", # Literal NA
            "\\bInf\\b", # Literal Inf
            "-Inf", # Negative Inf
            "^0 \\(0\\)$", # Exact: 0 (0)
            "^0 \\(0%\\)$", # Exact: 0 (0%)
            "^0% \\(0\\.0+\\)$", # Exact: 0% (0.000)
            "^0 \\(NA%\\)$", # Exact: 0 (NA%)
            "^0 \\(NA\\)$", # Exact: 0 (NA)
            "^NA \\(0\\)$", # Exact: NA (0)
            "^NA \\(NA\\)$", # Exact: NA (NA)
            "^NA \\(NA, NA\\)$", # Exact: NA (NA, NA)
            "^0\\.0+ \\(0\\.0+%?\\)$", # 0.00 (0.00) or 0.00 (0.00%)
            "^0\\.0+% \\(0\\.0+\\)$", # 0.00% (0.00)
            "^NA, NA$", # Exact: NA, NA
            # Patterns with confidence intervals
            # 0% (0.000) (0%, 0%)
            "^0% \\(0\\.0+\\) \\(0%?, 0%?\\)$",
            # 0.00% (0.00) (0.00%, 0.00%)
            "^0\\.0+% \\(0\\.0+\\) \\(0\\.0+%?, 0\\.0+%?\\)$",
            # 0 (0.00) (0, 0)
            "^0 \\(0\\.0+\\) \\(0, 0\\)$",
            # 0.00 (0.00) (0.00, 0.00)
            "^0\\.0+ \\(0\\.0+\\) \\(0\\.0+, 0\\.0+\\)$",
            # Catch any trailing CI with all zeros
            "\\(0%?, 0%?\\)$",
            "\\(0\\.0+%?, 0\\.0+%?\\)$"
          ), collapse = "|")
          if_else(grepl(na_pattern, ., perl = TRUE), NA_character_, .)
        }))
    )

  # Apply modify_missing_symbol to replace NA values with the symbol.
  # When var_type exists, target specific row types for precision.
  # When it doesn't (tbl_merge, tbl_strata), apply to all stat columns.
  if ("var_type" %in% names(tbl$table_body)) {
    tbl <- tbl |>
      modify_missing_symbol(
        symbol = symbol,
        columns = all_stat_cols(),
        rows =
          (var_type %in% c("continuous", "dichotomous") &
           row_type == "label") |
          (var_type %in% c("continuous2", "categorical") &
           row_type == "level")
      )
  } else {
    tbl <- tbl |>
      modify_missing_symbol(
        symbol = symbol,
        columns = all_stat_cols(),
        rows = TRUE
      )
  }

  tbl
}
