# sumExtras Test Suite

This directory contains the test suite for the sumExtras package using the testthat framework.

## Structure

```
tests/
├── testthat.R              # Main test runner
└── testthat/
    ├── test-extras.R       # Tests for extras() function
    ├── test-clean_table.R  # Tests for clean_table() function
    ├── test-labels.R       # Tests for create_labels() and add_auto_labels()
    ├── test-styling.R      # Tests for styling functions (theme_gt_compact, group_styling, get_group_rows)
    └── test-use_jama_theme.R # Tests for use_jama_theme() function
```

## Running Tests

### Run all tests
```r
devtools::test()
```

### Run tests with coverage
```r
covr::package_coverage()
```

### Run specific test file
```r
devtools::test_active_file()  # When file is open
# or
testthat::test_file("tests/testthat/test-extras.R")
```

### Interactive testing
```r
devtools::load_all()
testthat::test_local()
```

## Test Coverage

The test suite covers:

### extras() function (test-extras.R)
- ✓ Basic functionality with tbl_summary
- ✓ Without p-values (pval = FALSE)
- ✓ Without overall column (overall = FALSE)
- ✓ Overall column positioning (last parameter)
- ✓ Using .args parameter
- ✓ Non-stratified tables
- ✓ Regression tables

### clean_table() function (test-clean_table.R)
- ✓ Basic table cleaning
- ✓ Handling missing data
- ✓ Regression tables
- ✓ Pipeline integration

### Label functions (test-labels.R)
- ✓ create_labels() with valid dictionary
- ✓ create_labels() with missing variables
- ✓ add_auto_labels() with tbl_summary
- ✓ add_auto_labels() with tbl_regression
- ✓ Manual label override preservation
- ✓ Tables without matching dictionary variables

### Styling functions (test-styling.R)
- ✓ theme_gt_compact() with gt tables
- ✓ theme_gt_compact() option setting
- ✓ group_styling() with default formatting
- ✓ group_styling() with bold/italic only
- ✓ group_styling() with multiple groups
- ✓ get_group_rows() basic functionality
- ✓ get_group_rows() with multiple groups
- ✓ get_group_rows() error handling
- ✓ get_group_rows() with no groups

### use_jama_theme() function (test-use_jama_theme.R)
- ✓ Basic execution without error
- ✓ Theme setting verification
- ✓ Invisible return value
- ✓ Multiple calls handling

## Notes

- Tests use `skip_if_not_installed()` to handle optional dependencies gracefully
- Dictionary tests properly manage global environment state with cleanup
- All tests follow CRAN best practices
- Tests are isolated and can run in any order
