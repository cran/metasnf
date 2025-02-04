## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

# Generate data_list
my_dl <- data_list(
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
my_sc <- snf_config(
    my_dl,
    n_solutions = 1,
    max_k = 40
)

sol_df <- batch_snf(
    dl = my_dl,
    sc = my_sc,
    return_sim_mats = TRUE
)

sim_mats <- sim_mats_list(sol_df)

similarity_matrix <- sim_mats[[1]]

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
    dl = my_dl,
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
    dplyr::mutate(uid = paste0("uid_", patient_id))

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

