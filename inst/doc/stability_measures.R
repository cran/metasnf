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
# my_dl <- data_list(
#     list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
#     list(cort_sa, "cortical_area", "neuroimaging", "continuous"),
#     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#     list(income, "household_income", "demographics", "continuous"),
#     list(pubertal, "pubertal_status", "demographics", "continuous"),
#     uid = "unique_id"
# )
# 
# set.seed(42)
# sc <- snf_config(
#     my_dl,
#     n_solutions = 4,
#     max_k = 40
# )
# 
# sol_df <- batch_snf(my_dl, sc)

## ----eval = FALSE-------------------------------------------------------------
# my_dl_subsamples <- subsample_dl(
#     my_dl,
#     n_subsamples = 50,
#     subsample_fraction = 0.85
# )

## ----eval = FALSE-------------------------------------------------------------
# batch_subsample_results <- batch_snf_subsamples(
#     my_dl_subsamples,
#     sc,
#     verbose = TRUE
# )

## ----eval = FALSE-------------------------------------------------------------
# pairwise_aris <- subsample_pairwise_aris(
#     batch_subsample_results,
#     verbose = TRUE
# )

## ----eval = FALSE-------------------------------------------------------------
# inter_ss_ari_hm <- ComplexHeatmap::Heatmap(
#     pairwise_aris$"raw_aris"$"s1",
#     heatmap_legend_param = list(
#         color_bar = "continuous",
#         title = "Inter-Subsample\nARI",
#         at = c(0, 0.5, 1)
#     ),
#     show_column_names = FALSE,
#     show_row_names = FALSE
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     inter_ss_ari_hm,
#     "vignettes/inter_ss_ari_hm.png",
#     width = 400,
#     height = 300,
#     res = 70
# )

## ----eval = FALSE-------------------------------------------------------------
# coclustering_results <- calculate_coclustering(
#     batch_subsample_results,
#     sol_df,
#     verbose = TRUE
# )
# 
# coclustering_results$"cocluster_summary"

## ----eval = FALSE-------------------------------------------------------------
# cocluster_dfs <- coclustering_results$"cocluster_dfs"
# 
# cocluster_density(cocluster_dfs[[1]])

## ----eval = FALSE-------------------------------------------------------------
# # Fraction of co-clustering between observations, grouped by original
# # cluster membership
# cocluster_heatmap(
#     cocluster_dfs[[1]],
#     dl = my_dl,
#     top_hm = list(
#         "Income" = "household_income",
#         "Pubertal Status" = "pubertal_status"
#     ),
#     annotation_colours = list(
#         "Pubertal Status" = colour_scale(
#             c(1, 4),
#             min_colour = "black",
#             max_colour = "purple"
#         ),
#         "Income" = colour_scale(
#             c(0, 4),
#             min_colour = "black",
#             max_colour = "red"
#         )
#     )
# )

