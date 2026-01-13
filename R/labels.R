#' Add automatic labels from dictionary to a gtsummary table
#'
#' @description Automatically apply variable labels from a dictionary or label
#'   attributes to `tbl_summary`, `tbl_svysummary`, or `tbl_regression` objects.
#'   Intelligently preserves manual label overrides set in the original table call
#'   while applying dictionary labels or reading label attributes from data.
#'   The dictionary can be passed explicitly or will be searched for in the calling
#'   environment. If no dictionary is found, the function will attempt to read
#'   label attributes from the underlying data.
#'
#' @param tbl A gtsummary table object created by `tbl_summary()`, `tbl_svysummary()`,
#'   or `tbl_regression()`.
#' @param dictionary A data frame or tibble with `Variable` and `Description` columns.
#'   If not provided (missing), the function will search for a `dictionary` object in
#'   the calling environment. If no dictionary is found, the function will attempt to
#'   read label attributes from the data. Set to `NULL` explicitly to skip dictionary
#'   search and only use attributes.
#'
#' @returns A gtsummary table object with labels applied. Manual labels set via
#'   `label = list(...)` in the original table call are always preserved.
#'
#' @details
#' ## Label Priority Hierarchy
#'
#' The function applies labels according to this priority (highest to lowest):
#'
#' 1. **Manual labels** - Labels set via `label = list(...)` in `tbl_summary()` etc.
#'    are always preserved
#' 2. **Dictionary vs Attributes** - Controlled by `options(sumExtras.preferDictionary)`:
#'    - If `TRUE`: Dictionary labels take precedence over attribute labels
#'    - If `FALSE` (default): Attribute labels take precedence over dictionary labels
#' 3. **Default** - If no label source is available, uses variable name
#'
#' ## Dictionary Format
#'
#' The dictionary must be a data frame with columns:
#' - `Variable`: Character column with exact variable names from datasets
#' - `Description`: Character column with human-readable labels
#'
#' ## Label Attributes
#'
#' The function reads label attributes from data using `attr(data$var, "label")`,
#' following the same label convention used by **haven**, **Hmisc**, and **ggplot2 4.0+**.
#'
#' Your data may already have labels from various sources - imported from statistical
#' software packages, set by other R packages, added manually, or from collaborative
#' projects. This function discovers and applies them seamlessly within gtsummary tables.
#'
#' Because sumExtras uses native R's attribute storage, labels work across any package
#' that respects the `"label"` attribute convention, including:
#' - **ggplot2 4.0+** - automatic axis and legend labels
#' - **gt** - table label support
#' - **Hmisc** - label utilities and display functions
#'
#' This approach requires zero package dependencies and is fully compatible with the
#' labelled package if you choose to use it, but does not require it.
#'
#' ## Implementation Note
#'
#' **This function relies on internal gtsummary structures** (`tbl$call_list`,
#' `tbl$inputs`, `tbl$table_body`) to detect manually set labels. While robust
#' error handling is implemented, major updates to gtsummary may require
#' corresponding updates to sumExtras. Requires gtsummary >= 1.7.0.
#'
#' @section Options:
#' Set `options(sumExtras.preferDictionary = TRUE)` to prioritize dictionary labels
#' over label attributes when both are available. Default is `FALSE`, which prioritizes
#' attributes over dictionary labels.
#'
#' @importFrom gtsummary modify_table_body
#' @importFrom dplyr left_join mutate select filter case_when
#' @importFrom purrr map_chr
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
#'   add_auto_labels()  # Finds dictionary automatically
#'
#' # Working with pre-labeled data (no dictionary needed)
#' labeled_data <- gtsummary::trial
#' attr(labeled_data$age, "label") <- "Patient Age (years)"
#' attr(labeled_data$marker, "label") <- "Marker Level (ng/mL)"
#'
#' labeled_data |>
#'   gtsummary::tbl_summary(include = c(age, marker)) |>
#'   add_auto_labels()  # Reads from label attributes
#'
#' # Manual overrides always win
#' gtsummary::trial |>
#'   gtsummary::tbl_summary(
#'     by = trt,
#'     include = c(age, grade),
#'     label = list(age ~ "Custom Age Label")  # Manual override
#'   ) |>
#'   add_auto_labels(dictionary = my_dict)  # grade gets dict label, age keeps manual
#'
#' # Control priority with options
#' options(sumExtras.preferDictionary = TRUE)  # Dictionary over attributes
#'
#' # Data has both dictionary and attributes
#' labeled_trial <- gtsummary::trial
#' attr(labeled_trial$age, "label") <- "Age from Attribute"
#' dictionary <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age from Dictionary"
#' )
#'
#' labeled_trial |>
#'   gtsummary::tbl_summary(include = age) |>
#'   add_auto_labels()  # Uses "Age from Dictionary" (option = TRUE)
#' }
#'
#' @family labeling functions
#' @seealso
#' * `apply_labels_from_dictionary()` for setting label attributes on data for ggplot2/other packages
#' * `gtsummary::modify_table_body()` for advanced table customization
#'
#' @export
add_auto_labels <- function(tbl, dictionary) {

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

  # Determine if dictionary argument was explicitly provided
  dict_missing <- missing(dictionary)
  dict_is_null <- !dict_missing && is.null(dictionary)

  # Step 1: Try to get dictionary
  has_dictionary <- FALSE
  dict_filtered <- NULL

  if (!dict_is_null) {  # User didn't explicitly set dictionary = NULL
    if (dict_missing) {
      # Try to find dictionary in calling environment
      if (exists("dictionary", envir = parent.frame())) {
        dictionary <- get("dictionary", envir = parent.frame())
        has_dictionary <- TRUE

        # Show user-friendly message only once per session
        if (!isTRUE(getOption("sumExtras.dictionary_message_shown"))) {
          message(
            "Auto-labeling from 'dictionary' object in your environment ",
            "(this message will only show once per session)"
          )
          options(sumExtras.dictionary_message_shown = TRUE)
        }
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
        dplyr::select(variable = Variable, dict_label = Description)
    }
  }

  # Step 2: Try to read label attributes from data
  has_attributes <- FALSE
  attr_filtered <- NULL

  if (!is.null(tbl$inputs$data)) {
    table_vars <- unique(tbl$table_body$variable)
    data <- tbl$inputs$data

    # Extract label attributes for each variable using purrr
    attr_labels <- purrr::map_chr(table_vars, function(var) {
      if (var %in% names(data)) {
        attr(data[[var]], "label") %||% NA_character_
      } else {
        NA_character_
      }
    })
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
  # Support all table types: tbl_summary, tbl_svysummary, tbl_regression, tbl_uvregression
  user_labeled_vars <- c()

  call_obj <- tbl$call_list$tbl_summary %||%
              tbl$call_list$tbl_svysummary %||%
              tbl$call_list$tbl_regression %||%
              tbl$call_list$tbl_uvregression

  if (!is.null(call_obj) && !is.null(call_obj$label)) {
    user_labeled_vars <- tryCatch(
      {
        label_arg <- eval(call_obj$label)
        vars <- purrr::map_chr(label_arg, function(x) {
          if (inherits(x, "formula")) {
            all.vars(x)[1]
          } else {
            NA_character_
          }
        })
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

  # Step 4: Get preference option
  prefer_dict <- getOption("sumExtras.preferDictionary", default = FALSE)

  # Step 5: Apply labels with priority logic
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
              dplyr::left_join(dict_filtered, by = 'variable')
          } else {
            tbl_body <- tbl_body |>
              dplyr::mutate(dict_label = NA_character_)
          }

          # Join attribute labels if available
          if (has_attributes) {
            tbl_body <- tbl_body |>
              dplyr::left_join(attr_filtered, by = 'variable')
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
                row_type != 'label' ~ label,
                # Priority 2 & 3: Depend on option setting
                prefer_dict & !is.na(dict_label) ~ dict_label,
                !is.na(attr_label) ~ attr_label,
                !is.na(dict_label) ~ dict_label,
                # Default: keep existing label
                TRUE ~ label
              )
            ) |>
            dplyr::select(-dict_label, -attr_label)

          return(tbl_body)
        }
      )
  }

  return(result)
}




#' Apply variable labels from dictionary to data as attributes
#'
#' @description Sets variable label attributes on data columns using a dictionary.
#'   This enables cross-package integration with tools that read label attributes,
#'   including ggplot2 4.0+ (automatic axis labels), gt (label support), and Hmisc.
#'   Labels are stored as the `'label'` attribute on each column, following the
#'   informal convention used across the R ecosystem.
#'
#'   This function is designed for workflows where you need labels to persist with
#'   your data for use in plots, descriptive tables, or other visualizations beyond
#'   gtsummary tables.
#'
#' @param data A data frame or tibble to add label attributes to
#' @param dictionary A data frame or tibble with `Variable` and `Description`
#'   columns matching the format used by `add_auto_labels()`
#' @param overwrite Logical. If `TRUE` (default), overwrites existing label
#'   attributes. If `FALSE`, preserves existing labels and only adds new ones.
#'
#' @returns The input data with label attributes attached to matching columns.
#'   Original data is returned unmodified except for added/updated attributes.
#'
#' @details This function provides a bridge from sumExtras' dictionary-based
#'   labeling system to the broader R ecosystem. Key use cases:
#'
#'   - **ggplot2 4.0+**: Automatic axis and legend labels from attributes
#'   - **Cross-package workflows**: One dictionary for tables (gtsummary) and plots (ggplot2)
#'   - **Documentation**: Labels visible in RStudio data viewer
#'   - **Interoperability**: Compatible with gt, Hmisc, and other label-aware packages
#'
#'   Only variables present in both the data and dictionary will receive label
#'   attributes. Dictionary entries for non-existent variables are silently ignored.
#'
#'   ## Implementation: The R Ecosystem Label Convention
#'
#'   This function uses **native R's `attr()` function** to store labels in the `"label"`
#'   attribute, following the same approach as haven, Hmisc, and ggplot2 4.0+.
#'   This standardized convention enables seamless integration across the R ecosystem.
#'
#'   Because labels are stored as simple base R attributes (not in a special package-specific
#'   format), they work transparently with any package that respects the `"label"` attribute:
#'
#'   - **Dictionary-to-Attribute Bridge**: Converts your dictionary's `Description` column
#'     into standard R label attributes
#'   - **Zero Dependencies**: Uses only base R, no special packages required
#'   - **Transparent & Simple**: Users can inspect labels with `attr(data$var, "label")`
#'   - **Ecosystem Compatible**: Works with ggplot2, gt, gtsummary, Hmisc, and beyond
#'
#'   The benefits of this approach are that labels remain portable with your data,
#'   work across multiple R packages without version constraints, and integrate naturally
#'   with the broader R ecosystem's labeling conventions.
#'
#' @importFrom rlang abort
#'
#' @examples
#' \donttest{
#' # Create a dictionary
#' my_dict <- tibble::tribble(
#'   ~Variable, ~Description,
#'   "age", "Age at Enrollment (years)",
#'   "marker", "Marker Level (ng/mL)",
#'   "trt", "Treatment Group",
#'   "grade", "Tumor Grade"
#' )
#'
#' # Apply labels to data
#' trial_labeled <- gtsummary::trial |>
#'   apply_labels_from_dictionary(my_dict)
#'
#' # Now labels work automatically in gtsummary
#' trial_labeled |>
#'   gtsummary::tbl_summary(by = trt, include = c(age, marker, grade))
#'
#' # And in ggplot2 4.0+ (automatic axis labels!)
#' if (requireNamespace("ggplot2", quietly = TRUE) &&
#'     utils::packageVersion("ggplot2") >= "4.0.0") {
#'   library(ggplot2)
#'   trial_labeled |>
#'     ggplot(aes(x = age, y = marker, color = factor(trt))) +
#'     geom_point()  # Axes and legend automatically labeled!
#' }
#'
#' # Check that labels were applied
#' attr(trial_labeled$age, "label")  # "Age at Enrollment (years)"
#'
#' # Preserve existing labels
#' trial_partial <- gtsummary::trial
#' attr(trial_partial$age, "label") <- "Existing Age Label"
#'
#' trial_partial |>
#'   apply_labels_from_dictionary(my_dict, overwrite = FALSE)
#'
#' attr(trial_partial$age, "label")  # Still "Existing Age Label"
#' attr(trial_partial$marker, "label")  # "Marker Level (ng/mL)" (was added)
#' }
#'
#' @family labeling functions
#' @seealso
#' * `add_auto_labels()` for applying labels to gtsummary tables
#' * `labelled::var_label()` for an alternative way to set label attributes
#' * `ggplot2::labs()` for manual plot labeling
#'
#' @export
apply_labels_from_dictionary <- function(data, dictionary, overwrite = TRUE) {

  # Validate data is a data frame
  if (!is.data.frame(data)) {
    rlang::abort(
      c(
        "`data` must be a data frame or tibble.",
        "x" = sprintf("You supplied an object of class: %s", class(data)[1]),
        "i" = "Supply a data frame containing variables to be labeled."
      ),
      class = "apply_labels_invalid_data"
    )
  }

  # Validate dictionary is provided
  if (missing(dictionary) || is.null(dictionary)) {
    rlang::abort(
      c(
        "`dictionary` argument is required.",
        "i" = "Pass a dictionary: apply_labels_from_dictionary(data, dictionary = my_dict)",
        "i" = "Example: dictionary <- tibble::tribble(~Variable, ~Description, 'age', 'Age at Enrollment')"
      ),
      class = "apply_labels_missing_dictionary"
    )
  }

  # Validate dictionary is a data frame
  if (!is.data.frame(dictionary)) {
    rlang::abort(
      c(
        "`dictionary` must be a data frame or tibble.",
        "x" = sprintf("The dictionary object has class: %s", class(dictionary)[1]),
        "i" = "Create a tibble with `Variable` and `Description` columns."
      ),
      class = "apply_labels_invalid_dictionary_type"
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
      class = "apply_labels_missing_columns"
    )
  }

  # Validate overwrite parameter
  if (!is.logical(overwrite) || length(overwrite) != 1) {
    rlang::abort(
      c(
        "`overwrite` must be a single logical value (TRUE or FALSE).",
        "x" = sprintf("You supplied: %s", deparse(overwrite)),
        "i" = "Use overwrite = TRUE to replace existing labels, or overwrite = FALSE to preserve them."
      ),
      class = "apply_labels_invalid_overwrite"
    )
  }

  # Filter dictionary to only variables present in data
  data_vars <- names(data)
  filtered_dict <- dictionary[dictionary$Variable %in% data_vars, ]

  # Apply labels as attributes to each matching column
  for (i in seq_len(nrow(filtered_dict))) {
    var_name <- filtered_dict$Variable[i]
    var_label <- filtered_dict$Description[i]

    # Check if label already exists
    existing_label <- attr(data[[var_name]], "label")

    # Set the 'label' attribute based on overwrite setting
    if (overwrite || is.null(existing_label)) {
      attr(data[[var_name]], "label") <- var_label
    }
    # If overwrite = FALSE and label exists, skip (preserve existing)
  }

  return(data)
}
