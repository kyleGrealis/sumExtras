# Prevent CMD check notes about undefined global variables
utils::globalVariables(
  c(
    "variable",
    "var_type",
    "row_type",
    "label",
    "description"
  )
)
