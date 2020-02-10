
de_windows_path <- function(path) {
  path <- stringr::str_replace_all(path, stringr::fixed("\\"), "/")
  if (substr(path, 1, 2) == "//") {
    return(paste0("\\\\", substr(path, 3, nchar(path))))
  } else {
    return(path)
  }
}
