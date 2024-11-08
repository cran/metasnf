## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----eval = FALSE-------------------------------------------------------------
#  library(metasnf)
#  
#  data_list <- generate_data_list(
#      list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
#      list(cort_sa, "cortical_area", "neuroimaging", "continuous"),
#      list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#      list(income, "household_income", "demographics", "continuous"),
#      list(pubertal, "pubertal_status", "demographics", "continuous"),
#      uid = "unique_id"
#  )
#  
#  set.seed(42)
#  settings_matrix <- generate_settings_matrix(
#      data_list,
#      nrow = 4,
#      max_k = 40
#  )
#  
#  # Cluster solutions made using the full data
#  solutions_matrix <- batch_snf(data_list, settings_matrix)

## ----eval = FALSE-------------------------------------------------------------
#  data_list_subsamples <- subsample_data_list(
#      data_list,
#      n_subsamples = 100,
#      subsample_fraction = 0.85
#  )

## ----eval = FALSE-------------------------------------------------------------
#  batch_subsample_results <- batch_snf_subsamples(
#      data_list_subsamples,
#      settings_matrix
#  )

## ----eval = FALSE-------------------------------------------------------------
#  subsample_cluster_solutions <- batch_subsample_results[["cluster_solutions"]]
#  pairwise_aris <- subsample_pairwise_aris(
#      subsample_cluster_solutions,
#      return_raw_aris = TRUE
#  )

## ----eval = FALSE-------------------------------------------------------------
#  ComplexHeatmap::Heatmap(
#      raw_aris[[1]],
#      heatmap_legend_param = list(
#          color_bar = "continuous",
#          title = "Inter-Subsample\nARI",
#          at = c(0, 0.5, 1)
#      ),
#      show_column_names = FALSE,
#      show_row_names = FALSE
#  )

## ----eval = FALSE-------------------------------------------------------------
#  coclustering_results <- calculate_coclustering(
#      subsample_cluster_solutions,
#      solutions_matrix
#  )

## ----eval = FALSE-------------------------------------------------------------
#  cocluster_dfs <- coclustering_results$"cocluster_dfs"
#  
#  cocluster_density(cocluster_dfs[[1]])

## ----eval = FALSE-------------------------------------------------------------
#  # Fraction of co-clustering between observations, grouped by original
#  # cluster membership
#  cocluster_heatmap(
#      cocluster_dfs[[1]],
#      data_list = data_list,
#      top_hm = list(
#          "Income" = "household_income",
#          "Pubertal Status" = "pubertal_status"
#      ),
#      annotation_colours = list(
#          "Pubertal Status" = colour_scale(
#              c(1, 4),
#              min_colour = "black",
#              max_colour = "purple"
#          ),
#          "Income" = colour_scale(
#              c(0, 4),
#              min_colour = "black",
#              max_colour = "red"
#          )
#      )
#  )

