#' Add standard styling and formatting to gtsummary tables
#'
#' @description Applies a consistent set of formatting options to gtsummary tables
#'   including overall column, bold labels, clean headers, and optional p-values.
#'   Streamlines the common workflow of adding multiple formatting functions.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param pval Logical indicating whether to add p-values. Default is `TRUE`.
#'   When `TRUE`, uses gtsummary's default statistical tests (Kruskal-Wallis for 
#'   continuous variables with 3+ groups, chi-square for categorical variables).
#' @param overall Logical indicating whether to add overall column
#' @param last Logical indicating if Overall column should be last. Aligns with default
#'   from \code{gtsummary::add_overall()}.
#' @param .args Optional list of arguments to use instead of individual parameters.
#'   When provided, overrides `pval`, `overall`, and `last` arguments.
#'
#' @returns A gtsummary table object with standard formatting applied
#'
#' @details The function applies the following modifications:
#' * Adds an "Overall" column as the last column (if `overall = TRUE`)
#' * Bolds variable labels for emphasis
#' * Removes the "Characteristic" header label
#' * Applies `clean_table()` styling
#' * Optionally adds p-values with gtsummary's default statistical tests
#' 
#' @importFrom gtsummary add_overall add_p bold_labels modify_header style_pvalue
#'
#' @examples
#' \dontrun{
#' # With p-values (default)
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   extras()
#' 
#' # Using .args list
#' extra_args <- list(pval = TRUE, overall = TRUE, last = FALSE)
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras(.args = extra_args)
#'   
#' # Without p-values
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   extras(pval = FALSE)
#'   
#' # Chain with other functions
#' # Create required dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   'record_id', 'Participant ID',
#'   'age', 'Age at enrollment',
#'   'sex', 'Biological sex'
#' )
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   add_auto_labels() |> 
#'   extras(pval = TRUE) |> 
#'   group_styling()
#' }
#' 
#' @seealso 
#' * `gtsummary::add_overall()` for adding overall columns
#' * `gtsummary::add_p()` for adding p-values
#' * `clean_table()` for additional table styling
#'
#' @export
extras <- function(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL) {

  # If .args is provided, use those values; otherwise use explicit arguments
  if (!is.null(.args)) {
    pval <- .args$pval %||% TRUE
    overall <- .args$overall %||% TRUE
    last <- .args$last %||% FALSE
  }
  
  result <- tbl |>
    bold_labels() |> 
    modify_header(label ~ "")

  # Add overall column and set default position to first column. THis follows the 
  # default from gtsummary::add_overall().
  if (overall) result <- result |> add_overall(last = last)
  
  if (pval) {
    result <- result |> 
      add_p(
        pvalue_fun = ~ style_pvalue(.x, digits = 3),
        test.args = all_tests("fisher.test") ~ list(simulate.p.value = TRUE)
      )
  }
  
  result |> clean_table()
}
