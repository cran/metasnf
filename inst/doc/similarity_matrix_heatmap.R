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
        name = "expression_data",
        domain = "gene_expression",
        type = "continuous"
    ),
    list(
        data = methylation_df,
        name = "methylation_data",
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
    list(
        data = age_df,
        name = "age",
        domain = "demographics",
        type = "discrete"
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
    my_dl,
    my_sc,
    return_sim_mats = TRUE
)

similarity_matrices <- sim_mats_list(sol_df)

# The first (and only) similarity matrix:
similarity_matrix <- similarity_matrices[[1]]

# The first (and only) cluster solution:
cluster_solution <- t(sol_df)

## ----eval = FALSE-------------------------------------------------------------
# similarity_matrix_hm <- similarity_matrix_heatmap(
#     similarity_matrix = similarity_matrix,
#     cluster_solution = cluster_solution,
#     heatmap_height = grid::unit(10, "cm"),
#     heatmap_width = grid::unit(10, "cm")
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = similarity_matrix_hm,
#     path = "vignettes/similarity_matrix_heatmap.png",
#     width = 410,
#     height = 330,
#     res = 80
# )

## ----eval = FALSE-------------------------------------------------------------
# annotated_sm_hm <- similarity_matrix_heatmap(
#     similarity_matrix = similarity_matrix,
#     cluster_solution = cluster_solution,
#     scale_diag = "mean",
#     log_graph = TRUE,
#     data = my_dl,
#     left_hm = list(
#         "Diagnosis" = "diagnosis"
#     ),
#     top_hm = list(
#         "Gender" = "gender"
#     ),
#     top_bar = list(
#         "Age" = "age"
#     ),
#     annotation_colours = list(
#         Diagnosis = c(
#             "definite asthma" = "red3",
#             "possible asthma" = "pink1",
#             "no asthma" = "bisque1"
#         ),
#         Gender = c(
#             "female" = "purple",
#             "male" = "lightgreen"
#         )
#     ),
#     heatmap_height = grid::unit(10, "cm"),
#     heatmap_width = grid::unit(10, "cm")
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = annotated_sm_hm,
#     path = "vignettes/annotated_sm_heatmap.png",
#     width = 500,
#     height = 440,
#     res = 80
# )

## ----eval = FALSE-------------------------------------------------------------
# merged_df <- as.data.frame(my_dl)
# order <- sort(cluster_solution[, 2], index.return = TRUE)$"ix"
# merged_df <- merged_df[order, ]
# 
# top_annotations <- ComplexHeatmap::HeatmapAnnotation(
#     Age = ComplexHeatmap::anno_barplot(merged_df$"age"),
#     Gender = merged_df$"gender",
#     col = list(
#         Gender = c(
#             "female" = "purple",
#             "male" = "lightgreen"
#         )
#     ),
#     show_legend = TRUE
# )
# 
# left_annotations <- ComplexHeatmap::rowAnnotation(
#     Diagnosis = merged_df$"diagnosis",
#     col = list(
#         Diagnosis = c(
#             "definite asthma" = "red3",
#             "possible asthma" = "pink1",
#             "no asthma" = "bisque1"
#         )
#     ),
#     show_legend = TRUE
# )
# 
# similarity_matrix_heatmap(
#     similarity_matrix = similarity_matrix,
#     cluster_solution = cluster_solution,
#     scale_diag = "mean",
#     log_graph = TRUE,
#     data = merged_df,
#     top_annotation = top_annotations,
#     left_annotation = left_annotations
# )

