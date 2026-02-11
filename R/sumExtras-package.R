#' @keywords internal
#' @aliases sumExtras-package
#'
#' @section Main Functions:
#' * [extras()] - Overall columns, p-values, clean styling
#' * [clean_table()] - Standardize missing value display
#' * [add_auto_labels()] - Automatic variable labeling
#' * [use_jama_theme()] - JAMA compact theme for gtsummary
#' * [theme_gt_compact()] - JAMA-style compact theme for gt
#' * [add_group_styling()] - Format grouped table headers
#' * [add_group_colors()] - Group colors with gt conversion
#'
#' @section Important Notes on Package Dependencies:
#' **gtsummary Internals:** This package depends on internal
#' structures of the gtsummary package (specifically
#' `tbl$call_list`, `tbl$inputs`, and `tbl$table_body`).
#' Compatibility is maintained where possible, but major
#' gtsummary updates may require sumExtras updates.
#'
#' **Minimum Versions:** Requires gtsummary >= 1.7.0 and
#' gt >= 0.9.0 for the necessary internal structures.
#'
#' **Testing:** Test your workflows after gtsummary
#' updates, especially major version changes.
#'
#' @seealso
#' * gtsummary package: <https://www.danieldsjoberg.com/gtsummary/>
#' * Package website: <https://www.kyleGrealis.com/sumExtras/>
#'
#' @examples
#' \donttest{
#' # Basic workflow with extras()
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt) |>
#'   extras()
#'
#' # Complete workflow with styling
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker, grade, stage)) |>
#'   extras() |>
#'   gtsummary::add_variable_group_header(
#'     header = "Patient Characteristics",
#'     variables = age:stage
#'   ) |>
#'   add_group_styling() |>
#'   add_group_colors()
#' }
#'
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
