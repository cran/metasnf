## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## ----eval = FALSE-------------------------------------------------------------
# library(metasnf)
# 
# # First imputed dataset
# dl_imp1 <- data_list(
#     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#     list(income, "household_income", "demographics", "continuous"),
#     list(pubertal, "pubertal_status", "demographics", "continuous"),
#     list(anxiety, "anxiety", "behaviour", "ordinal"),
#     list(depress, "depressed", "behaviour", "ordinal"),
#     uid = "unique_id"
# )
# 
# # Second imputed dataset
# dl_imp2 <- data_list(
#     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#     list(income, "household_income", "demographics", "continuous"),
#     list(pubertal, "pubertal_status", "demographics", "continuous"),
#     list(anxiety, "anxiety", "behaviour", "ordinal"),
#     list(depress, "depressed", "behaviour", "ordinal"),
#     uid = "unique_id"
# )
# 
# set.seed(42)
# sc <- snf_config(
#     dl = dl_imp1,
#     n_solutions = 10,
#     min_k = 20,
#     max_k = 50
# )
# 
# # Generation of 20 cluster solutions
# sol_df_imp1 <- batch_snf(dl_imp1, sc)
# sol_df_imp2 <- batch_snf(dl_imp2, sc)
# 
# nrow(sol_df_imp1)
# nrow(sol_df_imp1)
# 
# # Create a stacked solution matrix that stores solutions from both imputations
# # Solutions 1:10 are for imputation 1, 11:20 are for imputation 2
# sol_df <- rbind(sol_df_imp1, sol_df_imp2, reset_indices = TRUE)
# 
# sol_df
# 
# # Calculate pairwise similarities across all solutions
# # (Including across imputations)
# sol_aris <- calc_aris(sol_df)
# 
# meta_cluster_order <- get_matrix_order(sol_aris)
# 
# # Base heatmap for identifying meta clusters
# ari_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order
# )
# 
# # Identify meta cluster boundaries
# shiny_annotator(ari_hm)
# 
# split_vec <- c(7, 13)
# 
# ari_mc_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec
# )
# 
# # Calculate how features are distributed across solutions
# ext_sol_df_imp1 <- extend_solutions(
#     sol_df,
#     target_dl = dl_imp1
# )

## ----eval = FALSE-------------------------------------------------------------
# annotation_data <- as.data.frame(ext_sol_df_imp1, keep_attributes = TRUE)
# annotation_data$"imputation" <- c(rep("imp_1", 10), rep("imp_2", 10))
# 
# # Visualize influence of imputation on meta clustering results
# annotated_ari_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec,
#     data = annotation_data,
#     top_hm = list(
#         "Depression p-value" = "cbcl_depress_r_pval",
#         "Anxiety p-value" = "cbcl_anxiety_r_pval"
#     ),
#     left_hm = list(
#         "Imputation" = "imputation"
#     ),
#     annotation_colours = list(
#         "Depression p-value" = colour_scale(
#             annotation_data$"cbcl_depress_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Anxiety p-value" = colour_scale(
#             annotation_data$"cbcl_anxiety_r_pval",
#             min_colour = "green",
#             max_colour = "black"
#         ),
#         "Imputation" = c(
#             "imp_1" = "orange",
#             "imp_2" = "blue"
#         )
#     )
# )

