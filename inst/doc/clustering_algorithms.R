## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
# Load the package
library(metasnf)

# Start by making a data list containing all our dataframes to more easily
# identify subjects without missing data
full_data_list <- generate_data_list(
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

# Partition into a data and target list (optional)
data_list <- full_data_list[1:3]
target_list <- full_data_list[4:5]

# Specifying 5 different sets of settings for SNF
set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 5,
    max_k = 40
)

# This matrix has clustering solutions for each of the 5 SNF runs!
solutions_matrix <- batch_snf(data_list, settings_matrix)

extended_solutions <- extend_solutions(
    solutions_matrix,
    target_list,
    cat_test = "fisher_exact"
)

## ----eval = FALSE-------------------------------------------------------------
#  clust_esm_manhattan <- esm_manhattan_plot(
#      extended_solutions,
#      threshold = 0.05,
#      bonferroni_line = TRUE
#  )
#  
#  ggplot2::ggsave(
#      "clust_esm_manhattan.png",
#      clust_esm_manhattan,
#      width = 5,
#      height = 5,
#      dpi = 100
#  )

## -----------------------------------------------------------------------------
settings_matrix$"clust_alg"

## -----------------------------------------------------------------------------
clust_algs_list <- generate_clust_algs_list()

# The default list:
clust_algs_list

# A prettier format:
summarize_clust_algs_list(clust_algs_list)

# Adding algorithms provided by the package
clust_algs_list <- generate_clust_algs_list(
    "two_cluster_spectral" = spectral_two,
    "five_cluster_spectral" = spectral_five
)

# Note that this one has the default algorithms as well as the newly added ones
summarize_clust_algs_list(clust_algs_list)

# This list has only the newly added ones, thanks to the disable_base parameter
clust_algs_list <- generate_clust_algs_list(
    "two_cluster_spectral" = spectral_two,
    "five_cluster_spectral" = spectral_five,
    disable_base = TRUE
)

summarize_clust_algs_list(clust_algs_list)

## -----------------------------------------------------------------------------
# This list has only the newly added ones, thanks to the disable_base parameter
clust_algs_list <- generate_clust_algs_list(
    "two_cluster_spectral" = spectral_two,
    "three_cluster_spectral" = spectral_three,
    "five_cluster_spectral" = spectral_five
)

# Specifying 5 different sets of settings for SNF
set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    max_k = 40,
    clustering_algorithms = clust_algs_list
)

settings_matrix$"clust_alg"

## ----eval = FALSE-------------------------------------------------------------
#  solutions_matrix <- batch_snf(
#      data_list,
#      settings_matrix,
#      clust_algs_list = clust_algs_list
#  )

## ----eval = FALSE-------------------------------------------------------------
#  # Default clustering algorithm #1
#  spectral_eigen <- function(similarity_matrix) {
#      estimated_n <- estimate_nclust_given_graph(
#          W = similarity_matrix,
#          NUMC = 2:10
#      )
#      nclust_estimate <- estimated_n$`Eigen-gap best`
#      solution <- SNFtool::spectralClustering(
#          similarity_matrix,
#          nclust_estimate
#      )
#      nclust <- length(unique(solution))
#      solution_data <- list("solution" = solution, "nclust" = nclust)
#      if (nclust_estimate != nclust) {
#          warning(
#              "Spectral clustering provided a solution of size ", nclust,
#              " when the number requested based on the eigen-gap heuristic",
#              " was ", nclust_estimate, "."
#          )
#      }
#      return(solution_data)
#  }
#  
#  # Default clustering algorithm #2
#  spectral_rot <- function(similarity_matrix) {
#      estimated_n <- estimate_nclust_given_graph(
#          W = similarity_matrix,
#          NUMC = 2:10
#      )
#      nclust_estimate <- estimated_n$`Rotation cost best`
#      solution <- SNFtool::spectralClustering(
#          similarity_matrix,
#          nclust_estimate
#      )
#      nclust <- length(unique(solution))
#      solution_data <- list("solution" = solution, "nclust" = nclust)
#      if (nclust_estimate != length(unique(solution))) {
#          warning(
#              "Spectral clustering provided a solution of size ", nclust,
#              " when the number requested based on the rotation cost heuristic",
#              " was ", nclust_estimate, "."
#          )
#      }
#      return(solution_data)
#  }

## -----------------------------------------------------------------------------
batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    clust_algs_list = clust_algs_list,
    return_similarity_matrices = TRUE
)

names(batch_snf_results)

solutions_matrix <- batch_snf_results$"solutions_matrix"

# Similarity matrices are in the list below:
similarity_matrices <- batch_snf_results$"similarity_matrices"

length(similarity_matrices)

dim(similarity_matrices[[1]])

# Your manual clustering goes here...

## ----eval = FALSE-------------------------------------------------------------
#  library(dbscan)
#  ## Example 1: use dbscan on the iris data set
#  data(iris)
#  iris <- as.matrix(iris[, 1:4])
#  iris_dist <- dist(iris)
#  
#  ## Find suitable DBSCAN parameters:
#  ## 1. We use minPts = dim + 1 = 5 for iris. A larger value can also be used.
#  ## 2. We inspect the k-NN distance plot for k = minPts - 1 = 4
#  kNNdistplot(iris, minPts = 5)
#  
#  ## Noise seems to start around a 4-NN distance of .7
#  abline(h=.7, col = "red", lty = 2)
#  
#  results <- dbscan(iris_dist, eps = 0.7, minPts = 5)
#  
#  # The 1 is added to ensure that those with no cluster (cluster 0) are still
#  # plotted.
#  pairs(iris, col = results$cluster + 1)

## ----fig.width = 5, fig.height = 4.5------------------------------------------
library(dbscan)
library(ggplot2)

data_list <- generate_data_list(
    list(
        data = expression_df,
        name = "genes_1_and_2_exp",
        domain = "gene_expression",
        type = "continuous"
    ),
    list(
        data = methylation_df,
        name = "genes_1_and_2_meth",
        domain = "gene_methylation",
        type = "continuous"
    ),
    uid = "patient_id"
)

set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 5
)

batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    return_similarity_matrices = TRUE
)

similarity_matrices <- batch_snf_results$"similarity_matrices"

solutions_matrix <- batch_snf_results$"solutions_matrix"

representative_sm <- similarity_matrices[[1]]

representative_sms <- similarity_matrices[c(1, 2)]

distance_matrix1 <- as.dist(
    max(representative_sm) - representative_sm
)

kNNdistplot(
    distance_matrix1,
    minPts = 10
)

## Maybe there?
abline(h=0.4872, col = "red", lty = 2)

dbscan_results <- dbscan(distance_matrix1, eps = 0.4872, minPts = 10)$"cluster"

spectral_results <- get_clusters(solutions_matrix[1, ])

dbscan_vs_spectral <- data.frame(
    dbscan = dbscan_results,
    spectral = spectral_results
)

ggplot(dbscan_vs_spectral, aes(x = dbscan, y = spectral)) +
    geom_jitter(height = 0.1, width = 0.1, alpha = 0.5) +
    theme_bw()

## ----eval = FALSE-------------------------------------------------------------
#  for (i in seq(0.485, 0.488, by = 0.0001)) {
#      results <- dbscan(distance_matrix1, eps = i, minPts = 10)
#      if (length(unique(results$"cluster")) == 3) {
#          print(i)
#      }
#  }

