% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_fns_list.R
\name{siw_euclidean_distance}
\alias{siw_euclidean_distance}
\title{Squared (including weights) Euclidean distance}
\usage{
siw_euclidean_distance(df, weights_row)
}
\arguments{
\item{df}{data frame containing at least 1 data column.}

\item{weights_row}{Single-row data frame where the column names contain the
column names in df and the row contains the corresponding weights.}
}
\value{
distance_matrix A distance matrix.
}
\description{
Squared (including weights) Euclidean distance
}
