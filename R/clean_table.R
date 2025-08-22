#' Clean and standardize missing value display in gtsummary tables
#'
#' @description Improves table readability by replacing various missing value 
#'   representations with a consistent "--" symbol. This makes it easier to 
#'   distinguish between actual data and missing/undefined values in summary 
#'   tables, creating a cleaner and more professional appearance.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#'
#' @returns A gtsummary table object with standardized missing value display
#'
#' @details The function uses `gtsummary::modify_table_body()` to transform 
#'   character columns and replace common missing value patterns with "--":
#'   * `"0 (NA%)"` - No events occurred and percentages cannot be calculated
#'   * `"NA (NA)"` - Completely missing data for both count and percentage
#'   * `"0 (0%)"` - Zero counts with zero percentage
#'   * `"NA (NA, NA)"` - Missing data with confidence intervals
#'   * `"NA, NA"` - Missing paired values (e.g., median and IQR)
#'   
#'   This standardization makes tables more scannable and reduces visual clutter
#'   from various "empty" data representations.
#' 
#' @importFrom dplyr across if_else mutate 
#' @importFrom gtsummary all_stat_cols modify_missing_symbol modify_table_body 
#'   tbl_regression tbl_summary
#' @importFrom stringr str_detect
#'
#' @examples
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
#'
#' @seealso 
#' * [gtsummary::modify_table_body()] for general table body modifications
#' * [extras()] which includes `clean_table()` in its styling pipeline
#'
#' @export
clean_table <- function(tbl) {
  tbl |>
    modify_table_body(
      ~ .x |> 
        mutate(across(all_stat_cols(), ~ {
          # Detect any statistic containing "NA" or "Inf" using word boundaries
          # \\b ensures to match complete words, avoiding false positives
          na_pattern <- "\\bNA\\b|\\bInf\\b|^0 \\(0%\\)$"
          if_else(str_detect(., na_pattern), NA_character_, .)
        }))
    ) |> 
    modify_missing_symbol(
      symbol = "---",
      columns = all_stat_cols(),
      rows = 
        (var_type %in% c("continuous", "dichotomous") & row_type == "label") |
        (var_type %in% c("continuous2", "categorical") & row_type == "level")
    )
}