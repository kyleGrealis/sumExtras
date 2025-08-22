#' Add standard styling and formatting to gtsummary tables
#'
#' @description Applies a consistent set of formatting options to gtsummary tables
#'   including overall column, bold labels, clean headers, and optional p-values.
#'   Streamlines the common workflow of adding multiple formatting functions.
#'
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param pval Logical indicating whether to add p-values. Default is `TRUE`.
#'   When `TRUE`, adds Kruskal-Wallis tests for continuous variables and 
#'   chi-square tests for categorical variables.
#' @param overall Logical indicating whether to add overall column
#'
#' @returns A gtsummary table object with standard formatting applied
#'
#' @details The function applies the following modifications:
#' * Adds an "Overall" column as the last column
#' * Bolds variable labels for emphasis
#' * Removes the "Characteristic" header label
#' * Applies `clean_table()` styling
#' * Optionally adds p-values with appropriate statistical tests
#' 
#' @importFrom gtsummary add_overall add_p all_categorical all_continuous bold_labels 
#'   modify_header style_pvalue
#'
#' @examples
#' # With p-values (default)
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   extras()
#'   
#' # Without p-values
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   extras(pval = FALSE)
#'   
#' # Chain with other functions
#' \dontrun{
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   add_auto_labels() |> 
#'   extras(pval = TRUE) |> 
#'   group_styling()
#' }
#' 
#' @seealso 
#' * [gtsummary::add_overall()] for adding overall columns
#' * [gtsummary::add_p()] for adding p-values
#' * [clean_table()] for additional table styling
#'
#' @export
extras <- function(tbl, pval = TRUE, overall = TRUE) {
  result <- tbl |>
    bold_labels() |> 
    modify_header(label ~ "")

  if (overall) {
    result <- result |> 
      add_overall(last = TRUE)
  }
  
  if (pval) {
    result <- result |> 
      add_p(
        test = list(
          all_continuous() ~ "kruskal.test",
          all_categorical() ~ "chisq.test"
        ),
        pvalue_fun = ~ style_pvalue(.x, digits = 3)
      )
  }
  
  result |> clean_table()
}
