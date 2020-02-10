#' Limit the graph to workbooks that are connected (in either direction) to a
#' particular workbook
#'
#' @param g An igraph object created by  `scan_directory`
#' @param path The path of the workbook you wish to examine
#'
#' @examples
#' \dontrun{
#' g <- scan_directory("C:/my spreadsheets/")
#' get_connected_workbooks(g, "C:/my spreadsheets/bar.xlsx")
#' }
#'
#' @export
get_connected_workbooks <- function(g, path) {
  index <- igraph::vertex_attr(g, "name") == path
  if (sum(index) != 1) stop(paste0("Could not find workbook ", path, " in your map"))
  wb <- igraph::V(g)[index]
  in_dist <- (is.finite(igraph::distances(g, wb, mode = "in")))
  out_dist <- (is.finite(igraph::distances(g, wb, mode = "out")))
  igraph::induced_subgraph(g, igraph::V(g)[in_dist | out_dist])
}

#' Check whether a workbook has a link to a file that no longer exists
#'
#' @param g An igraph object created by `scan_directory`
#' @param path The path to the workbook you wish to inspect
#'
#' @export
has_broken_link <- function(g, path) {
  index <- igraph::vertex_attr(g, "name") == path
  if (sum(index) != 1) stop(paste0("Could not find workbook ", path, " in your map"))
  wb <- igraph::V(g)[index]
  any(is.na(igraph::vertex_attr(g, "modified_date", igraph::neighbors(g, wb, "out"))))
}

#' Check whether a workbook is eventually linked to a workbook that no longer exists.
#' This searches through the full chain of links - i.e. even if all a workbook's
#' links exist, if one of the linked workbook's links is broken, this will return
#' TRUE
#'
#' @param g An igraph object created by `as_igraph` of the results from `scan_directory`
#' @param path The path to the workbook you wish to inspect
#'
#' @export
has_broken_dependency <- function(g, path) {
  index <- igraph::vertex_attr(g, "name") == path
  if (sum(index) != 1) stop(paste0("Could not find workbook ", path, " in your map"))
  wb <- igraph::V(g)[index]
  any(is.na(igraph::vertex_attr(g, "modified_date", igraph::neighborhood(g, wb, order = 1000, mode = "out")[[1]])))
}
