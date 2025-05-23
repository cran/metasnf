% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ext_solutions_df.R
\name{extend_solutions}
\alias{extend_solutions}
\title{Extend a solutions data frame to include outcome evaluations}
\usage{
extend_solutions(
  sol_df,
  target_dl = NULL,
  dl = NULL,
  cat_test = "chi_squared",
  min_pval = 1e-10,
  processes = 1,
  verbose = FALSE
)
}
\arguments{
\item{sol_df}{Result of \code{batch_snf} storing cluster solutions and
the settings that were used to generate them.}

\item{target_dl}{A data list with features to calculate p-values for.
Features in the target list will be included during p-value summary
measure calculations.}

\item{dl}{A data list with features to calculate p-values for, but
that should not be incorporated into p-value summary measure columns (i.e.,
min/mean/max p-value columns).}

\item{cat_test}{String indicating which statistical test will be used to
associate cluster with a categorical feature. Options are "chi_squared" for
the Chi-squared test and "fisher_exact" for Fisher's exact test.}

\item{min_pval}{If assigned a value, any p-value less than this will be
replaced with this value.}

\item{processes}{The number of processes to use for parallelization.
Progress is only reported for sequential processing (processes = 1).}

\item{verbose}{If TRUE, output progress to console.}
}
\value{
An extended solutions data frame (\code{ext_sol_df} class object)
that contains p-value columns for each outcome in the provided data lists
}
\description{
Extend a solutions data frame to include outcome evaluations
}
\examples{
\dontrun{
    input_dl <- data_list(
        list(gender_df, "gender", "demographics", "categorical"),
        list(diagnosis_df, "diagnosis", "clinical", "categorical"),
        uid = "patient_id"
    )
    
    sc <- snf_config(input_dl, n_solutions = 2)
    
    sol_df <- batch_snf(input_dl, sc)
    
    ext_sol_df <- extend_solutions(sol_df, input_dl)
}
}
