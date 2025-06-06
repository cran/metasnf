% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nclust_estimation.R
\name{estimate_nclust_given_graph}
\alias{estimate_nclust_given_graph}
\title{Estimate number of clusters for a similarity matrix}
\usage{
estimate_nclust_given_graph(W, NUMC = 2:10)
}
\arguments{
\item{W}{Similarity matrix to calculate number of clusters for.}

\item{NUMC}{Range of cluster counts to consider among when picking best
number of clusters.}
}
\value{
A list containing the top two eigengap and rotation-cost estimates
for the number of clusters in a given similarity matrix.
}
\description{
Calculate eigengap and rotation-cost estimates of the number of clusters
to use when clustering a similarity matrix. This function was adapted
from \code{SNFtool::estimateClustersGivenGraph}, but scales up the Laplacian
operator prior to eigenvalue calculations to minimize the risk of
floating point-related errors.
}
\examples{
input_dl <- data_list(
    list(gender_df, "gender", "demographics", "categorical"),
    list(diagnosis_df, "diagnosis", "clinical", "categorical"),
    uid = "patient_id"
)

sc <- snf_config(input_dl, n_solutions = 1)
sol_df <- batch_snf(input_dl, sc, return_sim_mats = TRUE)
sim_mat <- sim_mats_list(sol_df)[[1]]
estimate_nclust_given_graph(sim_mat)
}
