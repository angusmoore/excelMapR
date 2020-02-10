.onLoad <- function(libname, pkgname) {
  # Load Java dependencies (all jars inside the java subfolder)
  if (is.null(unlist(options("java.parameters")))) {
    options(java.parameters = "-XX:-UseGCOverheadLimit -Xmx16384m")
  }
  rJava::.jpackage(name = pkgname, jars = "*")
  cat(paste0("JVM started with parameters: ", options()$java.parameters))
}
