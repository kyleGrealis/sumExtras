.onAttach <- function(libname, pkgname) {
  # Set default theme when package loads
  if (requireNamespace("gtsummary", quietly = TRUE)) {
    suppressMessages(
      gtsummary::set_gtsummary_theme(
        gtsummary::theme_gtsummary_compact("jama")
      )
    )
    packageStartupMessage(
      "\nsumExtras: Applied JAMA compact theme to {gtsummary}\nReset with `gtsummary::reset_gtsummary_theme()`\n"
    )
  }
}