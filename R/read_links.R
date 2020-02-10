read_externallinkstable <- function(file_list) {
  if (length(file_list) > 0) {
    links_reader <- rJava::.jnew("ExternalLinksReader")
    if (length(file_list) > 1) {
      result <- rJava::J(links_reader, "getLinks", file_list)
      result <- as.list(result)
    } else {
      # Because R does not distinguish singletons from single-length vectors, length 1
      # file lists do not dispatch to a method in java. I use this awful workaround
      # to force it to do so
      result <- rJava::J(links_reader, "getLinks", append(file_list,""))
      result <- as.list(result)[1]
    }


    names(result) <- unlist(file_list)
    result <- lapply(result, function(x) {
      x <- as.list(x)
      x <- sapply(x, rJava::.jstrVal, USE.NAMES = FALSE)
      if (length(x) > 0 && stringr::str_detect(x, "ERROR:")) {
        warning(x)
        return(list())
      } else {
        return(x)
      }
      })

    return(result)
  } else {
    return(list())
  }
}

format_link_xlsx <- function(link, parent_folder, startup_folder) {
  parent_folder <- de_windows_path(parent_folder)
  startup_folder <- de_windows_path(startup_folder)
  link <- de_windows_path(link)
  link <- stringr::str_replace_all(link, stringr::fixed("%20"), " ")
  if (basename_safe(link) == link) {
    # Linked worksheet is in the same directory
    if (substr(parent_folder, nchar(parent_folder), nchar(parent_folder)) != "/") {
      return(paste0(parent_folder, "/", link))
    } else {
      return(paste0(parent_folder, link))
    }
  } else if (substr(link, 1, 10) == "file://///") {
    # Absolute link to network drive, replace with network drive prefix
    return(paste0("\\\\", substr(link, 11, nchar(link))))
  } else if (substr(link, 1, 8) == "file:///") {
    # Absolute link to local drive, replace with drive letter
    return(substr(link, 9, nchar(link)))
  } else {
    # File in the "At startup, open all files in: "
    if (substr(startup_folder, nchar(startup_folder), nchar(startup_folder)) != "/") {
      return <- paste0(startup_folder, "/", link)
    } else {
      return(paste0(startup_folder, link))
    }
  }
}

format_link_xls <- function(link, parent_folder, startup_folder) {
  parent_folder <- de_windows_path(parent_folder)
  startup_folder <- de_windows_path(startup_folder)
  link <- de_windows_path(link)

  if (basename_safe(link) == link) {
    # Linked worksheet is in the same directory
    if (substr(parent_folder, nchar(parent_folder), nchar(parent_folder)) != "/") {
      return(paste0(parent_folder, "/", link))
    } else {
      return(paste0(parent_folder, link))
    }
  } else if (substr(link, 2, 2) == ":") {
    # Absolute link to local drive. All ok.
    if (substr(link, 3, 3) != "/") {
      # This happens...
      link <- paste0(substr(link, 1, 2), "/", substr(link, 3, nchar(link)))
    }
    return(link)
  } else if (substr(link, 1, 2) == "\\\\") {
    # Absolute link to network drive, also ok
    return(link)
  } else if (substr(link, 1, 2) == "./" ) {
    # File in the "At startup, open all files in: "
    if (substr(startup_folder, nchar(startup_folder), nchar(startup_folder)) != "/") {
      return <- paste0(startup_folder, "/", substr(link, 3, nchar(link)))
    } else {
      return(paste0(startup_folder, substr(link, 3, nchar(link))))
    }
  } else {
    return(link)
  }
}

format_link <- function(link, parent_folder, startup_folder, ext) {
  if (ext == "xlsx" || ext == "xlsm" || ext == "xlsb") {
    return(format_link_xlsx(link, parent_folder, startup_folder))
  } else {
    return(format_link_xls(link, parent_folder, startup_folder))
  }
}
