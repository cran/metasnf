## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

# Generate data_list
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
    list(
        data = gender_df,
        name = "gender",
        domain = "demographics",
        type = "categorical"
    ),
    list(
        data = diagnosis_df,
        name = "diagnosis",
        domain = "clinical",
        type = "categorical"
    ),
    uid = "patient_id"
)

set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 1,
    max_k = 40
)

batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    return_similarity_matrices = TRUE
)

solutions_matrix <- batch_snf_results$"solutions_matrix"
similarity_matrices <- batch_snf_results$"similarity_matrices"

similarity_matrix <- similarity_matrices[[1]]

cluster_solution <- get_cluster_solutions(solutions_matrix)$"1"

## -----------------------------------------------------------------------------
# Spectral clustering functions ranging from 2 to 6 clusters
cluster_sequence <- list(
    spectral_two,
    spectral_three,
    spectral_four
)

## ----fig.width = 7, fig.height = 5.5------------------------------------------
alluvial_cluster_plot(
    cluster_sequence = cluster_sequence,
    similarity_matrix = similarity_matrix,
    data_list = data_list,
    key_outcome = "gender", # the name of the feature of interest
    key_label = "Gender", # how the feature of interest should be displayed
    extra_outcomes = "diagnosis", # more features to plot but not colour by
    title = "Gender Across Cluster Counts"
)

## ----fig.width = 7, fig.height = 5.5------------------------------------------
extra_data <- dplyr::inner_join(
    gender_df,
    diagnosis_df,
    by = "patient_id"
) |>
    dplyr::mutate(subjectkey = paste0("subject_", patient_id))

head(extra_data)

alluvial_cluster_plot(
    cluster_sequence = cluster_sequence,
    similarity_matrix = similarity_matrix,
    data = extra_data,
    key_outcome = "gender",
    key_label = "Gender",
    extra_outcomes = "diagnosis",
    title = "Gender Across Cluster Counts"
)

