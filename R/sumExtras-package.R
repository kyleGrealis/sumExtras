#' @keywords internal
#' @aliases sumExtras-package
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' sumExtras: Extra Functions for 'gtsummary' Table Styling
#'
#' @description
#' Provides additional convenience functions for 'gtsummary'
#' (Sjoberg et al. (2021) <doi:10.32614/RJ-2021-053>) & 'gt' tables,
#' including automatic variable labeling from dictionaries, standardized
#' missing value display, and consistent formatting helpers for streamlined
#' table styling workflows.
#'
#' @section Main Functions:
#' * [extras()] - The signature function that adds overall columns, p-values, and clean styling
#' * [clean_table()] - Standardizes missing value display
#' * [add_auto_labels()] - Smart automatic variable labeling from dictionaries or label attributes
#' * [apply_labels_from_dictionary()] - Set label attributes on data for cross-package workflows
#' * [use_jama_theme()] - Apply JAMA compact theme to gtsummary tables
#' * [theme_gt_compact()] - JAMA-style compact themes for gt tables
#' * [add_group_styling()] - Enhanced text formatting for grouped tables
#' * [add_group_colors()] - Convenience function for group colors with automatic gt conversion
#'
#' @section Important Notes on Package Dependencies:
#' **gtsummary Internals:** This package depends on internal structures of the
#' gtsummary package (specifically `tbl$call_list`, `tbl$inputs`, and `tbl$table_body`).
#' While we make every effort to maintain compatibility, major updates to gtsummary
#' may require corresponding updates to sumExtras.
#'
#' **Minimum Versions:** Requires gtsummary >= 1.7.0 and gt >= 0.9.0. These minimum
#' versions ensure the necessary internal structures are available.
#'
#' **Testing:** We recommend testing your workflows after any gtsummary updates,
#' especially major version changes.
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
#' @name sumExtras-package
NULL
