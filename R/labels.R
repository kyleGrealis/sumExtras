#' Add automatic labels from dictionary to a gtsummary table
#'
#' @description Applies variable labels from a dictionary or label
#'   attributes to `tbl_summary`, `tbl_svysummary`, or `tbl_regression` objects.
#'   Preserves manual label overrides set in the original table
#'   call. The dictionary can be passed explicitly or will be
#'   searched for in the calling environment. If no dictionary
#'   is found, the function reads label attributes from the
#'   underlying data.
#'
#' @param tbl A gtsummary table object created by
#'   `tbl_summary()`, `tbl_svysummary()`, or
#'   `tbl_regression()`.
#' @param dictionary A data frame or tibble with `Variable`
#'   and `Description` columns. If not provided (missing),
#'   the function will search for a `dictionary` object in
#'   the calling environment. If no dictionary is found, the
#'   function will attempt to read label attributes from the
#'   data. Set to `NULL` explicitly to skip dictionary search
#'   and only use attributes.
#'
#' @returns A gtsummary table object with labels applied. Manual labels set via
#'   `label = list(...)` in the original table call are always preserved.
#'
#' @details
#' ## Label Priority Hierarchy
#'
#' The function applies labels according to this priority (highest to lowest):
#'
#' 1. **Manual labels** - Labels set via `label = list(...)`
#'    in `tbl_summary()` etc. are always preserved
#' 2. **Attribute labels** - Labels from `attr(data$var, "label")`
#' 3. **Dictionary labels** - Labels from the dictionary data frame
#' 4. **Default** - If no label source is available, uses variable name
#'
#' ## Dictionary Format
#'
#' The dictionary must be a data frame with columns:
#' - `Variable`: Character column with exact variable names from datasets
#' - `Description`: Character column with human-readable labels
#'
#' ## Label Attributes
#'
#' The function reads label attributes from data using
#' `attr(data$var, "label")`, following the same convention
#' used by **haven**, **Hmisc**, and **ggplot2 4.0+**.
#' If your data already has labels (from imported files,
#' other packages, or manual assignment), this function
#' picks them up automatically.
#'
#' ## Implementation Note
#'
#' **This function relies on internal gtsummary structures** (`tbl$call_list`,
#' `tbl$inputs`, `tbl$table_body`) to detect manually set labels. Major updates
#' to gtsummary may require corresponding updates to sumExtras.
#' Requires gtsummary >= 1.7.0.
#'
#'
#' @importFrom gtsummary modify_table_body
#' @importFrom dplyr distinct left_join mutate select filter case_when
#' @importFrom stats na.omit
#' @importFrom rlang %||% abort warn
#'
#' @examples
#' \donttest{
#' # Create a dictionary
#' my_dict <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment",
#'   "trt", "Treatment Group",
#'   "grade", "Tumor Grade"
#' )
#'
#' # Basic usage: pass dictionary explicitly
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
#'   add_auto_labels(dictionary = my_dict)
#'
#' # Automatic dictionary search (dictionary in environment)
#' dictionary <- my_dict
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, grade)) |>
#'   add_auto_labels() # Finds dictionary automatically
#'
#' # Working with pre-labeled data (no dictionary needed)
#' labeled_data <- gtsummary::trial
#' attr(labeled_data$age, "label") <- "Patient Age (years)"
#' attr(labeled_data$marker, "label") <- "Marker Level (ng/mL)"
#'
#' labeled_data |>
#'   gtsummary::tbl_summary(include = c(age, marker)) |>
#'   add_auto_labels() # Reads from label attributes
#'
#' # Manual overrides always win
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(
#'     by = trt,
#'     include = c(age, grade),
#'     label = list(age ~ "Custom Age Label") # Manual override
#'   ) |>
#'   add_auto_labels(dictionary = my_dict) # grade: dict, age: manual
#'
#' }
#'
#' @seealso
#' * `gtsummary::modify_table_body()` for advanced table
#'   customization
#'
#' @export
add_auto_labels <- function(tbl, dictionary) {
  # Validate tbl is a gtsummary object
  if (!inherits(tbl, "gtsummary")) {
    rlang::abort(
      c(
        "`tbl` must be a gtsummary object.",
        "x" = sprintf("You supplied an object of class: %s", class(tbl)[1]),
        "i" = "Create a table using `tbl_summary()` or `tbl_regression()`."
      ),
      class = "add_auto_labels_invalid_input"
    )
  }

  # Determine if dictionary argument was explicitly provided
  dict_missing <- missing(dictionary)
  dict_is_null <- !dict_missing && is.null(dictionary)

  # Step 1: Try to get dictionary
  has_dictionary <- FALSE
  dict_filtered <- NULL

  if (!dict_is_null) { # User didn't explicitly set dictionary = NULL
    if (dict_missing) {
      # Try to find dictionary in calling environment
      if (exists("dictionary", envir = parent.frame())) {
        dictionary <- get("dictionary", envir = parent.frame())
        has_dictionary <- TRUE
      }
    } else {
      # Dictionary was provided explicitly
      has_dictionary <- TRUE
    }

    # Validate and filter dictionary if we have one
    if (has_dictionary) {
      # Validate dictionary structure
      if (!is.data.frame(dictionary)) {
        rlang::abort(
          c(
            "`dictionary` must be a data frame or tibble.",
            "x" = sprintf(
              "The dictionary object has class: %s",
              class(dictionary)[1]
            ),
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
            "x" = sprintf(
              "Missing column(s): %s",
              paste(missing_cols, collapse = ", ")
            ),
            "i" = "Dictionary must have `Variable` and `Description` columns."
          ),
          class = "add_auto_labels_invalid_dictionary"
        )
      }

      # Extract variable names from the table body
      table_vars <- unique(tbl$table_body$variable)

      # Filter dictionary to matching variables and de-duplicate
      dict_filtered <- dictionary |>
        dplyr::filter(Variable %in% table_vars) |>
        dplyr::select(variable = Variable, dict_label = Description) |>
        dplyr::distinct(variable, .keep_all = TRUE)
    }
  }

  # Step 2: Try to read label attributes from data
  has_attributes <- FALSE
  attr_filtered <- NULL

  if (!is.null(tbl$inputs$data)) {
    table_vars <- unique(tbl$table_body$variable)
    data <- tbl$inputs$data

    # Extract label attributes for each variable
    attr_labels <- vapply(table_vars, function(var) {
      if (var %in% names(data)) {
        attr(data[[var]], "label") %||% NA_character_
      } else {
        NA_character_
      }
    }, character(1))
    names(attr_labels) <- table_vars

    # Filter to non-NA labels
    attr_labels_clean <- attr_labels[!is.na(attr_labels)]

    if (length(attr_labels_clean) > 0) {
      has_attributes <- TRUE
      attr_filtered <- data.frame(
        variable = names(attr_labels_clean),
        attr_label = as.character(attr_labels_clean),
        stringsAsFactors = FALSE
      )
    }
  }

  # Step 3: Get user-set manual labels (these always win)
  # Support all table types: tbl_summary, tbl_svysummary,
  # tbl_regression, tbl_uvregression
  user_labeled_vars <- c()

  call_obj <- tbl$call_list$tbl_summary %||%
    tbl$call_list$tbl_svysummary %||%
    tbl$call_list$tbl_regression %||%
    tbl$call_list$tbl_uvregression

  if (!is.null(call_obj) && !is.null(call_obj$label)) {
    user_labeled_vars <- tryCatch(
      {
        label_arg <- eval(call_obj$label)
        vars <- vapply(label_arg, function(x) {
          if (inherits(x, "formula")) {
            all.vars(x)[1]
          } else {
            NA_character_
          }
        }, character(1))
        as.character(stats::na.omit(vars))
      },
      error = function(e) {
        rlang::warn(c(
          "Could not extract manual labels from table call.",
          "i" = "Manual labels may not be preserved correctly.",
          "i" = sprintf("Error: %s", e$message)
        ))
        character(0)
      }
    )
  }

  # Step 4: Apply labels with priority logic
  result <- tbl

  # Only proceed if we have at least one label source
  if (has_dictionary || has_attributes) {
    result <- result |>
      modify_table_body(
        ~ {
          tbl_body <- .x

          # Join dictionary labels if available
          if (has_dictionary) {
            tbl_body <- tbl_body |>
              dplyr::left_join(dict_filtered, by = "variable")
          } else {
            tbl_body <- tbl_body |>
              dplyr::mutate(dict_label = NA_character_)
          }

          # Join attribute labels if available
          if (has_attributes) {
            tbl_body <- tbl_body |>
              dplyr::left_join(attr_filtered, by = "variable")
          } else {
            tbl_body <- tbl_body |>
              dplyr::mutate(attr_label = NA_character_)
          }

          # Apply priority logic
          tbl_body <- tbl_body |>
            dplyr::mutate(
              label = dplyr::case_when(
                # Priority 1: Manual labels always win
                variable %in% user_labeled_vars ~ label,
                # Only modify label rows
                row_type != "label" ~ label,
                # Priority 2: Attribute labels
                !is.na(attr_label) ~ attr_label,
                # Priority 3: Dictionary labels
                !is.na(dict_label) ~ dict_label,
                # Default: keep existing label
                TRUE ~ label
              )
            ) |>
            dplyr::select(-dict_label, -attr_label)

          tbl_body
        }
      )
  }

  result
}
