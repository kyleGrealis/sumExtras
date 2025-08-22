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
#' @seealso [add_auto_labels()] for automatic application to existing tbl_summary objects
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




#' Add automatic labels from dictionary to a tbl_summary object
#' 
#' @description Pipe a `gtsummary::tbl_summary` object to automatically add variable 
#'   labels from a dictionary tibble. Preserves any manual label overrides specified 
#'   in the original `tbl_summary()` call while adding dictionary labels for unlabeled 
#'   variables. Requires a `dictionary` object with `Variable` and `Description` columns.
#'   See `create_labels()` function for dictionary format requirements.
#' 
#' @param tbl A gtsummary table object created by `tbl_summary()`
#' 
#' @returns A gtsummary table object with automatic labels applied
#' 
#' @importFrom gtsummary tbl_summary tbl_svysummary
#' @importFrom purrr map_chr
#' @importFrom stats setNames
#' 
#' @examples
#' \dontrun{
#' # Basic usage - adds dictionary labels to all variables
#' table1_data |> 
#'   gtsummary::tbl_summary(by = diagnosis) |> 
#'   add_auto_labels()
#'   
#' # Preserves manual overrides while adding dictionary labels for the rest
#' table1_data |> 
#'   gtsummary::tbl_summary(by = diagnosis, label = c(age ~ "Patient Age")) |> 
#'   add_auto_labels()  # 'age' stays "Patient Age", others get dictionary labels
#' }
#' 
#' @seealso [create_labels()] for dictionary requirements
#' 
#' @export
add_auto_labels <- function(tbl) {

  # Extract the original dataset from the table object
  # This data is stored in tbl$inputs$data and contains all variables used in the table
  original_data <- tbl$inputs$data
  
  # Check if this is a survey table by looking at the table class, not just the data
  # Detects tbl_svysummary objects or survey design data to call the correct
  #   reconstruction function
  is_survey_table <- inherits(tbl, "tbl_svysummary") || 
                      any(grepl("svy", class(tbl))) ||
                      inherits(original_data, "survey.design")
  
  # For survey objects, extract the data frame from the design
  # Survey designs store actual data in $variables component
  if (inherits(original_data, "survey.design")) {
    data_for_labels <- original_data$variables
  } else {
    data_for_labels <- original_data
  }
  
  # Get the variables that are actually included in the table
  # Only label variables that were specified in the include argument to avoid errors
  included_vars <- tbl$inputs$include %||% names(data_for_labels)
  
  # Generate automatic labels from the dictionary using create_labels()
  # Returns a list of formulas: list(variable ~ "Description from dictionary")
  auto_labels_list <- create_labels(data_for_labels)
  
  # Filter auto labels to only include variables in the table
  # Extract variable names from formulas and keep only those in the current table
  auto_vars <- purrr::map_chr(auto_labels_list, ~ all.vars(.x)[1])
  keep_vars <- auto_vars %in% included_vars
  auto_labels_filtered <- auto_labels_list[keep_vars]
  
  # Extract any existing & overriding labels that were manually specified in tbl_summary()
  # Note: tbl_summary stores these as a named list: list(variable = "Custom Label")
  # The %||% operator means "use this, or if NULL use list()"
  override_labels <- tbl$inputs$label %||% list()
  
  if (length(override_labels) > 0) {
    # DON'T convert override labels - they're already in the correct format for 
    #   reconstruction!
    # gtsummary expects the original input format when using do.call()
    
    # Extract variable names from the override custom labels
    # These variables should NOT be overwritten by dictionary labels
    existing_vars <- names(override_labels)
    
    # Extract variable names from the filtered auto-generated dictionary labels
    # all.vars(.x)[1] gets the left-hand side variable name from each formula
    filtered_auto_vars <- purrr::map_chr(auto_labels_filtered, ~ all.vars(.x)[1])
    
    # Filter auto_labels to exclude any variables that have custom labels
    # This preserves manual overrides while adding dictionary labels for the rest
    keep_auto <- !filtered_auto_vars %in% existing_vars
    final_auto_labels <- auto_labels_filtered[keep_auto]
    
    # Convert remaining dictionary labels to named list format to match override format
    if (length(final_auto_labels) > 0) {
      auto_as_named_list <- setNames(
        # Extract description
        purrr::map_chr(final_auto_labels, ~ as.character(.x)[3]),
         # Extract variable name
        purrr::map_chr(final_auto_labels, ~ all.vars(.x)[1])
      )
      # Combine override labels (named list) with auto labels (converted to named list)
      combined_labels <- c(override_labels, auto_as_named_list)
    } else {
      # No additional dictionary labels needed, use only manual overrides
      combined_labels <- override_labels
    }

    # DEBUG: Check final structure
    # print("Manual override vars:")
    # print(existing_vars)
    # print("Dictionary vars being added:")
    # print(filtered_auto_vars[keep_auto])
    # print("Any duplicates?")
    # print(intersect(existing_vars, filtered_auto_vars[keep_auto]))

  } else {
    # No existing override custom labels found, use all filtered dictionary labels
    combined_labels <- auto_labels_filtered
  }
  
  # Reconstruct the table with the combined label set
  # Preserve all original arguments (data, by, missing, etc.) from tbl$inputs
  args <- tbl$inputs
  args$label <- combined_labels
  
  # Rebuild and return the table with automatic + custom labels applied
  # Use the survey detection to call the right function (tbl_svysummary vs tbl_summary)
  if (is_survey_table) {
    do.call(tbl_svysummary, args)
  } else {
    do.call(tbl_summary, args)
  }
}
