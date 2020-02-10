get_d3_clickJS <- function(vertices) {
  paste0(
    d3_data_addition_hack(vertices),
    "
    function titlecolor(exists) {
    if (exists == 'TRUE') {
    return('black');
    } else {
    return('red');
    }
    }
d3.selectAll('.xtooltip').remove();
  d3.select('body').append('div')
  .attr('class', 'xtooltip')
  .style('position', 'absolute')
  .style('border', '1px solid #999')
  .style('border-radius', '3px')
  .style('padding', '5px')
  .style('opacity', '0.85')
  .style('background-color', '#fff')
  .style('box-shadow', '2px 2px 6px #888888')
  .style('font-family', 'Calibri, sans')
  .style('font-size', '10px')
  .html('<div style = \"font-weight:bold; font-size: 12px; color: ' + titlecolor(d.exists) + '\">' + d.name + '</div>' + 'Last modified: ' + d.modified_date + '<br>Full path: ' + d.path + '<br>Size: ' + d.file_size)
  .style('left', (d3.event.pageX) + 'px')
  .style('top', (d3.event.pageY - 28) + 'px')
  .attr('onclick', 'd3.selectAll(\".xtooltip\").remove();');
  ")
}

d3_group_colours <- function(groups, group) {
  if (group == "last_modified") {
    color_map <- list(
      "No longer exists" = "'#f4425f'",
      "Past month" = "'#4853f2'",
      "Past quarter" = "'#7980f2'",
      "3-6 months" = "'#ad78f1'",
      "6-12 months" = "'#d077f0'",
      "1-2 years" = "'#cd5fd3'",
      "More than 2 years" = "'#885fd3'"
    )
    return(paste0("[",paste0(sapply(groups, function(x) color_map[[x]]), collapse = ", "),"]"))
  } else {
    return("d3.schemeCategory20")
  }
}


last_modified_tooltip_text <- function(modified) {
  elapsed_days <- difftime(Sys.Date(), modified, units = "days")
  if (is.na(elapsed_days)) {
    return("No longer exists!")
  } else if (elapsed_days == 0) {
    elapsed_days <- " (today)"
  } else if (elapsed_days == 1) {
    elapsed_days <- " (yesterday)"
  } else {
    elapsed_days <- paste0(" (", elapsed_days, " days ago)")
  }
  paste0(as.character(modified), elapsed_days)
}

add_d3_data_attribute <- function(attribute, value, i) {
  paste0("d3.selectAll('.node').data()[", i - 1, "].", attribute, " = '", value, "';\n")
}

escape_quotes <- function(x) {
  x <- stringr::str_replace_all(x, "'", "\\\\'")
  stringr::str_replace_all(x, "\"", "\\\"")
}

d3_data_addition_hack <- function(vertices) {
  output <- ""
  for (i in 1:nrow(vertices)) {
    output <- paste0(
      output,
      add_d3_data_attribute("modified_date",last_modified_tooltip_text(vertices$modified_date[i]),i),
      add_d3_data_attribute("path", escape_quotes(vertices$path[i]), i),
      add_d3_data_attribute("exists", !is.na(vertices$modified_date[i]), i),
      add_d3_data_attribute("file_size", paste0(round(vertices$file_size[i], 1), "MB"), i)
    )
  }
  return(output)
}
