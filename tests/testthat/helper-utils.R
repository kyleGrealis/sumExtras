# Shared test helpers

#' Create a clean trial dataset without pre-existing label attributes
get_unlabeled_trial <- function() {
  data <- gtsummary::trial
  for (col in names(data)) {
    attr(data[[col]], "label") <- NULL
  }
  data
}
