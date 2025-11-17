#' Standardize missing value display across all gtsummary table types
#'
#' @description Improves table readability by replacing various missing value
#'   representations with a consistent "--" symbol. This makes it easier to
#'   distinguish between actual data and missing/undefined values in summary
#'   tables, creating a cleaner and more professional appearance.
#'
#'   Works seamlessly with all gtsummary table types, including stacked tables
#'   (`tbl_strata`) and survey-weighted summaries (`tbl_svysummary`).
#'   Automatically handles tables with or without the standard `var_type` column.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_svysummary()`,
#'   `tbl_regression()`, or `tbl_strata()`)
#'
#' @returns A gtsummary table object with standardized missing value display
#'
#' @details The function uses `gtsummary::modify_table_body()` to transform
#'   character columns and replace common missing value patterns with "--":
#'   * `"0 (NA%)"` - No events occurred and percentages cannot be calculated
#'   * `"NA (NA)"` - Completely missing data for both count and percentage
#'   * `"0 (0%)"` - Zero counts with zero percentage
#'   * `"0% (0.000)"` - Zero percentage with decimal precision
#'   * `"NA (NA, NA)"` - Missing data with confidence intervals
#'   * `"NA, NA"` - Missing paired values (e.g., median and IQR)
#'
#'   This standardization makes tables more scannable and reduces visual clutter
#'   from various "empty" data representations.
#'
#'   Note: The function checks for the presence of `var_type` column before applying
#'   `modify_missing_symbol()`. This allows it to work seamlessly with `tbl_strata`
#'   objects which use `var_type_1`, `var_type_2`, etc. instead of `var_type`.
#'
#' @importFrom dplyr across if_else mutate
#' @importFrom gtsummary all_stat_cols modify_missing_symbol modify_table_body
#'   tbl_regression tbl_summary
#' @importFrom rlang abort
#'
#' @examples
#' \donttest{
#' # Basic usage - clean missing values in summary table
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   clean_table()
#'
#' # Often used as part of a styling pipeline
#' # Create a test dictionary for add_auto_labels():
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   'age', 'Age at enrollment',
#'   'stage', 'T Stage',
#'   'grade', 'Grade',
#'   'response', 'Tumor Response'
#' )
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   add_auto_labels() |>
#'   extras() |>
#'   clean_table()
#'
#' # Works with regression tables too
#' lm(age ~ trt + grade, data = gtsummary::trial) |>
#'   gtsummary::tbl_regression() |>
#'   clean_table()
#' }
#'
#' @seealso
#' * `gtsummary::modify_table_body()` for general table body modifications
#' * `extras()` which includes `clean_table()` in its styling pipeline
#'
#' @export
clean_table <- function(tbl) {
  # Validate input is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "clean_table_invalid_input"
    )
  }

  # Apply the NA pattern cleaning first
  tbl <- tbl |>
    modify_table_body(
      ~ .x |>
        mutate(across(all_stat_cols(), ~ {
          # Detect specific missing value patterns to replace with standardized symbol
          # Uses explicit pattern matching to avoid false positives
          na_pattern <- paste(c(
            "\\bNA\\b",                  # Literal NA
            "\\bInf\\b",                 # Literal Inf
            "-Inf",                      # Negative Inf
            "^0 \\(0%\\)$",              # Exact: 0 (0%)
            "^0% \\(0\\.0+\\)$",         # Exact: 0% (0.000)
            "^0 \\(NA%\\)$",             # Exact: 0 (NA%)
            "^NA \\(NA\\)$",             # Exact: NA (NA)
            "^NA \\(NA, NA\\)$",         # Exact: NA (NA, NA)
            "^0\\.0+ \\(0\\.0+%?\\)$",   # 0.00 (0.00) or 0.00 (0.00%)
            "^0\\.0+% \\(0\\.0+\\)$",    # 0.00% (0.00)
            "^NA, NA$"                   # Exact: NA, NA
          ), collapse = "|")
          if_else(grepl(na_pattern, ., perl = TRUE), NA_character_, .)
        }))
    )

  # Only apply modify_missing_symbol if var_type column exists
  # tbl_strata objects have var_type_1, var_type_2, etc. instead of var_type
  # so we skip this step for those table types
  if ("var_type" %in% names(tbl$table_body)) {
    tbl <- tbl |>
      modify_missing_symbol(
        symbol = "---",
        columns = all_stat_cols(),
        rows =
          (var_type %in% c("continuous", "dichotomous") & row_type == "label") |
          (var_type %in% c("continuous2", "categorical") & row_type == "level")
      )
  }

  tbl
}
