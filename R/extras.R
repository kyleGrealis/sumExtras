#' Add standard styling and formatting to gtsummary tables
#'
#' @description Applies a consistent set of formatting options to gtsummary tables
#'   including overall column, bold labels, clean headers, and optional p-values.
#'   Streamlines the common workflow of adding multiple formatting functions.
#'   The function always succeeds by applying what works and warning about unsupported features.
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
#' * Bolds variable labels for emphasis (all table types)
#' * Removes the "Characteristic" header label (all table types)
#' * Adds an "Overall" column (only stratified summary tables)
#' * Optionally adds p-values (only stratified summary tables)
#' * Applies `clean_table()` styling (all table types)
#'
#' The function automatically detects whether the input table is stratified (has a `by`
#' argument) and what type of table it is (tbl_summary, tbl_regression, tbl_strata, etc.).
#'
#' For tables that don't support overall columns or p-values (non-stratified tables,
#' regression tables, or stacked tables), the function will issue a warning and
#' continue by applying only the universally supported features (bold_labels and
#' modify_header). This ensures the function always succeeds rather than failing
#' midway through the pipeline.
#'
#' If any individual formatting step fails (e.g., due to unexpected table structure),
#' the function will issue a warning and continue without that feature. This provides
#' robustness while keeping you informed of what was skipped.
#'
#' @importFrom gtsummary add_overall add_p all_tests bold_labels modify_header style_pvalue
#' @importFrom rlang %||% warn abort
#'
#' @section Table Type Support:
#' The function applies features based on table type and stratification:
#'
#' \itemize{
#'   \item \strong{bold_labels()} and \strong{modify_header()}: Work on all table types
#'   \item \strong{add_overall()}: Only works on stratified summary tables (tbl_summary with `by`)
#'   \item \strong{add_p()}: Only works on stratified summary tables (tbl_summary with `by`)
#' }
#'
#' \strong{Full feature support:} tbl_summary and tbl_svysummary with `by` argument
#'
#' \strong{Partial support (basic formatting only):} tbl_regression, tbl_strata, and
#' non-stratified tables. When applied to these table types and overall/pval = TRUE,
#' the function warns about unsupported features but applies the formatting that works.
#'
#' @examples
#' \donttest{
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
#'   add_group_styling()
#' }
#'
#' @seealso
#' * `gtsummary::add_overall()` for adding overall columns
#' * `gtsummary::add_p()` for adding p-values
#' * `clean_table()` for additional table styling
#'
#' @export
extras <- function(tbl, pval = TRUE, overall = TRUE, last = FALSE, .args = NULL) {

  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "extras_invalid_input"
    )
  }

  # Validate .args structure if provided
  if (!is.null(.args)) {
    if (!is.list(.args)) {
      rlang::abort(
        c(
          "`.args` must be a list.",
          "x" = sprintf("You supplied an object of class: %s", class(.args)[1]),
          "i" = "Use a named list like `list(pval = TRUE, overall = TRUE, last = FALSE)`."
        ),
        class = "extras_invalid_args"
      )
    }

    # Check for valid argument names
    valid_args <- c("pval", "overall", "last")
    invalid_args <- setdiff(names(.args), valid_args)

    if (length(invalid_args) > 0) {
      rlang::abort(
        c(
          "`.args` contains invalid argument names.",
          "x" = sprintf("Invalid argument(s): %s", paste(invalid_args, collapse = ", ")),
          "i" = sprintf("Valid arguments are: %s", paste(valid_args, collapse = ", "))
        ),
        class = "extras_invalid_arg_names"
      )
    }

    pval <- .args$pval %||% TRUE
    overall <- .args$overall %||% TRUE
    last <- .args$last %||% FALSE
  }

  # Detect if table is stratified (has a 'by' argument)
  # For tbl_summary objects, check if tbl$inputs$by exists and has length > 0
  # Using length() handles both NULL and character(0) cases
  is_stratified <- !is.null(tbl$inputs) && length(tbl$inputs$by) > 0

  # Warn about table types with limited feature support
  if ("tbl_regression" %in% class(tbl) && (overall || pval)) {
    rlang::warn(
      c(
        "Regression tables cannot have overall columns or p-values.",
        "i" = "The regression coefficients are the model results.",
        "i" = "Applying only `bold_labels()` and `modify_header(label ~ '')`."
      ),
      class = "extras_regression_unsupported_features"
    )
  }

  if ("tbl_strata" %in% class(tbl) && (overall || pval)) {
    rlang::warn(
      c(
        "`extras()` with stacked tables (tbl_strata) has limited support.",
        "i" = "Overall column and p-values are not supported for stacked tables.",
        "i" = "Applying only `bold_labels()` and `modify_header(label ~ '')`.",
        "i" = "For full features, apply `extras()` to each stratum before stacking."
      ),
      class = "extras_strata_limited_support"
    )
  }

  if (!is_stratified && (overall || pval)) {
    rlang::warn(
      c(
        "This table is not stratified (missing `by` argument).",
        "i" = "Overall column and p-values require stratification.",
        "i" = "Applying only `bold_labels()` and `modify_header(label ~ '')`."
      ),
      class = "extras_not_stratified"
    )
  }

  result <- tbl |>
    bold_labels() |>
    modify_header(label ~ "")

  # Add overall column and set default position to first column. This follows the
  # default from gtsummary::add_overall().
  # Only add if table is stratified, warn on failure rather than silently ignoring
  if (overall && is_stratified) {
    result <- tryCatch(
      {
        suppressMessages(result |> add_overall(last = last))
      },
      error = function(e) {
        rlang::warn(
          c(
            "Failed to add overall column.",
            "x" = sprintf("Error: %s", conditionMessage(e)),
            "i" = "Continuing without overall column."
          ),
          class = "extras_overall_failed"
        )
        result
      }
    )
  }

  # Only add p-values if table is stratified, warn on failure rather than silently ignoring
  if (pval && is_stratified) {
    result <- tryCatch(
      {
        suppressMessages(
          result |>
            add_p(
              pvalue_fun = ~ style_pvalue(.x, digits = 3),
              # Use Monte Carlo simulation for Fisher's exact test to prevent
              # computational errors and excessive runtime on large tables (r>2 or c>2).
              # Trades exact p-values for computational feasibility. Default B=2000
              # iterations provides adequate precision.
              # Reference: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/fisher.test.html
              test.args = all_tests("fisher.test") ~ list(simulate.p.value = TRUE)
            )
        )
      },
      error = function(e) {
        rlang::warn(
          c(
            "Failed to add p-values.",
            "x" = sprintf("Error: %s", conditionMessage(e)),
            "i" = "Continuing without p-values."
          ),
          class = "extras_pvalue_failed"
        )
        result
      }
    )
  }

  result |> clean_table()
}
