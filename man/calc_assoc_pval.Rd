% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/solutions_df.R
\name{calc_assoc_pval}
\alias{calc_assoc_pval}
\title{Calculate p-values based on feature vectors and their types}
\usage{
calc_assoc_pval(var1, var2, type1, type2, cat_test = "chi_squared")
}
\arguments{
\item{var1}{A single vector containing a feature.}

\item{var2}{A single vector containing a feature.}

\item{type1}{The type of var1 (continuous, discrete, ordinal, categorical).}

\item{type2}{The type of var2 (continuous, discrete, ordinal, categorical).}

\item{cat_test}{String indicating which statistical test will be used to
associate cluster with a categorical feature. Options are "chi_squared" for
the Chi-squared test and "fisher_exact" for Fisher's exact test.}
}
\value{
pval A p-value from a statistical test based on the provided types.
Currently, this will either be the F-test p-value from a linear model
if at least one feature is non-categorical, or the chi-squared test
p-value if both features are categorical.
}
\description{
Calculate p-values based on feature vectors and their types
}
\keyword{internal}
