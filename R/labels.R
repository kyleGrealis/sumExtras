#' Create a list of variable labels from a dataset using a dictionary
#'
#' @description Creates a list of formula objects for variable labeling compatible with
#'   `gtsummary::tbl_summary()`. Matches dataset variable names against a dictionary
#'   tibble to generate labels. The dictionary can be passed explicitly as a parameter
#'   or will be searched for in the calling environment.
#'
#' @param data A data frame or tibble containing variables to be labeled
#' @param dictionary Optional. A data frame or tibble with `Variable` and `Description`
#'   columns. If not provided, the function will search for a `dictionary` object in
#'   the calling environment.
#'
#' @returns A list of formula objects in the format `variable ~ "Description"`
#'   suitable for use in `gtsummary::tbl_summary(label = )`
#'
#' @details The dictionary must be structured as a data frame with columns:
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
#' # Create a dictionary
#' my_dict <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment",
#'   "marker", "Marker Level (ng/mL)",
#'   "trt", "Treatment Group"
#' )
#'
#' # Pass dictionary explicitly (recommended)
#' my_labels <- create_labels(gtsummary::trial, dictionary = my_dict)
#'
#' # Or use without passing (searches calling environment)
#' dictionary <- my_dict
#' my_labels <- create_labels(gtsummary::trial)
#'
#' # Use directly in tbl_summary
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(
#'     include = c(age, marker, trt),
#'     label = create_labels(gtsummary::trial, dictionary = my_dict)
#'   )
#' }
#'
#' @family labeling functions
#' @seealso `add_auto_labels()` for automatic application to existing tbl_summary objects
#'
#' @export
create_labels <- function(data, dictionary = NULL) {
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

  # If dictionary not provided, try to find it in calling environment
  if (is.null(dictionary)) {
    if (!exists("dictionary", envir = parent.frame())) {
      rlang::abort(
        c(
          "No `dictionary` provided and none found in calling environment.",
          "i" = "Pass dictionary explicitly: create_labels(data, dictionary = my_dict)",
          "i" = "Or ensure a `dictionary` object exists in your environment.",
          "i" = "Example: dictionary <- tibble::tribble(~Variable, ~Description, 'age', 'Age at Enrollment')"
        ),
        class = "create_labels_missing_dictionary"
      )
    }
    dictionary <- get("dictionary", envir = parent.frame())
  }

  # Validate dictionary is a data frame
  if (!is.data.frame(dictionary)) {
    rlang::abort(
      c(
        "`dictionary` must be a data frame or tibble.",
        "x" = sprintf("The dictionary object has class: %s", class(dictionary)[1]),
        "i" = "Create a tibble with `Variable` and `Description` columns."
      ),
      class = "create_labels_invalid_dictionary_type"
    )
  }

  # Validate dictionary has required columns
  required_cols <- c("Variable", "Description")
  missing_cols <- setdiff(required_cols, names(dictionary))

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
#'   while adding dictionary labels for unlabeled variables. The dictionary can
#'   be passed explicitly or will be searched for in the calling environment.
#'   See `create_labels()` function for dictionary format requirements.
#'
#' @param tbl A gtsummary table object created by `tbl_summary()` or `tbl_regression()`
#' @param dictionary Optional. A data frame or tibble with `Variable` and `Description`
#'   columns. If not provided, the function will search for a `dictionary` object in
#'   the calling environment.
#'
#' @returns A gtsummary table object with automatic labels applied
#'
#' @importFrom gtsummary modify_table_body
#' @importFrom dplyr left_join mutate select if_else filter
#' @importFrom purrr map_chr
#' @importFrom stats setNames
#' @importFrom rlang %||%
#'
#' @examples
#' \donttest{
#' # Create a dictionary
#' my_dict <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment",
#'   "trt", "Treatment Group"
#' )
#'
#' # With tbl_summary (pass dictionary explicitly - recommended)
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
#'   add_auto_labels(dictionary = my_dict)
#'
#' # Or use without passing (searches calling environment)
#' dictionary <- my_dict
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
#'   add_auto_labels()
#'
#' # With tbl_regression
#' reg_dict <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "cyl", "Number of Cylinders",
#'   "wt", "Weight (1000 lbs)",
#'   "hp", "Horsepower"
#' )
#' lm(mpg ~ cyl + wt + hp, data = mtcars) |>
#'   gtsummary::tbl_regression() |>
#'   add_auto_labels(dictionary = reg_dict)
#' }
#'
#' @family labeling functions
#' @seealso `create_labels()` for dictionary requirements
#'
#' @export
add_auto_labels <- function(tbl, dictionary = NULL) {

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

  # If dictionary not provided, try to find it in calling environment
  if (is.null(dictionary)) {
    if (!exists("dictionary", envir = parent.frame())) {
      rlang::abort(
        c(
          "No `dictionary` provided and none found in calling environment.",
          "i" = "Pass dictionary explicitly: add_auto_labels(tbl, dictionary = my_dict)",
          "i" = "Or ensure a `dictionary` object exists in your environment.",
          "i" = "Example: dictionary <- tibble::tribble(~Variable, ~Description, 'age', 'Age at Enrollment')"
        ),
        class = "add_auto_labels_missing_dictionary"
      )
    }
    dictionary <- get("dictionary", envir = parent.frame())
  }

  # Validate dictionary structure (use same validation as create_labels)
  if (!is.data.frame(dictionary)) {
    rlang::abort(
      c(
        "`dictionary` must be a data frame or tibble.",
        "x" = sprintf("The dictionary object has class: %s", class(dictionary)[1]),
        "i" = "Create a tibble with `Variable` and `Description` columns."
      ),
      class = "add_auto_labels_invalid_dictionary"
    )
  }

  # Validate dictionary has required columns
  required_cols <- c("Variable", "Description")
  missing_cols <- setdiff(required_cols, names(dictionary))

  if (length(missing_cols) > 0) {
    rlang::abort(
      c(
        "`dictionary` is missing required columns.",
        "x" = sprintf("Missing column(s): %s", paste(missing_cols, collapse = ", ")),
        "i" = "The dictionary must have both `Variable` and `Description` columns."
      ),
      class = "add_auto_labels_invalid_dictionary"
    )
  }

  # Extract variable names from the table body
  table_vars <- unique(tbl$table_body$variable)

  # Filter dictionary to matching variables
  dict_filtered <- dictionary |>
    dplyr::filter(Variable %in% table_vars) |>
    dplyr::select(variable = Variable, auto_label = Description)

  # Apply labels by modifying the table body
  # Only update labels for variable header rows (row_type == 'label')
  # This approach works for ALL gtsummary table types and preserves all modifications
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
