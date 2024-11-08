## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
library(SNFtool)

## -----------------------------------------------------------------------------
K <- 20
alpha <- 0.5
T <- 20

## -----------------------------------------------------------------------------
data(Data1)
data(Data2)

## ----eval = FALSE-------------------------------------------------------------
#  library(ComplexHeatmap)
#  
#  # gene expression data
#  gene_expression_hm <- Heatmap(
#      as.matrix(Data1),
#      cluster_rows = FALSE,
#      cluster_columns = FALSE,
#      show_row_names = FALSE,
#      show_column_names = FALSE,
#      heatmap_legend_param = list(
#          title = "Gene Expression"
#      )
#  )
#  
#  gene_expression_hm

## ----eval = FALSE-------------------------------------------------------------
#  # methylation data
#  methylation_hm <- Heatmap(
#      as.matrix(Data2),
#      cluster_rows = FALSE,
#      cluster_columns = FALSE,
#      show_row_names = FALSE,
#      show_column_names = FALSE,
#      heatmap_legend_param = list(
#          title = "Methylation"
#      )
#  )
#  
#  methylation_hm

## -----------------------------------------------------------------------------
true_label <- c(matrix(1, 100, 1), matrix(2, 100, 1))

## -----------------------------------------------------------------------------
distance_matrix_1 <- as.matrix(dist(Data1, method = "euclidean"))
distance_matrix_2 <- as.matrix(dist(Data2, method = "euclidean"))

## -----------------------------------------------------------------------------
similarity_matrix_1 <- affinityMatrix(distance_matrix_1, K, alpha)
similarity_matrix_2 <- affinityMatrix(distance_matrix_2, K, alpha)

## -----------------------------------------------------------------------------
fused_network <- SNF(
    list(similarity_matrix_1, similarity_matrix_2),
    K,
    T
)

## -----------------------------------------------------------------------------
number_of_clusters <- 2
assigned_clusters <- spectralClustering(fused_network, number_of_clusters)

## -----------------------------------------------------------------------------
all(true_label == assigned_clusters)

## -----------------------------------------------------------------------------
library(metasnf)

## -----------------------------------------------------------------------------
# Add "patient_id" column to each dataframe
Data1$"patient_id" <- 101:(nrow(Data1) + 100)
Data2$"patient_id" <- 101:(nrow(Data2) + 100)

data_list <- generate_data_list(
    list(
        data = Data1,
        name = "genes_1_and_2_exp",
        domain = "gene_expression",
        type = "continuous"
    ),
    list(
        data = Data2,
        name = "genes_1_and_2_meth",
        domain = "gene_methylation",
        type = "continuous"
    ),
    uid = "patient_id"
)


## ----eval = FALSE-------------------------------------------------------------
#  # Compactly:
#  data_list <- generate_data_list(
#      list(Data1, "genes_1_and_2_exp", "gene_expression", "continuous"),
#      list(Data2, "genes_1_and_2_meth", "gene_methylation", "continuous"),
#      uid = "patient_id"
#  )

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 1,
    alpha_values = 0.5,
    k_values = 20,
    t_values = 20,
    dropout_dist = "none",
    possible_snf_schemes = 1
)

settings_matrix

## -----------------------------------------------------------------------------
solutions_matrix <- batch_snf(
    data_list,
    settings_matrix
)

solutions_matrix[, 1:20] # it goes on like this for some time...


## -----------------------------------------------------------------------------
cluster_solution <- get_cluster_df(solutions_matrix)

head(cluster_solution)

## -----------------------------------------------------------------------------
identical(cluster_solution$"cluster", true_label)

## -----------------------------------------------------------------------------

batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    return_similarity_matrices = TRUE
)

names(batch_snf_results)

# The solutions_matrix
solutions_matrix <- batch_snf_results$"solutions_matrix"

# The first (and only, in this case) final fused network
similarity_matrix <- batch_snf_results$"similarity_matrices"[[1]]

## -----------------------------------------------------------------------------
max(similarity_matrix - fused_network)

