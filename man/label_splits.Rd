% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/heatmaps.R
\name{label_splits}
\alias{label_splits}
\title{Convert a vector of partition indices into meta cluster labels}
\usage{
label_splits(split_vector, nrow)
}
\arguments{
\item{split_vector}{A vector of partition indices.}

\item{nrow}{The number of rows in the data being partitioned.}
}
\value{
A character vector that expands the split_vector into an nrow-length
sequence of ascending letters of the alphabet. If the split vector is
c(3, 6) and the number of rows is 8, the result will be a vector of two
"A"s (up to the first index, 3), three "B"s (up to the second index, 6),
and three "C"s (up to and including the last index, 8).
}
\description{
Convert a vector of partition indices into meta cluster labels
}
\keyword{internal}
