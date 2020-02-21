# excelMapR

<!-- badges: start -->
[![Travis-CI Build Status](https://travis-ci.org/angusmoore/excelMapR.svg?branch=master)](https://travis-ci.org/angusmoore/excelMapR)
[![Coverage Status](https://coveralls.io/repos/github/angusmoore/excelMapR/badge.svg?branch=master)](https://coveralls.io/github/angusmoore/excelMapR?branch=master)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

`excelMapR` is an R library that solves a single problem rife in complicated
spreadsheets:
> What spreadsheets depend on this spreadsheet?

This is a pretty niche package. But the motivation comes from a previous job I had
where daily analysis relied on a huge sprawling network of interlinked
spreadsheets (in the 10s of thousands). This was exactly as problematic as you'd
imagine.

Improving one of those spreadsheets was hard, because you couldn't know if
changing a column would break some other spreadsheet somewhere else. There is
_no_ way to track reverse dependencies in Excel.

`excelMapR` tries to solves this problem by scanning a folder (or drive) of 
spreadsheets to map the full dependency tree. Armed with that tree, you can find
the reverse dependencies.

(Of course, the correct answer to this problem is: don't use Excel.)

## Installation

`excelMapR` is not available on CRAN, and probably never will be given how niche
it is.

Install the latest version of the package using the R `remotes` package:
```
remotes::install_github("angusmoore/excelMapR")
```

Alternatively, you can install the latest development version using
```
remotes::install_github("angusmoore/excelMapR")
```

# Package documentation and usage

Documentation for this package can be found [here](https://angusmoore.github.io/excelMapR/).
