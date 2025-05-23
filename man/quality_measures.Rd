% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/quality_measures.R
\name{quality_measures}
\alias{quality_measures}
\alias{calculate_silhouettes}
\alias{calculate_dunn_indices}
\alias{calculate_db_indices}
\title{Quality metrics}
\usage{
calculate_silhouettes(sol_df)

calculate_dunn_indices(sol_df)

calculate_db_indices(sol_df)
}
\arguments{
\item{sol_df}{A \code{solutions_df} class object created by \code{batch_snf()} with
the parameter \code{return_sim_mats = TRUE}.}
}
\value{
A list of \code{silhouette} class objects, a vector of Dunn indices, or a
vector of Davies-Bouldin indices depending on which function was used.
}
\description{
These functions calculate conventional metrics of cluster solution quality.
}
\details{
calculate_silhouettes: A wrapper for \code{cluster::silhouette} that calculates
silhouette scores for all cluster solutions in a provided solutions data
frame. Silhouette values range from -1 to +1 and indicate an overall ratio
of how close together observations within a cluster are to how far apart
observations across clusters are. You can learn more about interpreting
the results of this function by calling \code{?cluster::silhouette}.

calculate_dunn_indices: A wrapper for \code{clv::clv.Dunn} that calculates
Dunn indices for all cluster solutions in a provided solutions data
frame. Dunn indices, like silhouette scores, similarly reflect similarity
within clusters and separation across clusters. You can learn more about
interpreting the results of this function by calling \code{?clv::clv.Dunn}.

calculate_db_indices: A wrapper for \code{clv::clv.Davies.Bouldin} that
calculates Davies-Bouldin indices for all cluster solutions in a provided
solutions data frame. These values can be interpreted similarly as those
above. You can learn more about interpreting the results of this function by
calling \code{?clv::clv.Davies.Bouldin}.
}
\examples{
\dontrun{
input_dl <- data_list(
    list(gender_df, "gender", "demographics", "categorical"),
    list(diagnosis_df, "diagnosis", "clinical", "categorical"),
    uid = "patient_id"
)

sc <- snf_config(input_dl, n_solutions = 5)

sol_df <- batch_snf(input_dl, sc, return_sim_mats = TRUE)

# calculate Davies-Bouldin indices
davies_bouldin_indices <- calculate_db_indices(sol_df)

# calculate Dunn indices
dunn_indices <- calculate_dunn_indices(sol_df)

# calculate silhouette scores
silhouette_scores <- calculate_silhouettes(sol_df)
}
}
