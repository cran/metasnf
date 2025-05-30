% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/print.R
\name{not_shown_message}
\alias{not_shown_message}
\title{Helper function for creating what hidden ft/obs/sols message}
\usage{
not_shown_message(
  hidden_solutions = NULL,
  hidden_observations = NULL,
  hidden_features = NULL
)
}
\arguments{
\item{hidden_solutions}{Number of hidden solutions.}

\item{hidden_observations}{Number of hidden observations.}

\item{hidden_features}{Number of hidden features.}
}
\value{
If all arguments are NULL or 0, returns NULL. Otherwise, output a
neatly formatted string indicating how many observations, features, and/or
observations were not shown.
}
\description{
Helper function for creating what hidden ft/obs/sols message
}
\keyword{internal}
