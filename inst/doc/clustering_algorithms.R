## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
# Load the package
library(metasnf)

dl <- data_list(
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

set.seed(42)
sc <- snf_config(
    dl = dl,
    n_solutions = 5,
    max_k = 40
)

## -----------------------------------------------------------------------------
# Available functions
sc$"clust_fns_list"

# Which functions will be used
sc$"settings_df"$"clust_alg"

## -----------------------------------------------------------------------------
# The default list:
sc <- snf_config(
    dl = dl,
    n_solutions = 5,
    use_default_clust_fns = TRUE
)

sc$"clust_fns_list"

# Adding algorithms provided by the package
sc <- snf_config(
    dl = dl,
    n_solutions = 5,
    clust_fns = list(
        "two_cluster_spectral" = spectral_two,
        "five_cluster_spectral" = spectral_five
    ),
    use_default_clust_fns = TRUE
)

# Note that this one has the default algorithms as well as the newly added ones
sc$"clust_fns_list"

# This list has only the newly added ones
sc <- snf_config(
    dl = dl,
    n_solutions = 5,
    clust_fns = list(
        "two_cluster_spectral" = spectral_two,
        "five_cluster_spectral" = spectral_five
    )
)

sc$"clust_fns_list"

## -----------------------------------------------------------------------------
sc

## ----eval = FALSE-------------------------------------------------------------
# sol_df <- batch_snf(
#     dl = dl,
#     sc = sc
# )

## ----eval = FALSE-------------------------------------------------------------
# # Default clustering algorithm #1
# spectral_eigen <- function(similarity_matrix) {
#     estimated_n <- estimate_nclust_given_graph(
#         W = similarity_matrix,
#         NUMC = 2:10
#     )
#     nclust_estimate <- estimated_n$`Eigen-gap best`
#     solution <- SNFtool::spectralClustering(
#         similarity_matrix,
#         nclust_estimate
#     )
#     return(solution)
# }
# 
# # Default clustering algorithm #2
# spectral_rot <- function(similarity_matrix) {
#     estimated_n <- estimate_nclust_given_graph(
#         W = similarity_matrix,
#         NUMC = 2:10
#     )
#     nclust_estimate <- estimated_n$`Rotation cost best`
#     solution <- SNFtool::spectralClustering(
#         similarity_matrix,
#         nclust_estimate
#     )
#     return(solution)
# }

## -----------------------------------------------------------------------------
sol_df <- batch_snf(
    dl,
    sc,
    return_sim_mats = TRUE
)

# Similarity matrices are in the list below:
similarity_matrices <- sim_mats_list(sol_df)

length(similarity_matrices)

dim(similarity_matrices[[1]])

# Your manual clustering goes here...

## ----eval = FALSE-------------------------------------------------------------
# library(dbscan)
# ## Example 1: use dbscan on the iris data set
# data(iris)
# iris <- as.matrix(iris[, 1:4])
# iris_dist <- dist(iris)
# 
# ## Find suitable DBSCAN parameters:
# ## 1. We use minPts = dim + 1 = 5 for iris. A larger value can also be used.
# ## 2. We inspect the k-NN distance plot for k = minPts - 1 = 4
# kNNdistplot(iris, minPts = 5)
# 
# ## Noise seems to start around a 4-NN distance of .7
# abline(h=.7, col = "red", lty = 2)
# 
# results <- dbscan(iris_dist, eps = 0.7, minPts = 5)
# 
# # The 1 is added to ensure that those with no cluster (cluster 0) are still
# # plotted.
# pairs(iris, col = results$cluster + 1)

## ----fig.width = 5, fig.height = 4.5------------------------------------------
library(dbscan)
library(ggplot2)

dl <- data_list(
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
sc <- snf_config(
    dl = dl,
    n_solutions = 5
)

sol_df <- batch_snf(
    dl = dl,
    sc = sc,
    return_sim_mats = TRUE
)

similarity_matrices <- sim_mats_list(sol_df)

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

spectral_results <- t(sol_df[1, ])[, 2]

dbscan_vs_spectral <- data.frame(
    dbscan = dbscan_results,
    spectral = spectral_results
)

ggplot(dbscan_vs_spectral, aes(x = dbscan, y = spectral)) +
    geom_jitter(height = 0.1, width = 0.1, alpha = 0.5) +
    theme_bw()

## ----eval = FALSE-------------------------------------------------------------
# for (i in seq(0.485, 0.488, by = 0.0001)) {
#     results <- dbscan(distance_matrix1, eps = i, minPts = 10)
#     if (length(unique(results$"cluster")) == 3) {
#         print(i)
#     }
# }

