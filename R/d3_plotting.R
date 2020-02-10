
#' Create an interactive plot of a spreadsheet graph (using D3)
#'
#' @param link_map An Excel link map created by `scan_directory`
#' @param color_by How to colour the graphs. Defaults to `last_modified` categories. Can
#' alternatively use `basename` to group by spreadsheet names (helps find duplicates)
#' or pass the full path of a spreadsheet to highlight just it
#'
#' @examples
#' \dontrun{
#' map <- scan_directory("C:/my spreadsheets/")
#' plot_d3(map)
#' }
#'
#' @export
plot_d3 <- function(link_map, color_by = "last_modified") {
  g <- as_igraph(link_map)
  vertices <- networkD3::igraph_to_networkD3(g, what = "nodes")
  names(vertices) <- "path"

  vertices$basename <- igraph::vertex_attr(g, "basename")
  vertices$last_modified <- igraph::vertex_attr(g, "last_modified")
  vertices$modified_date <- igraph::vertex_attr(g, "modified_date")
  class(vertices$modified_date) <- "Date"
  vertices$file_size <- igraph::vertex_attr(g, "file_size")
  vertices$exists <- !is.na(vertices$modified_date)

  if (color_by != "last_modified" & color_by != "basename") {
    group <- "highlight"
    index <- igraph::vertex_attr(g, "name") == color_by
    if (sum(index) != 1) stop(paste0("Could not find workbook ", color_by, " in your map"))
    vertices$highlight <- index
  } else {
    group <- color_by
  }

  links <- networkD3::igraph_to_networkD3(g, what = "links")
  links$value <- 1
  clickJS <- get_d3_clickJS(vertices)
  d3 <-
    networkD3::forceNetwork(
      Links = links,
      Nodes = vertices,
      Source = "source",
      Target = "target",
      NodeID = "basename",
      Group = group,
      Value = "value",
      opacity = 'opacityNoHover = 1',
      colourScale = networkD3::JS(paste0(
        "d3.scaleOrdinal(",
        d3_group_colours(unique(
          vertices[[group]]
        ), group)
        ,
        ");"
      )),
      arrows = TRUE,
      zoom = TRUE,
      legend = TRUE,
      bounded = TRUE,
      fontSize = 10,
      fontFamily = "Calibri",
      clickAction = clickJS
    )

  return(d3)
}
