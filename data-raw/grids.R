url <- "https://raw.githubusercontent.com/hafen/grid-designer/master/grid_list.json"
grid_list <- jsonlite::fromJSON(url)

## read in any that haven't been stored in package yet
##---------------------------------------------------------

# get list of new ones to read in
nms <- setdiff(grid_list$name, gsub("\\.rda", "", list.files("data")))
# nms <- grid_list$name # to re-read all grids

lapply(nms, function(x) {
  url <- sprintf("https://raw.githubusercontent.com/hafen/grid-designer/master/grids/%s.csv", x)
  res <- data.frame(readr::read_csv(url))
  assign(x, res)
  eval(parse(text = sprintf("devtools::use_data(%s, overwrite = TRUE)", x)))
})

## update documentation - generate R/grid_docs.R
##---------------------------------------------------------

doc_string <- "#' Geo Grids
#'
#' @name grids
#' @docType data
#' @keywords data
#' @description See \\code{\\link{facet_geo}} for several examples.
#' @rdname grids
NULL
"

for (ii in seq_len(nrow(grid_list))) {
  x <- grid_list[ii, ]
  doc_string <- paste0(doc_string, "
#' @name ", x$name, "
#' @description
#' \\strong{", x$name, ":} ", x$desc, " Image reference \\href{", x$ref_img, "}{here}.",
  ifelse(is.na(x$contrib), "", paste0(" Thanks to \\url{", x$contrib, "}.")), "
#' @usage ", x$name, "
#' @rdname grids
NULL
"
)
}

cat(doc_string, file = "R/grid_docs.R")

document()

## generate R/valid_grids.R
##---------------------------------------------------------

nms <- paste0("\"", paste0(grid_list$name, collapse = "\", \""), "\"")
txt <- paste0(strwrap(paste0(".valid_grids <- c(", nms, ")"), 80, exdent = 2), collapse = "\n")
cat(paste0(txt, "\n"), file = "R/valid_grids.R")
