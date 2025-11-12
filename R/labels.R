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
#' @importFrom rlang abort
#' 
#' @examples
#' \donttest{
#' # Create required dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment",
#'   "marker", "Marker Level (ng/mL)",
#'   "trt", "Treatment Group"
#' )
#'
#' # Generate labels for a dataset
#' my_labels <- create_labels(gtsummary::trial)
#'
#' # Use directly in tbl_summary
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(
#'     include = c(age, marker, trt),
#'     label = create_labels(gtsummary::trial)
#'   )
#' }
#' 
#' @seealso `add_auto_labels()` for automatic application to existing tbl_summary objects
#' 
#' @export
create_labels <- function(data) {
  # Validate data is a data frame
  if (!is.data.frame(data)) {
    rlang::abort(
      c(
        "`data` must be a data frame or tibble.",
        "x" = sprintf("You supplied an object of class: %s", class(data)[1]),
        "i" = "Supply a data frame containing variables to be labeled."
      ),
      class = "create_labels_invalid_data"
    )
  }

  # Validate dictionary exists in environment
  if (!exists("dictionary", envir = parent.frame())) {
    rlang::abort(
      c(
        "The `dictionary` object does not exist.",
        "i" = "Create a dictionary tibble with `Variable` and `Description` columns.",
        "i" = "Example: dictionary <- tibble::tribble(~Variable, ~Description, 'age', 'Age at Enrollment')"
      ),
      class = "create_labels_missing_dictionary"
    )
  }

  # Get dictionary from parent frame for validation
  dict <- get("dictionary", envir = parent.frame())

  # Validate dictionary is a data frame
  if (!is.data.frame(dict)) {
    rlang::abort(
      c(
        "`dictionary` must be a data frame or tibble.",
        "x" = sprintf("The dictionary object has class: %s", class(dict)[1]),
        "i" = "Create a tibble with `Variable` and `Description` columns."
      ),
      class = "create_labels_invalid_dictionary_type"
    )
  }

  # Validate dictionary has required columns
  required_cols <- c("Variable", "Description")
  missing_cols <- setdiff(required_cols, names(dict))

  if (length(missing_cols) > 0) {
    rlang::abort(
      c(
        "`dictionary` is missing required columns.",
        "x" = sprintf("Missing column(s): %s", paste(missing_cols, collapse = ", ")),
        "i" = "The dictionary must have both `Variable` and `Description` columns."
      ),
      class = "create_labels_missing_columns"
    )
  }

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
#' @importFrom rlang %||%
#' 
#' @examples
#' \donttest{
#' # Create a dictionary first
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment",
#'   "trt", "Treatment Group"
#' )
#'
#' # With tbl_summary
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
#'   add_auto_labels()
#'
#' # With tbl_regression
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "cyl", "Number of Cylinders",
#'   "wt", "Weight (1000 lbs)",
#'   "hp", "Horsepower"
#' )
#' lm(mpg ~ cyl + wt + hp, data = mtcars) |>
#'   gtsummary::tbl_regression() |>
#'   add_auto_labels()
#' }
#' 
#' @seealso `create_labels()` for dictionary requirements
#' 
#' @export
add_auto_labels <- function(tbl) {

  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a gtsummary table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "add_auto_labels_invalid_input"
    )
  }

  # Validate dictionary exists in environment
  if (!exists("dictionary", envir = parent.frame())) {
    rlang::abort(
      c(
        "The `dictionary` object does not exist.",
        "i" = "Create a dictionary tibble with `Variable` and `Description` columns.",
        "i" = "Example: dictionary <- tibble::tribble(~Variable, ~Description, 'age', 'Age at Enrollment')"
      ),
      class = "add_auto_labels_missing_dictionary"
    )
  }

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
      # Extract variable names and labels in separate steps to avoid double iteration
      vars <- purrr::map_chr(final_auto_labels, ~ all.vars(.x)[1])
      labels <- purrr::map_chr(final_auto_labels, ~ as.character(.x)[3])
      auto_as_named_list <- setNames(labels, vars)
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
