file_last_modified <- function(x) {
  as.Date(file.info(x)$mtime)
}

file_last_modified_group <- function(x) {
  last <- file_last_modified(x)
  elapsed <- difftime(Sys.time(), last, units = "days")
  dplyr::case_when(
    is.na(elapsed) ~ "No longer exists",
    elapsed < 30 ~ "Past month",
    elapsed < 90 ~ "Past quarter",
    elapsed < 180 ~ "3-6 months",
    elapsed < 365 ~ "6-12 months",
    elapsed < 730 ~ "1-2 years",
    TRUE ~ "More than 2 years"
  )
}

get_vertices_attributes <- function(link_map) {
  vertex_paths <- get_unique_files(link_map)
  if (length(vertex_paths) > 0) {
    vertices <-
      data.frame(
        path = vertex_paths,
        basename = sapply(vertex_paths, basename_safe, USE.NAMES = FALSE),
        last_modified = sapply(vertex_paths, file_last_modified_group, USE.NAMES = FALSE),
        modified_date = sapply(vertex_paths, file_last_modified, USE.NAMES = FALSE),
        file_size = sapply(vertex_paths, function(x) file.info(x)$size/(1024^2), USE.NAMES = FALSE),
        stringsAsFactors = FALSE
      )

    class(vertices$modified_date) <- "Date"
  } else {
    vertices <- data.frame(
      path = character(0),
      basename = character(0),
      last_modified = character(0),
      modified_date = as.Date(character(0)),
      file_size = numeric(0),
      stringsAsFactors = FALSE
    )
  }

  return(vertices)
}
