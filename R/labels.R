#' Create a list of variable labels from a dataset using a dictionary
#' 
#' @description Creates a list of formula objects for variable labeling compatible with 
#'   `gtsummary::tbl_summary()`. Matches dataset variable names against a dictionary 
#'   tibble to generate labels. Requires a global `dictionary` object with `Variable` 
#'   and `Description` columns. Can be used standalone or internally by `add_auto_labels()`.
#' @param data A data frame or tibble containing variables to be labeled
#' 
#' @returns A list of formula objects in the format `variable ~ "Description"` 
#'   suitable for use in `gtsummary::tbl_summary(label = )`
#' 
#' @details The function requires a `dictionary` object in the global environment 
#'   structured as a tibble with columns:
#'   - `Variable`: Character column with exact variable names from datasets
#'   - `Description`: Character column with human-readable labels
#'   
#'   Only variables present in both the input data and dictionary will be included 
#'   in the output. Missing variables are silently ignored.
#' 
#' @importFrom dplyr filter
#' @importFrom purrr map2
#' @importFrom stats as.formula
#' @importFrom tibble tribble
#' 
#' @examples
#' \dontrun{
#' # Create required dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   'record_id', 'Participant ID',
#'   'age', 'Age at enrollment',
#'   'sex', 'Biological sex'
#' )
#' 
#' # Generate labels for a dataset
#' my_labels <- create_labels(study_data)
#' 
#' # Use directly in tbl_summary
#' study_data |> 
#'   gtsummary::tbl_summary(label = create_labels(study_data))
#' }
#' 
#' @seealso `add_auto_labels()` for automatic application to existing tbl_summary objects
#' 
#' @export
create_labels <- function(data) {
  # Extract variable names from the input dataset
  variables <- names(data)

  # Filter dictionary to only include variables present in the dataset
  # This prevents errors from dictionary entries not in the current data
  filtered_dict <- dictionary |> 
    filter(Variable %in% variables)
  
  # Create list of formulas using map2 for pairwise iteration
  # Format: variable ~ "Description" as required by gtsummary::tbl_summary()
  labels_list <- purrr::map2(
    filtered_dict$Variable,
    filtered_dict$Description,
    ~as.formula(paste(.x, '~', shQuote(.y)))
  )

  return(labels_list)
}




#' Add automatic labels from dictionary to a tbl_summary or tbl_regression object
#' 
#' @description Pipe a `gtsummary::tbl_summary` or `gtsummary::tbl_regression` 
#'   object to automatically add variable labels from a dictionary tibble. 
#'   Preserves any manual label overrides specified in the original table call 
#'   while adding dictionary labels for unlabeled variables. Requires a `dictionary` 
#'   object with `Variable` and `Description` columns.
#'   See `create_labels()` function for dictionary format requirements.
#' 
#' @param tbl A gtsummary table object created by `tbl_summary()` or `tbl_regression()`
#' 
#' @returns A gtsummary table object with automatic labels applied
#' 
#' @importFrom gtsummary modify_table_body tbl_regression tbl_summary tbl_svysummary
#' @importFrom dplyr left_join mutate select if_else
#' @importFrom purrr map_chr
#' @importFrom stats setNames
#' 
#' @examples
#' \dontrun{
#' # With tbl_summary
#' table1_data |> 
#'   gtsummary::tbl_summary(by = diagnosis) |> 
#'   add_auto_labels()
#'   
#' # With tbl_regression
#' lm(mpg ~ cyl + wt + hp, data = mtcars) |>
#'   gtsummary::tbl_regression() |>
#'   add_auto_labels()
#' }
#' 
#' @seealso `create_labels()` for dictionary requirements
#' 
#' @export
add_auto_labels <- function(tbl) {
  
  # Detect if this is a regression table
  is_regression_table <- inherits(tbl, 'tbl_regression') || 
                         inherits(tbl, 'tbl_uvregression')
  
  # For regression tables, use a different approach
  if (is_regression_table) {
    
    # Extract variable names from the table body
    table_vars <- unique(tbl$table_body$variable)
    
    # Filter dictionary to matching variables
    dict_filtered <- dictionary |>
      dplyr::filter(Variable %in% table_vars) |>
      dplyr::select(variable = Variable, auto_label = Description)
    
    # Apply labels by modifying the table body
    # Only update labels for variable header rows (row_type == 'label')
    result <- tbl |>
      modify_table_body(
        ~ .x |>
          dplyr::left_join(dict_filtered, by = 'variable') |>
          dplyr::mutate(
            label = dplyr::if_else(
              row_type == 'label' & !is.na(auto_label),
              auto_label,
              label
            )
          ) |>
          dplyr::select(-auto_label)
      )
    
    return(result)
  }
  
  # Original code for tbl_summary/tbl_svysummary tables
  original_data <- tbl$inputs$data
  
  is_survey_table <- inherits(tbl, 'tbl_svysummary') || 
                      any(grepl('svy', class(tbl))) ||
                      inherits(original_data, 'survey.design')
  
  if (inherits(original_data, 'survey.design')) {
    data_for_labels <- original_data$variables
  } else {
    data_for_labels <- original_data
  }
  
  included_vars <- tbl$inputs$include %||% names(data_for_labels)
  
  auto_labels_list <- create_labels(data_for_labels)
  
  auto_vars <- purrr::map_chr(auto_labels_list, ~ all.vars(.x)[1])
  keep_vars <- auto_vars %in% included_vars
  auto_labels_filtered <- auto_labels_list[keep_vars]
  
  override_labels <- tbl$inputs$label %||% list()
  
  if (length(override_labels) > 0) {
    existing_vars <- names(override_labels)
    
    filtered_auto_vars <- purrr::map_chr(auto_labels_filtered, ~ all.vars(.x)[1])
    
    keep_auto <- !filtered_auto_vars %in% existing_vars
    final_auto_labels <- auto_labels_filtered[keep_auto]
    
    if (length(final_auto_labels) > 0) {
      auto_as_named_list <- setNames(
        purrr::map_chr(final_auto_labels, ~ as.character(.x)[3]),
        purrr::map_chr(final_auto_labels, ~ all.vars(.x)[1])
      )
      combined_labels <- c(override_labels, auto_as_named_list)
    } else {
      combined_labels <- override_labels
    }
  } else {
    combined_labels <- auto_labels_filtered
  }
  
  args <- tbl$inputs
  args$label <- combined_labels
  
  if (is_survey_table) {
    do.call(tbl_svysummary, args)
  } else {
    do.call(tbl_summary, args)
  }
}
