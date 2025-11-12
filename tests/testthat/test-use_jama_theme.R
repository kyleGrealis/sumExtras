# Tests for use_jama_theme() function

test_that("use_jama_theme() runs without error", {
  skip_if_not_installed("gtsummary")

  expect_message(
    use_jama_theme(),
    "Applied JAMA compact theme"
  )
})

test_that("use_jama_theme() sets gtsummary theme", {
  skip_if_not_installed("gtsummary")

  # Reset theme first
  gtsummary::reset_gtsummary_theme()

  # Apply JAMA theme
  suppressMessages(use_jama_theme())

  # Get current theme
  current_theme <- gtsummary::get_gtsummary_theme()

  # Check that a theme is set
  expect_true(length(current_theme) > 0)

  # Reset theme after test
  gtsummary::reset_gtsummary_theme()
})

test_that("use_jama_theme() returns theme invisibly", {
  skip_if_not_installed("gtsummary")

  result <- suppressMessages(use_jama_theme())

  expect_type(result, "list")

  # Reset theme after test
  gtsummary::reset_gtsummary_theme()
})

test_that("use_jama_theme() can be called multiple times", {
  skip_if_not_installed("gtsummary")

  expect_message(use_jama_theme())
  expect_message(use_jama_theme())

  # Reset theme after test
  gtsummary::reset_gtsummary_theme()
})
