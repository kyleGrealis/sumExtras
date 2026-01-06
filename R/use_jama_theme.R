#' Apply JAMA Compact Theme to gtsummary Tables
#'
#' @description Sets the global gtsummary theme to the JAMA (Journal of the
#'   American Medical Association) compact style. This is the recommended theme
#'   for use with sumExtras functions, providing professional medical journal
#'   formatting with reduced padding and consistent styling. The theme remains
#'   active for the entire R session or until changed with another theme.
#'
#' @returns Invisibly returns the theme list object from
#'   \code{gtsummary::theme_gtsummary_compact("jama")}. The theme is applied
#'   globally via \code{gtsummary::set_gtsummary_theme()}, affecting all
#'   subsequent gtsummary tables created in the session. A message is printed
#'   confirming the theme application.
#'
#' @details The JAMA compact theme implements formatting standards used by the
#'   Journal of the American Medical Association, making it ideal for:
#'   \itemize{
#'     \item Medical research manuscripts and reports
#'     \item Clinical trial summaries
#'     \item Academic publications requiring AMA style
#'     \item Professional presentations with clean, compact tables
#'   }
#'
#'   Key formatting features include:
#'   \itemize{
#'     \item Reduced font size (13px) for compact appearance
#'     \item Minimal cell padding (1px) to maximize information density
#'     \item Bold column headers and variable labels
#'     \item Clean borders following JAMA style guidelines
#'     \item Consistent alignment and spacing
#'   }
#'
#'   The function checks for the gtsummary package and will stop with an
#'   informative error if it is not installed. The theme is applied globally
#'   and will affect all gtsummary tables created after calling this function,
#'   including \code{tbl_summary()}, \code{tbl_regression()}, \code{tbl_cross()},
#'   \code{tbl_strata()}, and related functions.
#'
#'   For visual consistency with regular gt tables, use \code{theme_gt_compact()}
#'   which replicates the same styling for non-gtsummary tables.
#'
#' @importFrom gtsummary theme_gtsummary_compact set_gtsummary_theme
#'
#' @examples
#' \donttest{
#' # Apply theme at the start of your analysis
#' use_jama_theme()
#'
#' # All subsequent gtsummary tables will use JAMA formatting
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt)
#'
#' # Works with all gtsummary table types
#' lm(age ~ trt + grade, data = gtsummary::trial) |>
#'   gtsummary::tbl_regression()
#'
#' # Combine with sumExtras styling functions
#' use_jama_theme()
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker, stage)) |>
#'   extras() |>
#'   add_group_styling()
#'
#' # Reset to default theme if needed
#' gtsummary::reset_gtsummary_theme()
#' }
#'
#' @seealso
#' * \code{\link{theme_gt_compact}} for applying JAMA-style formatting to regular gt tables
#' * \code{\link{extras}} for standard sumExtras table formatting
#' * \code{gtsummary::theme_gtsummary_compact()} for other compact theme options
#' * \code{gtsummary::set_gtsummary_theme()} for setting custom themes
#' * \code{gtsummary::reset_gtsummary_theme()} for resetting to default theme
#'
#' @family theme functions
#' @export
use_jama_theme <- function() {
  if (!requireNamespace("gtsummary", quietly = TRUE)) {
    stop("Package 'gtsummary' is required. Please install it.", call. = FALSE)
  }

  theme <- gtsummary::theme_gtsummary_compact("jama")
  gtsummary::set_gtsummary_theme(theme)
  message("Applied JAMA compact theme to {gtsummary}")
  invisible(theme)
}
