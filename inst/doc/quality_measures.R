## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----eval = FALSE-------------------------------------------------------------
#  # load package
#  library(metasnf)
#  
#  # generate data_list
#  data_list <- generate_data_list(
#      list(cort_t, "cort_t", "neuroimaging", "continuous"),
#      list(cort_sa, "cort_sa", "neuroimaging", "continuous"),
#      list(subc_v, "subc_v", "neuroimaging", "continuous"),
#      list(income, "income", "demographics", "continuous"),
#      list(pubertal, "pubertal", "demographics", "continuous"),
#      uid = "unique_id"
#  )
#  
#  # build settings_matrix
#  set.seed(42)
#  settings_matrix <- generate_settings_matrix(
#      data_list,
#      nrow = 15
#  )
#  
#  # collect similarity matrices and solutions matrix from batch_snf
#  batch_snf_results <- batch_snf(
#      data_list,
#      settings_matrix,
#      return_similarity_matrices = TRUE
#  )
#  
#  solutions_matrix <- batch_snf_results$"solutions_matrix"
#  similarity_matrices <- batch_snf_results$"similarity_matrices"
#  
#  # calculate Davies-Bouldin indices
#  davies_bouldin_indices <- calculate_db_indices(
#      solutions_matrix,
#      similarity_matrices
#  )
#  
#  # calculate Dunn indices
#  dunn_indices <- calculate_dunn_indices(
#      solutions_matrix,
#      similarity_matrices
#  )
#  
#  # calculate silhouette scores
#  silhouette_scores <- calculate_silhouettes(
#      solutions_matrix,
#      similarity_matrices
#  )
#  
#  # plot the silhouette scores of the first solutions
#  plot(silhouette_scores[[1]])

