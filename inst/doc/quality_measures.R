## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## ----eval = FALSE-------------------------------------------------------------
# # load package
# library(metasnf)
# 
# # generate data_list
# dl <- data_list(
#     list(cort_t, "cort_t", "neuroimaging", "continuous"),
#     list(cort_sa, "cort_sa", "neuroimaging", "continuous"),
#     list(subc_v, "subc_v", "neuroimaging", "continuous"),
#     list(income, "income", "demographics", "continuous"),
#     list(pubertal, "pubertal", "demographics", "continuous"),
#     uid = "unique_id"
# )
# 
# # build SNF config
# set.seed(42)
# sc <- snf_config(
#     dl = dl,
#     n_solutions = 15
# )
# 
# # collect similarity matrices and solutions data frame from batch_snf
# sol_df <- batch_snf(
#     dl = dl,
#     sc,
#     return_sim_mats = TRUE
# )
# 
# # calculate Davies-Bouldin indices
# davies_bouldin_indices <- calculate_db_indices(sol_df)
# 
# # calculate Dunn indices
# dunn_indices <- calculate_dunn_indices(sol_df)
# 
# # calculate silhouette scores
# silhouette_scores <- calculate_silhouettes(sol_df)
# 
# # plot the silhouette scores of the first solutions
# plot(silhouette_scores[[1]])

