#' Get the unique file names from an Excel link map
#'
#' This includes files that are linked to by other spreadsheet but no longer
#' exist, and files outside the directory you scanned.
#'
#' @param link_map An Excel link map created by `scan_directory`
#'
#' @examples
#' \dontrun{
#' excel_map <- scan_directory("C:/my spreadsheets/")
#' get_unique_files(excel_map)
#' }
#'
#' @export
get_unique_files <- function(link_map) {
  files <- unlist(unname(link_map))
  files <- append(files, names(link_map))
  unique(files)
}

edge_list_df <- function(adj_list) {
  df <- data.frame(from = character(), to = character(), stringsAsFactors = FALSE)
  for (from in names(adj_list)) {
    if (length(adj_list[[from]] > 0)) {
      df <- dplyr::bind_rows(df, data.frame(from = from, to = adj_list[[from]], stringsAsFactors = FALSE))
    }
  }
  return(df)
}

#' Convert an Excel link map to an igraph object
#'
#' @param link_map An Excel link map created by `scan_directory`
#'
#' @export
as_igraph <- function(link_map) {
  vertices <- get_vertices_attributes(link_map)
  igraph::graph_from_data_frame(edge_list_df(link_map), directed = TRUE, vertices = vertices)
}

dirname_safe <- function(path) {
  if (nchar(path) < 256) {
    return(dirname(path))
  } else {
    last_slash <- stringr::str_locate_all(path, "/")[[1]][,1]
    last_backslash <- stringr::str_locate_all(path, "\\\\")[[1]][,1]
    separators <- c(last_slash, last_backslash)
    return(substr(path, 1, max(separators)-1))
  }
}

basename_safe <- function(path) {
  if (nchar(path) < 256) {
    return(basename(path))
  } else {
    last_slash <- stringr::str_locate_all(path, "/")[[1]][,1]
    last_backslash <- stringr::str_locate_all(path, "\\\\")[[1]][,1]
    separators <- c(last_slash, last_backslash)
    return(substr(path, max(separators)-1, nchar(path)))
  }
}

#' Scan a directory for excel files and enumerate the linked spreadsheets in
#' any files that are found.
#'
#' Returns a list mapping files (names in the list) to their links.
#'
#' @param dir The directory to search
#' @param startup_folder The folder listed under "At startup, open all files in:",
#' in Excel's Options > Advanced
#'
#' @examples
#' \dontrun{
#' scan_directory("C:/my spreadsheets/")
#' }
#
#' @export
scan_directory <- function(dir, startup_folder) {
  file_list <-
    list.files(
      dir,
      recursive = T,
      pattern = "\\.(xlsx|xlsm|xls)$",
      full.names = T
    )
  # Drop temporary files (~$)
  tmps <- stringr::str_detect(file_list, stringr::fixed("~$"))
  file_list <- file_list[!tmps]
  file_list <- sapply(file_list, function(x) stringr::str_replace_all(de_windows_path(x), stringr::fixed("//"), "/"))

  result <- read_externallinkstable(file_list)

  result <- lapply(seq_along(result), function(i) {
    sapply(result[[i]], function(link)
      format_link(link, dirname_safe(names(result)[i]), startup_folder, tools::file_ext(names(result)[i])), USE.NAMES = FALSE)
  })

  names(result) <- file_list
  result <- lapply(result, function(x) stringr::str_replace_all(x, stringr::fixed("//"), "/"))
  return(result)
}


#' Scan a single Excel file and enumerate the linked spreadsheets in it
#'
#' Returns a list mapping the files (names in the list) to its links.
#'
#' @param path The Excel file to search
#' @param startup_folder The folder listed under "At startup, open all files in:",
#' in Excel's Options > Advanced
#'
#' @examples
#' \dontrun{
#' scan_directory("C:/my spreadsheets/")
#' }
#
#' @export
scan_file <- function(path, startup_folder) {

  result <- read_externallinkstable(path)

  result <- lapply(seq_along(result), function(i) {
    sapply(result[[i]], function(link)
      format_link(link, dirname_safe(names(result)[i]), startup_folder, tools::file_ext(names(result)[i])), USE.NAMES = FALSE)
  })

  names(result) <- path
  result <- lapply(result, function(x) stringr::str_replace_all(x, stringr::fixed("//"), "/"))
  return(result)
}
