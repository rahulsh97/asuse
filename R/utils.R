#' This and the next function are used to print messages in the console
#' @keywords internal
msg <- function(..., startup = FALSE) {
  if (startup) {
    if (!isTRUE(getOption("asuse.quiet"))) {
      packageStartupMessage(text_col(...))
    }
  } else {
    message(text_col(...))
  }
}

#' @keywords internal
text_col <- function(x) {
  # If RStudio API is not available, messages print in black
  if (!rstudioapi::isAvailable()) {
    return(x)
  }

  if (!rstudioapi::hasFun("getThemeInfo")) {
    return(x)
  }

  theme <- rstudioapi::getThemeInfo()

  if (isTRUE(theme$dark)) crayon::white(x) else crayon::black(x)
}
