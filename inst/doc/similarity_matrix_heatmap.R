## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

# Generate data_list
data_list <- generate_data_list(
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

# Generate settings_matrix
set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 1,
    max_k = 40
)

# Run SNF and clustering
batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    return_similarity_matrices = TRUE
)

solutions_matrix <- batch_snf_results$"solutions_matrix"
similarity_matrices <- batch_snf_results$"similarity_matrices"

# The first (and only) similarity matrix:
similarity_matrix <- similarity_matrices[[1]]

# The first (and only) cluster solution:
cluster_solution <- get_cluster_solutions(solutions_matrix)$"1"

## ----eval = FALSE-------------------------------------------------------------
#  similarity_matrix_hm <- similarity_matrix_heatmap(
#      similarity_matrix = similarity_matrix,
#      cluster_solution = cluster_solution,
#      heatmap_height = grid::unit(10, "cm"),
#      heatmap_width = grid::unit(10, "cm")
#  )
#  
#  # Export heatmaps using the `save_heatmap` function
#  save_heatmap(
#      heatmap = similarity_matrix_hm,
#      path = "./similarity_matrix_heatmap.png",
#      width = 410,
#      height = 330,
#      res = 80
#  )

## ----eval = FALSE-------------------------------------------------------------
#  
#  annotated_sm_hm <- similarity_matrix_heatmap(
#      similarity_matrix = similarity_matrix,
#      cluster_solution = cluster_solution,
#      scale_diag = "mean",
#      log_graph = TRUE,
#      data_list = data_list,
#      left_hm = list(
#          "Diagnosis" = "diagnosis"
#      ),
#      top_hm = list(
#          "Gender" = "gender"
#      ),
#      top_bar = list(
#          "Age" = "age"
#      ),
#      annotation_colours = list(
#          Diagnosis = c(
#              "definite asthma" = "red3",
#              "possible asthma" = "pink1",
#              "no asthma" = "bisque1"
#          ),
#          Gender = c(
#              "female" = "purple",
#              "male" = "lightgreen"
#          )
#      ),
#      heatmap_height = grid::unit(10, "cm"),
#      heatmap_width = grid::unit(10, "cm")
#  )
#  
#  save_heatmap(
#      heatmap = annotated_sm_hm,
#      path = "./annotated_sm_heatmap.png",
#      width = 500,
#      height = 440,
#      res = 80
#  )

## ----eval = FALSE-------------------------------------------------------------
#  merged_df <- collapse_dl(data_list)
#  order <- sort(cluster_solution, index.return = TRUE)$"ix"
#  merged_df <- merged_df[order, ]
#  
#  top_annotations <- ComplexHeatmap::HeatmapAnnotation(
#      Age = ComplexHeatmap::anno_barplot(merged_df$"age"),
#      Gender = merged_df$"gender",
#      col = list(
#          Gender = c(
#              "female" = "purple",
#              "male" = "lightgreen"
#          )
#      ),
#      show_legend = TRUE
#  )
#  
#  left_annotations <- ComplexHeatmap::rowAnnotation(
#      Diagnosis = merged_df$"diagnosis",
#      col = list(
#          Diagnosis = c(
#              "definite asthma" = "red3",
#              "possible asthma" = "pink1",
#              "no asthma" = "bisque1"
#          )
#      ),
#      show_legend = TRUE
#  )
#  
#  similarity_matrix_heatmap(
#      similarity_matrix = similarity_matrix,
#      cluster_solution = cluster_solution,
#      scale_diag = "mean",
#      log_graph = TRUE,
#      data = merged_df,
#      top_annotation = top_annotations,
#      left_annotation = left_annotations
#  )
#  

