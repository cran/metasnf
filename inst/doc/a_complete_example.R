## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
library(metasnf)

class(cort_t)

dim(cort_t)

str(cort_t[1:5, 1:5])

cort_t[1:5, 1:5]

## -----------------------------------------------------------------------------
dim(income)

str(income[1:5, ])

income[1:5, ]

## -----------------------------------------------------------------------------
data <- list(
    anxiety,
    depress,
    cort_t,
    cort_sa,
    subc_v,
    income,
    pubertal
)

# The number of rows in each dataframe:
lapply(data, dim)

# Whether or not each dataframe has missing values:
lapply(data,
    function(x) {
        any(is.na(x))
    }
)

## -----------------------------------------------------------------------------
complete_uids <- get_complete_uids(data, uid = "unique_id")

print(length(complete_uids))

# Reducing dataframes to only common subjects with no missing data
anxiety <- anxiety[anxiety$"unique_id" %in% complete_uids, ]
depress <- depress[depress$"unique_id" %in% complete_uids, ]
cort_t <- cort_t[cort_t$"unique_id" %in% complete_uids, ]
cort_sa <- cort_sa[cort_sa$"unique_id" %in% complete_uids, ]
subc_v <- subc_v[subc_v$"unique_id" %in% complete_uids, ]
income <- income[income$"unique_id" %in% complete_uids, ]
pubertal <- pubertal[pubertal$"unique_id" %in% complete_uids, ]

## -----------------------------------------------------------------------------
# Note that you do not need to explicitly name every single named element
# (data = ..., name = ..., etc.)
data_list <- generate_data_list(
    list(
        data = cort_t,
        name = "cortical_thickness",
        domain = "neuroimaging",
        type = "continuous"
    ),
    list(
        data = cort_sa,
        name = "cortical_surface_area",
        domain = "neuroimaging",
        type = "continuous"
    ),
    list(
        data = subc_v,
        name = "subcortical_volume",
        domain = "neuroimaging",
        type = "continuous"
    ),
    list(
        data = income,
        name = "household_income",
        domain = "demographics",
        type = "continuous"
    ),
    list(
        data = pubertal,
        name = "pubertal_status",
        domain = "demographics",
        type = "continuous"
    ),
    uid = "unique_id"
)

## -----------------------------------------------------------------------------
summarize_dl(data_list)

## -----------------------------------------------------------------------------
target_list <- generate_data_list(
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

summarize_dl(target_list)

## -----------------------------------------------------------------------------
set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    min_k = 20,
    max_k = 50
)

settings_matrix[1:5, ]

## -----------------------------------------------------------------------------
solutions_matrix <- batch_snf(data_list, settings_matrix)

colnames(solutions_matrix)[1:30]

## -----------------------------------------------------------------------------
cluster_solutions <- get_cluster_solutions(solutions_matrix)

head(cluster_solutions)

## -----------------------------------------------------------------------------
solutions_matrix_aris <- calc_aris(solutions_matrix)

## -----------------------------------------------------------------------------
meta_cluster_order <- get_matrix_order(solutions_matrix_aris)

# Just a vector of numbers
meta_cluster_order

## ----eval = FALSE-------------------------------------------------------------
#  ari_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order
#  )
#  
#  save_heatmap(
#      heatmap = ari_hm,
#      path = "./adjusted_rand_index_heatmap.png",
#      width = 330,
#      height = 300,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  shiny_annotator(ari_hm)

## ----eval = FALSE-------------------------------------------------------------
#  split_vec <- c(2, 5, 12, 17)
#  
#  ari_mc_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = split_vec
#  )
#  
#  save_heatmap(
#      heatmap = ari_mc_hm,
#      path = "./ari_mc_hm.png",
#      width = 330,
#      height = 300,
#      res = 100
#  )

## -----------------------------------------------------------------------------
# Only looking at our out-of-model p-values
extended_solutions_matrix <- extend_solutions(
    solutions_matrix,
    target_list = target_list
)

# What columns have been added?
old_cols <- colnames(extended_solutions_matrix) %in% colnames(solutions_matrix)
new_cols <- !old_cols

head(extended_solutions_matrix[, new_cols])

# Re-running to calculate the p-value for every single input and out-of-model
# feature:
extended_solutions_matrix <- extend_solutions(
    solutions_matrix,
    data_list = data_list,
    target_list = target_list
)

## ----eval = FALSE-------------------------------------------------------------
#  # Also would work, but without any summary p-values
#  extended_solutions_matrix <- extend_solutions(
#      solutions_matrix,
#      data_list = c(data_list, target_list)
#  )
#  
#  # Also would work, but now every feature would be part of the summaries
#  extended_solutions_matrix <- extend_solutions(
#      solutions_matrix,
#      target_list = c(data_list, target_list)
#  )

## ----eval = FALSE-------------------------------------------------------------
#  annotated_ari_hm <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = split_vec,
#      data = extended_solutions_matrix,
#      top_hm = list(
#          "Depression p-value" = "cbcl_depress_r_pval",
#          "Anxiety p-value" = "cbcl_anxiety_r_pval",
#          "Overall outcomes p-value" = "mean_pval"
#      ),
#      bottom_bar = list(
#          "Number of Clusters" = "nclust"
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
#          "Overall outcomes p-value" = colour_scale(
#              extended_solutions_matrix$"mean_pval",
#              min_colour = "lightblue",
#              max_colour = "black"
#          )
#      )
#  )
#  
#  save_heatmap(
#      heatmap = annotated_ari_hm,
#      path = "./annotated_ari_hm.png",
#      width = 700,
#      height = 500,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  extended_solutions_matrix2 <- extended_solutions_matrix |>
#      dplyr::mutate(
#          key_subjects_cluster_together = dplyr::case_when(
#              subject_NDAR_INVLF3TNDUZ == subject_NDAR_INVLDQH8ATK ~ TRUE,
#              TRUE ~ FALSE
#          )
#      )
#  
#  annotated_ari_hm2 <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = split_vec,
#      data = extended_solutions_matrix2,
#      top_hm = list(
#          "Depression p-value" = "cbcl_depress_r_pval",
#          "Anxiety p-value" = "cbcl_anxiety_r_pval",
#          "Key Subjects Clustered Together" = "key_subjects_cluster_together"
#      ),
#      bottom_bar = list(
#          "Number of Clusters" = "nclust"
#      ),
#      annotation_colours = list(
#          "Depression p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_depress_r_pval",
#              min_colour = "purple",
#              max_colour = "black"
#          ),
#          "Anxiety p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_anxiety_r_pval",
#              min_colour = "purple",
#              max_colour = "black"
#          ),
#          "Key Subjects Clustered Together" = c(
#              "TRUE" = "blue",
#              "FALSE" = "black"
#          )
#      )
#  )
#  
#  save_heatmap(
#      heatmap = annotated_ari_hm2,
#      path = "./annotated_ari_hm2.png",
#      width = 700,
#      height = 500,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  rep_solutions <- get_representative_solutions(
#      solutions_matrix_aris,
#      split_vector = split_vec,
#      order = meta_cluster_order,
#      extended_solutions_matrix
#  )
#  
#  mc_manhattan <- mc_manhattan_plot(
#      rep_solutions,
#      data_list = data_list,
#      target_list = target_list,
#      hide_x_labels = TRUE,
#      point_size = 2,
#      text_size = 12,
#      threshold = 0.05,
#      neg_log_pval_thresh = 5
#  )
#  
#  ggplot2::ggsave(
#      "mc_manhattan.png",
#      mc_manhattan,
#      height = 4,
#      width = 8,
#      dpi = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  rep_solutions_no_cort <- dplyr::select(
#      rep_solutions,
#      -dplyr::contains("mrisdp")
#  )
#  
#  mc_manhattan2 <- mc_manhattan_plot(
#      rep_solutions_no_cort,
#      data_list = data_list,
#      target_list = target_list,
#      point_size = 4,
#      threshold = 0.01,
#      text_size = 12,
#      domain_colours = c(
#          "neuroimaging" = "cadetblue",
#          "demographics" = "purple",
#          "behaviour" = "firebrick"
#      )
#  )
#  mc_manhattan2
#  
#  ggplot2::ggsave(
#      "mc_manhattan2.png",
#      mc_manhattan2,
#      height = 8,
#      width = 12,
#      dpi = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  sm_hm <- settings_matrix_heatmap(
#      settings_matrix,
#      order = meta_cluster_order
#  )
#  
#  save_heatmap(
#      heatmap = sm_hm,
#      path = "./settings_matrix_heatmap_ordered.png",
#      width = 400,
#      height = 500,
#      res = 75
#  )

## ----eval = FALSE-------------------------------------------------------------
#  annotated_ari_hm3 <- adjusted_rand_index_heatmap(
#      solutions_matrix_aris,
#      order = meta_cluster_order,
#      split_vector = c(11, 14),
#      data = extended_solutions_matrix,
#      top_hm = list(
#          "Depression p-value" = "cbcl_depress_r_pval",
#          "Anxiety p-value" = "cbcl_anxiety_r_pval",
#          "Key Subjects Clustered Together" = "key_subjects_cluster_together"
#      ),
#      left_hm = list(
#          "Clustering Algorithm" = "clust_alg" # from the original settings
#      ),
#      bottom_bar = list(
#          "Number of Clusters" = "nclust" # also from the original settings
#      ),
#      annotation_colours = list(
#          "Depression p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_depress_r_pval",
#              min_colour = "purple",
#              max_colour = "black"
#          ),
#          "Anxiety p-value" = colour_scale(
#              extended_solutions_matrix$"cbcl_anxiety_r_pval",
#              min_colour = "purple",
#              max_colour = "black"
#          ),
#          "Key Subjects Clustered Together" = c(
#              "TRUE" = "blue",
#              "FALSE" = "black"
#          )
#      )
#  )

## -----------------------------------------------------------------------------
batch_snf_results <- batch_snf(
    data_list,
    settings_matrix,
    return_similarity_matrices = TRUE
)

solutions_matrix <- batch_snf_results$"solutions_matrix"
similarity_matrices <- batch_snf_results$"similarity_matrices"

## ----eval = FALSE-------------------------------------------------------------
#  silhouette_scores <- calculate_silhouettes(
#      solutions_matrix,
#      similarity_matrices
#  )
#  
#  dunn_indices <- calculate_dunn_indices(
#      solutions_matrix,
#      similarity_matrices
#  )
#  
#  db_indices <- calculate_db_indices(
#      solutions_matrix,
#      similarity_matrices
#  )

## -----------------------------------------------------------------------------
extended_solutions_matrix <- extend_solutions(solutions_matrix, target_list)

colnames(extended_solutions_matrix)[1:25]

# Looking at the newly added columns
head(no_subs(extended_solutions_matrix))

## -----------------------------------------------------------------------------
target_pvals <- get_pvals(extended_solutions_matrix)

head(target_pvals)

## ----eval = FALSE-------------------------------------------------------------
#  pval_hm <- pval_heatmap(target_pvals, order = meta_cluster_order)
#  
#  save_heatmap(
#      heatmap = pval_hm,
#      path = "./pval_heatmap_ordered.png",
#      width = 400,
#      height = 500,
#      res = 100
#  )

## -----------------------------------------------------------------------------
# All the subjects present in all dataframes with no NAs
all_subjects <- data_list[[1]]$"data"$"subjectkey"

# Remove the "subject_" prefix to allow merges with the original data
all_subjects <- gsub("subject_", "", all_subjects)

# Dataframe assigning 80% of subjects to train and 20% to test
assigned_splits <- train_test_assign(train_frac = 0.8, subjects = all_subjects)

# Pulling the training and testing subjects specifically
train_subs <- assigned_splits$"train"
test_subs <- assigned_splits$"test"

# Partition a training set
train_cort_t <- cort_t[cort_t$"unique_id" %in% train_subs, ]
train_cort_sa <- cort_sa[cort_sa$"unique_id" %in% train_subs, ]
train_subc_v <- subc_v[subc_v$"unique_id" %in% train_subs, ]
train_income <- income[income$"unique_id" %in% train_subs, ]
train_pubertal <- pubertal[pubertal$"unique_id" %in% train_subs, ]
train_anxiety <- anxiety[anxiety$"unique_id" %in% train_subs, ]
train_depress <- depress[depress$"unique_id" %in% train_subs, ]

# Partition a test set
test_cort_t <- cort_t[cort_t$"unique_id" %in% test_subs, ]
test_cort_sa <- cort_sa[cort_sa$"unique_id" %in% test_subs, ]
test_subc_v <- subc_v[subc_v$"unique_id" %in% test_subs, ]
test_income <- income[income$"unique_id" %in% test_subs, ]
test_pubertal <- pubertal[pubertal$"unique_id" %in% test_subs, ]
test_anxiety <- anxiety[anxiety$"unique_id" %in% test_subs, ]
test_depress <- depress[depress$"unique_id" %in% test_subs, ]

# A data list with just training subjects
train_data_list <- generate_data_list(
    list(train_cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(train_cort_sa, "cortical_sa", "neuroimaging", "continuous"),
    list(train_subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(train_income, "household_income", "demographics", "continuous"),
    list(train_pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# A data list with training and testing subjects
full_data_list <- generate_data_list(
    list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# Construct the target lists
train_target_list <- generate_data_list(
    list(train_anxiety, "anxiety", "behaviour", "ordinal"),
    list(train_depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

# Find a clustering solution in your training data
set.seed(42)
settings_matrix <- generate_settings_matrix(
    train_data_list,
    nrow = 5,
    min_k = 10,
    max_k = 30
)

train_solutions_matrix <- batch_snf(
    train_data_list,
    settings_matrix
)

extended_solutions_matrix <- extend_solutions(
    train_solutions_matrix,
    train_target_list
)

extended_solutions_matrix |> colnames()

# The fifth row had the lowest minimum p-value across our outcomes
lowest_min_pval <- min(extended_solutions_matrix$"min_pval")
which(extended_solutions_matrix$"min_pval" == lowest_min_pval)

# Keep track of your top solution
top_row <- extended_solutions_matrix[4, ]

# Use the solutions matrix from the training subjects and the data list from
# the training and testing subjects to propagate labels to the test subjects
propagated_labels <- lp_solutions_matrix(top_row, full_data_list)

head(propagated_labels)
tail(propagated_labels)

## -----------------------------------------------------------------------------
propagated_labels_all <- lp_solutions_matrix(
    extended_solutions_matrix,
    full_data_list
)

head(propagated_labels_all)
tail(propagated_labels_all)

