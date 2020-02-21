.onLoad <- function(libname, pkgname) {
  # Load Java dependencies (all jars inside the java subfolder)
  rJava::.jpackage(name = pkgname, jars = "*")
  cat(paste0("JVM started with parameters: ", options()$java.parameters))
}
