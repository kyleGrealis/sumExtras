#' Add standard styling and formatting to gtsummary tables
#'
#' @description Applies a consistent set of formatting
#'   options to gtsummary tables including overall column,
#'   bold labels, clean headers, and optional p-values.
#'   Wraps the common workflow of adding multiple formatting
#'   functions into one call. Always succeeds by applying
#'   what works and warning about the rest.
#'
#' @param tbl A gtsummary table object (e.g., from
#'   `tbl_summary()`, `tbl_regression()`)
#' @param pval Logical indicating whether to add p-values. Default is `TRUE`.
#'   When `TRUE`, uses gtsummary's default statistical tests (Kruskal-Wallis for
#'   continuous variables with 3+ groups, chi-square for categorical variables).
#' @param overall Logical indicating whether to add overall column
#' @param last Logical indicating if Overall column
#'   should be last. Aligns with default from
#'   \code{gtsummary::add_overall()}.
#' @param header Character string for the label column
#'   header. Default is `""` (blank). Use `"Characteristic"`
#'   or any custom text.
#' @param symbol Character string for missing value
#'   replacement in `clean_table()`. Default is `"---"`.
#'   Passed directly to `clean_table(symbol = ...)`.
#' @param .args Optional list of arguments to use
#'   instead of individual parameters.
#'   When provided, overrides `pval`, `overall`, and `last` arguments.
#' @param .add_p_args Optional named list of arguments
#'   to pass to `gtsummary::add_p()`. Allows customization
#'   of statistical tests and p-value formatting.
#'   User-provided arguments override the default arguments
#'   (`pvalue_fun` and `test.args`).
#'   See `gtsummary::add_p()` documentation for available arguments.
#'
#' @returns A gtsummary table object with standard formatting applied
#'
#' @details The function applies the following modifications (in order):
#' \enumerate{
#'   \item Bolds variable labels for emphasis (all table types)
#'   \item Removes the "Characteristic" header label (all table types)
#'   \item Adds an "Overall" column (only stratified summary tables)
#'   \item Optionally adds p-values with bold significance (only stratified
#'     summary tables)
#'   \item Applies automatic labels if options are set (see Options section)
#'   \item Applies `clean_table()` styling (all table types)
#' }
#'
#' The function automatically detects whether the input
#' table is stratified (has a `by` argument) and what
#' type of table it is (tbl_summary, tbl_regression,
#' tbl_strata, etc.).
#'
#' For tables that don't support overall columns or
#' p-values (non-stratified tables, regression tables,
#' or stacked tables), the function warns and applies
#' only basic formatting (bold_labels and modify_header).
#'
#' For merged tables (`tbl_merge`), call `extras()` on each
#' sub-table before merging — all formatting carries through.
#'
#' If any individual step fails (e.g., due to unexpected
#' table structure), the function warns and continues
#' without that feature.
#'
#' @section Options:
#' Set `options(sumExtras.auto_labels = TRUE)` for automatic labeling.
#' See `vignette("options")` for details.
#'
#' @section Pipeline Ordering:
#' Call `extras()` before `add_variable_group_header()` and
#' `add_group_colors()` last. See `vignette("sumExtras-intro")`.
#'
#' @importFrom gtsummary add_overall add_p all_tests
#'   bold_labels bold_p modify_header style_pvalue
#' @importFrom rlang %||% warn abort
#'
#' @section Table Type Support:
#' Full features (overall, p-values) require stratified `tbl_summary` or
#' `tbl_svysummary`. Regression and stacked tables get basic formatting
#' only (bold labels, clean header). Unsupported features trigger a warning.
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
#' # Custom header text
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras(header = "Variable")
#'
#' # Customize add_p() behavior
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras(.add_p_args = list(
#'     test = list(all_continuous() ~ "t.test"),
#'     pvalue_fun = ~ gtsummary::style_pvalue(.x, digits = 2)
#'   ))
#'
#' # Chain with other functions
#' # Create required dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "record_id", "Participant ID",
#'   "age", "Age at enrollment",
#'   "sex", "Biological sex"
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
extras <- function(
  tbl,
  pval = TRUE,
  overall = TRUE,
  last = FALSE,
  header = "",
  symbol = "---",
  .args = NULL,
  .add_p_args = NULL
) {
  # Capture whether user explicitly passed pval/overall before .args override
  pval_explicit <- !missing(pval)
  overall_explicit <- !missing(overall)

  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a table with `tbl_summary()` or similar."
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
          "i" = "Use a named list, e.g. `list(pval = TRUE)`."
        ),
        class = "extras_invalid_args"
      )
    }

    # Check for valid argument names
    valid_args <- c("pval", "overall", "last", "header", "symbol")
    invalid_args <- setdiff(names(.args), valid_args)

    if (length(invalid_args) > 0) {
      rlang::abort(
        c(
          "`.args` contains invalid argument names.",
          "x" = sprintf(
            "Invalid argument(s): %s",
            paste(invalid_args, collapse = ", ")
          ),
          "i" = sprintf(
            "Valid arguments are: %s",
            paste(valid_args, collapse = ", ")
          )
        ),
        class = "extras_invalid_arg_names"
      )
    }

    if (!is.null(.args$pval)) {
      pval <- .args$pval
      pval_explicit <- TRUE
    }
    if (!is.null(.args$overall)) {
      overall <- .args$overall
      overall_explicit <- TRUE
    }
    if (!is.null(.args$last)) {
      last <- .args$last
    }
    if (!is.null(.args$header)) {
      header <- .args$header
    }
    if (!is.null(.args$symbol)) {
      symbol <- .args$symbol
    }
  }

  # Detect if table is stratified (has a 'by' argument)
  # For tbl_summary objects, check if tbl$inputs$by exists and has length > 0
  # Using length() handles both NULL and character(0) cases
  is_stratified <- !is.null(tbl$inputs) && length(tbl$inputs$by) > 0

  # Detect regression, strata, and merged tables for special handling
  # tbl_strata inherits tbl_merge in gtsummary, so exclude it here
  is_regression <- inherits(tbl, "tbl_regression")
  is_strata <- inherits(tbl, "tbl_strata")
  is_merged <- inherits(tbl, "tbl_merge") && !is_strata

  # Inform merged table users to apply features before merging
  if (is_merged && (overall || pval)) {
    rlang::warn(
      c(
        "Overall columns and p-values cannot be added to merged tables.",
        "i" = "Add these features to each table before merging."
      ),
      class = "extras_merged_unsupported"
    )
  }

  # Compute once: user explicitly requested AND set to TRUE
  explicit_overall <- overall && overall_explicit
  explicit_pval <- pval && pval_explicit

  if (is_strata && (explicit_overall || explicit_pval)) {
    rlang::warn(
      c(
        "`extras()` with stacked tables (tbl_strata) has limited support.",
        "i" = "Overall and p-values are unsupported for stacked tables.",
        "i" = "Applying only `bold_labels()` and `modify_header()`.",
        "i" = "Apply `extras()` to each stratum before stacking."
      ),
      class = "extras_strata_limited_support"
    )
  }

  # Only warn if user explicitly requested features that can't apply
  # Skip for regression and strata tables — they have their own handling
  not_applicable <- !is_stratified && !is_regression && !is_merged &&
    !is_strata
  if (not_applicable && (explicit_overall || explicit_pval)) {
    rlang::warn(
      c(
        "This table is not stratified (missing `by` argument).",
        "i" = "Overall column and p-values require stratification.",
        "i" = "Applying only `bold_labels()` and `modify_header()`."
      ),
      class = "extras_not_stratified"
    )
  }

  result <- tryCatch(
    tbl |>
      bold_labels() |>
      modify_header(label = header),
    error = function(e) {
      rlang::warn(
        c(
          "Failed to apply bold labels or modify header.",
          "x" = conditionMessage(e),
          "i" = "Continuing with unmodified table."
        ),
        class = "extras_format_failed"
      )
      tbl
    }
  )

  # Regression tables already have p-values from the model;
  # bold them for consistent formatting
  if (is_regression) {
    result <- tryCatch(
      result |> bold_p(),
      error = function(e) result
    )
  }

  # Add overall column and set default position to first
  # column. This follows the default from add_overall().
  # Only add if stratified; warn on failure rather than
  # silently ignoring
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

  # Only add p-values if stratified; warn on failure
  # rather than silently ignoring
  if (pval && is_stratified) {
    # Define default add_p() arguments
    default_add_p_args <- list(
      pvalue_fun = ~ style_pvalue(.x, digits = 3),
      # Use Monte Carlo simulation for Fisher's exact test to prevent
      # computational errors and excessive runtime on large tables (r>2 or c>2).
      # Trades exact p-values for computational feasibility. Default B=2000
      # iterations provides adequate precision.
      # See ?fisher.test for details on simulation.
      test.args = all_tests("fisher.test") ~ list(simulate.p.value = TRUE)
    )

    # Validate .add_p_args if provided
    if (!is.null(.add_p_args)) {
      if (!is.list(.add_p_args)) {
        rlang::abort(
          c(
            "`.add_p_args` must be a list.",
            "x" = sprintf(
              "You supplied class: %s",
              class(.add_p_args)[1]
            ),
            "i" = "Use a named list, e.g. `list(test = ...)`."
          ),
          class = "extras_invalid_add_p_args"
        )
      }
      # Merge user args with defaults (user args override defaults)
      add_p_args <- utils::modifyList(default_add_p_args, .add_p_args)
    } else {
      add_p_args <- default_add_p_args
    }

    result <- tryCatch(
      {
        result <- suppressMessages(
          do.call(add_p, c(list(x = result), add_p_args))
        )
        result |> bold_p()
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

  # Auto-label if option is set
  if (isTRUE(getOption("sumExtras.auto_labels", default = FALSE))) {
    result <- tryCatch(
      {
        # Search caller's environment for dictionary and pass explicitly
        # (add_auto_labels() would search its own parent.frame which is
        # extras(), not the original caller)
        caller_env <- parent.frame()
        if (exists("dictionary", envir = caller_env)) {
          add_auto_labels(
            result,
            dictionary = get("dictionary", envir = caller_env)
          )
        } else {
          # No dictionary in environment -- use attributes only
          add_auto_labels(result, dictionary = NULL)
        }
      },
      error = function(e) {
        rlang::warn(
          c(
            "Auto-labeling failed.",
            "x" = conditionMessage(e),
            "i" = "Continuing without auto-labels."
          ),
          class = "extras_auto_labels_failed"
        )
        result
      }
    )
  }

  tryCatch(
    result |> clean_table(symbol = symbol),
    error = function(e) {
      rlang::warn(
        c(
          "Failed to clean table.",
          "x" = conditionMessage(e),
          "i" = "Continuing without clean_table()."
        ),
        class = "extras_clean_table_failed"
      )
      result
    }
  )
}
