#' Apply compact JAMA-style theme to gt tables
#'
#' @description Applies a compact table theme to gt tables that matches the 
#'   'jama' theme from gtsummary. This ensures visual consistency when mixing 
#'   gtsummary tables (using `theme_gtsummary_compact("jama")`) with regular 
#'   gt tables in the same document. The theme reduces padding, adjusts font 
#'   sizes, and applies JAMA journal styling conventions.
#'
#' @param tbl A gt table object created with `gt::gt()`
#'
#' @returns A gt table object with compact JAMA-style formatting applied
#'
#' @details This function replicates the visual appearance of 
#'   `gtsummary::theme_gtsummary_compact("jama")` for use with regular gt tables.
#'   Key styling includes:
#'   * Reduced font size (13px) for compact appearance
#'   * Minimal padding (1px) on all row types
#'   * Bold column headers and table titles
#'   * Hidden top and bottom table borders
#'   * Consistent spacing that matches JAMA journal standards
#' 
#' @importFrom gt px tab_options
#'
#' @examples
#' # Basic usage with a data frame
#' mtcars |> 
#'   head() |> 
#'   gt::gt() |> 
#'   theme_gt_compact()
#'   
#' # Combine with other gt functions
#' mtcars |> 
#'   head() |> 
#'   gt::gt() |> 
#'   gt::tab_header(title = "Vehicle Data") |> 
#'   theme_gt_compact()
#'   
#' # Use alongside gtsummary tables for consistency
#' # Set gtsummary theme first
#' gtsummary::set_gtsummary_theme(gtsummary::theme_gtsummary_compact("jama"))
#' 
#' # Then both tables will have matching appearance
#' summary_table <- gtsummary::trial |> 
#'   gtsummary::tbl_summary()
#' 
#' data_table <- gtsummary::trial |> 
#'   head() |>
#'   gt::gt() |>
#'   theme_gt_compact()
#'
#' @seealso 
#' * [gtsummary::theme_gtsummary_compact()] for gtsummary table themes
#' * [gtsummary::set_gtsummary_theme()] for setting global gtsummary themes
#' * [gt::tab_options()] for additional gt table styling options
#'
#' @export
theme_gt_compact <- function(tbl) {
 tbl |>
   gt::tab_options(
     table.font.size = gt::px(13),
     data_row.padding = gt::px(1),
     summary_row.padding = gt::px(1),
     grand_summary_row.padding = gt::px(1),
     footnotes.padding = gt::px(1),
     source_notes.padding = gt::px(1),
     row_group.padding = gt::px(1),
     heading.title.font.weight = "bold",
     column_labels.font.weight = "bold",
     table.border.top.style = "hidden",
     table.border.bottom.style = "hidden"
   )
}




#' Apply styling to variable group headers in gtsummary tables
#' 
#' @description Adds customizable formatting to variable group headers in 
#'   gtsummary tables. Variable groups are created when using functions like 
#'   `tbl_strata()` or when variables are organized into sections. This function 
#'   enhances table readability by making group headers visually distinct from 
#'   individual variable labels.
#' 
#' @param tbl A gtsummary table object (e.g., from `tbl_summary()`, `tbl_regression()`)
#' @param format Character vector specifying text formatting. Options include 
#'   `"bold"`, `"italic"`, or both. Default is `c("bold", "italic")`.
#' 
#' @returns A gtsummary table object with specified formatting applied to 
#'   variable group headers
#' 
#' @details The function targets rows where `row_type == 'variable_group'` and 
#'   applies the specified text formatting to the label column. This is 
#'   particularly useful for tables with multiple sections or stratified analyses 
#'   where clear visual hierarchy improves interpretation.
#' 
#' @importFrom gtsummary modify_table_styling tbl_strata tbl_summary
#' 
#' @examples
#' # Default formatting (bold and italic)
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   group_styling()
#'   
#' # Bold only
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   group_styling(format = "bold")
#'   
#' # Italic only
#' gtsummary::trial |> 
#'   gtsummary::tbl_summary(by = trt) |> 
#'   group_styling(format = "italic")
#'   
#' # Useful with stratified tables
#' gtsummary::trial |> 
#'   gtsummary::tbl_strata(
#'     strata = grade,
#'     .tbl_fun = ~ .x |> 
#'       gtsummary::tbl_summary(by = trt)
#'   ) |> 
#'   group_styling(format = "bold")
#' 
#' @seealso 
#' * [gtsummary::modify_table_styling()] for general table styling options
#' * [gtsummary::tbl_strata()] for creating stratified tables with groups
#' 
#' @export
group_styling <- function(tbl, format = c('bold', 'italic')) {
  tbl |> 
    modify_table_styling(
      columns = label,
      rows = row_type == 'variable_group',
      text_format = format
    )
}