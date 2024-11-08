## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----eval = FALSE-------------------------------------------------------------
#  library(metasnf)
#  
#  # First imputed dataset
#  data_list_imp1 <- generate_data_list(
#      list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#      list(income, "household_income", "demographics", "continuous"),
#      list(pubertal, "pubertal_status", "demographics", "continuous"),
#      list(anxiety, "anxiety", "behaviour", "ordinal"),
#      list(depress, "depressed", "behaviour", "ordinal"),
#      uid = "unique_id"
#  )
#  
#  # Second imputed dataset
#  data_list_imp2 <- generate_data_list(
#      list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#      list(income, "household_income", "demographics", "continuous"),
#      list(pubertal, "pubertal_status", "demographics", "continuous"),
#      list(anxiety, "anxiety", "behaviour", "ordinal"),
#      list(depress, "depressed", "behaviour", "ordinal"),
#      uid = "unique_id"
#  )
#  
#  set.seed(42)
#  settings_matrix <- generate_settings_matrix(
#      data_list_imp1,
#      nrow = 10,
#      min_k = 20,
#      max_k = 50
#  )
#  
#  # Generation of 20 cluster solutions
#  solutions_matrix_imp1 <- batch_snf(data_list_imp1, settings_matrix)
#  solutions_matrix_imp2 <- batch_snf(data_list_imp2, settings_matrix)
#  
#  solutions_matrix_imp1$"imputation" <- 1
#  solutions_matrix_imp1$"imputation" <- 2
#  
#  # Create a stacked solution matrix that stores solutions from both imputations
#  solutions_matrix <- rbind(solutions_matrix_imp1, solutions_matrix_imp2)
#  
#  # Calculate pairwise similarities across all solutions
#  # (Including across imputations)
#  solutions_matrix_aris <- calc_aris(solutions_matrix)
#  
#  meta_cluster_order <- get_matrix_order(solutions_matrix_aris)
#  
#  # Base heatmap for identifying meta clusters
#  ari_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order
#  )
#  
#  # Identify meta cluster boundaries
#  shiny_annotator(ari_hm)
#  split_vec <- c(2, 5, 12, 17)
#  
#  ari_mc_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = split_vec
#  )
#  
#  # Calculate how features are distributed across solutions
#  extended_solutions_matrix <- extend_solutions(
#      solutions_matrix,
#      data_list = data_list
#  )
#  
#  # Visualize influence of imputation on meta clustering results
#  annotated_ari_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = split_vec,
#      data = extended_solutions_matrix,
#      top_hm = list(
#          "Depression p-value" = "cbcl_depress_r_pval",
#          "Anxiety p-value" = "cbcl_anxiety_r_pval"
#      ),
#      left_hm = list(
#          "Imputation" = "imputation"
#      ),
#      annotation_colours = list(
#          "Depression p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_depress_r_pval",
#              min_colour = "purple",
#              max_colour = "black"
#          ),
#          "Anxiety p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_anxiety_r_pval",
#              min_colour = "green",
#              max_colour = "black"
#          ),
#          "Imputation" = colour_scale(
#              extended_solutions_matrix$"mean_pval",
#              min_colour = "lightblue",
#              max_colour = "black"
#          )
#      )
#  )

