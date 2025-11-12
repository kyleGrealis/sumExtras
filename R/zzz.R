.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\nsumExtras loaded.",
    "\nTip: Use `use_jama_theme()` to apply the JAMA compact theme to {gtsummary}\n"
  )
}
