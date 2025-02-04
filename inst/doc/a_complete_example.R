## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

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
df_list <- list(
    anxiety,
    depress,
    cort_t,
    cort_sa,
    subc_v,
    income,
    pubertal
)

# The number of rows in each data frame:
lapply(df_list, dim)

# Whether or not each data frame has missing values:
lapply(df_list,
    function(x) {
        any(is.na(x))
    }
)

## -----------------------------------------------------------------------------
complete_uids <- get_complete_uids(df_list, uid = "unique_id")

print(length(complete_uids))

# Reducing data frames to only common observations with no missing data
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
input_dl <- data_list(
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
summary(input_dl)

## -----------------------------------------------------------------------------
target_dl <- data_list(
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

summary(target_dl)

## -----------------------------------------------------------------------------
set.seed(42)
my_sc <- snf_config(
    dl = input_dl,
    n_solutions = 20,
    min_k = 20,
    max_k = 50
)

my_sc

## -----------------------------------------------------------------------------
my_sc$"settings_df"

## -----------------------------------------------------------------------------
head(as.data.frame(my_sc$"settings_df"))

## -----------------------------------------------------------------------------
names(my_sc)

## -----------------------------------------------------------------------------
sol_df <- batch_snf(input_dl, my_sc)

sol_df

## -----------------------------------------------------------------------------
cluster_solutions <- t(sol_df)

cluster_solutions

## -----------------------------------------------------------------------------
sol_aris <- calc_aris(sol_df)

head(sol_aris)

## ----eval = FALSE-------------------------------------------------------------
# if (!require("BiocManager", quietly = TRUE))
#     install.packages("BiocManager")
# 
# # To make heatmaps with metasnf
# BiocManager::install("ComplexHeatmap")
# 
# # To use heatmap shiny app (later in vignette) with metasnf
# BiocManager::install("InteractiveComplexHeatmap")

## -----------------------------------------------------------------------------
meta_cluster_order <- get_matrix_order(sol_aris)

# Just a vector of numbers
meta_cluster_order

## ----eval = FALSE-------------------------------------------------------------
# ari_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order
# )
# 
# ari_hm

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = ari_hm,
#     path = "vignettes/meta_cluster_heatmap.png",
#     width = 330,
#     height = 300,
#     res = 100
# )

## ----eval = FALSE-------------------------------------------------------------
# shiny_annotator(ari_hm)

## -----------------------------------------------------------------------------
split_vec <- c(2, 5, 12, 17)

## -----------------------------------------------------------------------------
mc_sol_df <- label_meta_clusters(
    sol_df,
    order = meta_cluster_order,
    split_vector = split_vec
)

mc_sol_df

## ----eval = FALSE-------------------------------------------------------------
# ari_mc_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec
# )
# 
# ari_mc_hm

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = ari_mc_hm,
#     path = "vignettes/ari_mc_hm.png",
#     width = 330,
#     height = 300,
#     res = 100
# )

## -----------------------------------------------------------------------------
# Only looking at our out-of-model p-values
ext_sol_df <- extend_solutions(
    mc_sol_df,
    target_dl = target_dl
)

ext_sol_df

# Re-running to calculate the p-value for every single input and out-of-model
# feature:
ext_sol_df <- extend_solutions(
    mc_sol_df,
    dl = input_dl,
    target_dl = target_dl
)

ext_sol_df

## ----eval = FALSE-------------------------------------------------------------
# # No features are used to calculate summary p-values
# ext_sol_df_no_summaries <- extend_solutions(
#     mc_sol_df,
#     dl = c(input_dl, target_dl)
# )
# 
# # Every features are used to calculate summary p-values
# ext_sol_df_all_summaries <- extend_solutions(
#     mc_sol_df,
#     target_dl = c(input_dl, target_dl)
# )

## ----eval = FALSE-------------------------------------------------------------
# annotated_ari_hm <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec,
#     data = as.data.frame(ext_sol_df),
#     top_hm = list(
#         "Depression p-value" = "cbcl_depress_r_pval",
#         "Anxiety p-value" = "cbcl_anxiety_r_pval",
#         "Overall outcomes p-value" = "mean_pval"
#     ),
#     bottom_bar = list(
#         "Number of Clusters" = "nclust"
#     ),
#     annotation_colours = list(
#         "Depression p-value" = colour_scale(
#             ext_sol_df$"cbcl_depress_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Anxiety p-value" = colour_scale(
#             ext_sol_df$"cbcl_anxiety_r_pval",
#             min_colour = "green",
#             max_colour = "black"
#         ),
#         "Overall outcomes p-value" = colour_scale(
#             ext_sol_df$"mean_pval",
#             min_colour = "lightblue",
#             max_colour = "black"
#         )
#     )
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = annotated_ari_hm,
#     path = "vignettes/annotated_ari_hm.png",
#     width = 700,
#     height = 500,
#     res = 100
# )

## ----eval = FALSE-------------------------------------------------------------
# annotation_data <- ext_sol_df |>
#     as.data.frame(keep_attributes = TRUE) |>
#     dplyr::mutate(
#         key_subjects_cluster_together = dplyr::case_when(
#             uid_NDAR_INVLF3TNDUZ == uid_NDAR_INVLDQH8ATK ~ TRUE,
#             TRUE ~ FALSE
#         )
#     )
# 
# annotated_ari_hm2 <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec,
#     data = annotation_data,
#     top_hm = list(
#         "Depression p-value" = "cbcl_depress_r_pval",
#         "Anxiety p-value" = "cbcl_anxiety_r_pval",
#         "Key Subjects Clustered Together" = "key_subjects_cluster_together"
#     ),
#     bottom_bar = list(
#         "Number of Clusters" = "nclust"
#     ),
#     annotation_colours = list(
#         "Depression p-value" = colour_scale(
#             ext_sol_df$"cbcl_depress_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Anxiety p-value" = colour_scale(
#             ext_sol_df$"cbcl_anxiety_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Key Subjects Clustered Together" = c(
#             "TRUE" = "blue",
#             "FALSE" = "black"
#         )
#     )
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = annotated_ari_hm2,
#     path = "vignettes/annotated_ari_hm2.png",
#     width = 700,
#     height = 500,
#     res = 100
# )

## ----eval = FALSE-------------------------------------------------------------
# rep_solutions <- get_representative_solutions(sol_aris, ext_sol_df)
# 
# mc_manhattan <- mc_manhattan_plot(
#     rep_solutions,
#     dl = input_dl,
#     target_dl = target_dl,
#     hide_x_labels = TRUE,
#     point_size = 2,
#     text_size = 12,
#     threshold = 0.05,
#     neg_log_pval_thresh = 5
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# ggplot2::ggsave(
#     "vignettes/mc_manhattan.png",
#     mc_manhattan,
#     height = 4,
#     width = 8,
#     dpi = 100
# )

## ----eval = FALSE-------------------------------------------------------------
# rep_solutions_no_cort <- dplyr::select(rep_solutions, -dplyr::contains("mrisdp"))
# 
# mc_manhattan2 <- mc_manhattan_plot(
#     ext_sol_df = rep_solutions_no_cort,
#     dl = input_dl,
#     target_dl = target_dl,
#     point_size = 4,
#     threshold = 0.01,
#     text_size = 12,
#     domain_colours = c(
#         "neuroimaging" = "cadetblue",
#         "demographics" = "purple",
#         "behaviour" = "firebrick"
#     )
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# ggplot2::ggsave(
#     "vignettes/mc_manhattan2.png",
#     mc_manhattan2,
#     height = 8,
#     width = 12,
#     dpi = 100
# )

## ----eval = FALSE-------------------------------------------------------------
# config_hm <- config_heatmap(
#     sc = my_sc,
#     order = meta_cluster_order,
#     hide_fixed = TRUE
# )

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = config_hm,
#     path = "vignettes/config_hm.png",
#     width = 400,
#     height = 500,
#     res = 75
# )

## ----eval = FALSE-------------------------------------------------------------
# annotation_data <- ext_sol_df |>
#     as.data.frame(keep_attributes = TRUE) |>
#     dplyr::mutate(
#         key_subjects_cluster_together = dplyr::case_when(
#             uid_NDAR_INVLF3TNDUZ == uid_NDAR_INVLDQH8ATK ~ TRUE,
#             TRUE ~ FALSE
#         )
#     )
# 
# annotation_data$"clust_alg" <- as.factor(annotation_data$"clust_alg")
# 
# annotated_ari_hm3 <- meta_cluster_heatmap(
#     sol_aris,
#     order = meta_cluster_order,
#     split_vector = split_vec,
#     data = annotation_data,
#     top_hm = list(
#         "Depression p-value" = "cbcl_depress_r_pval",
#         "Anxiety p-value" = "cbcl_anxiety_r_pval",
#         "Key Subjects Clustered Together" = "key_subjects_cluster_together"
#     ),
#     left_hm = list(
#         "Clustering Algorithm" = "clust_alg" # from the original settings
#     ),
#     bottom_bar = list(
#         "Number of Clusters" = "nclust" # also from the original settings
#     ),
#     annotation_colours = list(
#         "Depression p-value" = colour_scale(
#             ext_sol_df$"cbcl_depress_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Anxiety p-value" = colour_scale(
#             ext_sol_df$"cbcl_anxiety_r_pval",
#             min_colour = "purple",
#             max_colour = "black"
#         ),
#         "Key Subjects Clustered Together" = c(
#             "TRUE" = "blue",
#             "FALSE" = "black"
#         )
#     )
# )
# 
# annotated_ari_hm3

## -----------------------------------------------------------------------------
sol_df <- batch_snf(dl = input_dl, sc = my_sc, return_sim_mats = TRUE)

## ----eval = FALSE-------------------------------------------------------------
# silhouette_scores <- calculate_silhouettes(sol_df)
# dunn_indices <- calculate_dunn_indices(sol_df)
# db_indices <- calculate_db_indices(sol_df)

## -----------------------------------------------------------------------------
ext_sol_df <- extend_solutions(sol_df, target_dl)

## ----eval = FALSE-------------------------------------------------------------
# pval_hm <- pval_heatmap(ext_sol_df, order = meta_cluster_order)
# 
# pval_hm

## ----eval = FALSE, echo = FALSE-----------------------------------------------
# save_heatmap(
#     heatmap = pval_hm,
#     path = "vignettes/pval_heatmap_ordered.png",
#     width = 400,
#     height = 500,
#     res = 100
# )

## -----------------------------------------------------------------------------
# All the observations present in all data frames with no NAs
all_observations <- uids(input_dl)

all_observations

# Remove the "uid_" prefix to allow merges with the original data
all_observations <- gsub("uid_", "", all_observations)

# data frame assigning 80% of observations to train and 20% to test
assigned_splits <- train_test_assign(train_frac = 0.8, uids = all_observations)

# Pulling the training and testing observations specifically
train_obs <- assigned_splits$"train"
test_obs <- assigned_splits$"test"

# Partition a training set
train_cort_t <- cort_t[cort_t$"unique_id" %in% train_obs, ]
train_cort_sa <- cort_sa[cort_sa$"unique_id" %in% train_obs, ]
train_subc_v <- subc_v[subc_v$"unique_id" %in% train_obs, ]
train_income <- income[income$"unique_id" %in% train_obs, ]
train_pubertal <- pubertal[pubertal$"unique_id" %in% train_obs, ]
train_anxiety <- anxiety[anxiety$"unique_id" %in% train_obs, ]
train_depress <- depress[depress$"unique_id" %in% train_obs, ]

# Partition a test set
test_cort_t <- cort_t[cort_t$"unique_id" %in% test_obs, ]
test_cort_sa <- cort_sa[cort_sa$"unique_id" %in% test_obs, ]
test_subc_v <- subc_v[subc_v$"unique_id" %in% test_obs, ]
test_income <- income[income$"unique_id" %in% test_obs, ]
test_pubertal <- pubertal[pubertal$"unique_id" %in% test_obs, ]
test_anxiety <- anxiety[anxiety$"unique_id" %in% test_obs, ]
test_depress <- depress[depress$"unique_id" %in% test_obs, ]

# A data list with just training observations
train_dl <- data_list(
    list(train_cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(train_cort_sa, "cortical_sa", "neuroimaging", "continuous"),
    list(train_subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(train_income, "household_income", "demographics", "continuous"),
    list(train_pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# A data list with training and testing observations
full_dl <- data_list(
    list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# Construct the target lists
train_target_dl <- data_list(
    list(train_anxiety, "anxiety", "behaviour", "ordinal"),
    list(train_depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

# Find a clustering solution in your training data
set.seed(42)
my_sc <- snf_config(
    train_dl,
    n_solutions = 5,
    min_k = 10,
    max_k = 30
)

train_sol_df <- batch_snf(
    train_dl,
    my_sc
)

ext_sol_df <- extend_solutions(
    train_sol_df,
    train_target_dl
)

# The first row had the lowest minimum p-value across our outcomes
lowest_min_pval <- min(ext_sol_df$"min_pval")
which(ext_sol_df$"min_pval" == lowest_min_pval)

# Keep track of your top solution
top_row <- ext_sol_df[1, ]

# Use the solutions data frame from the training observations and the data list from
# the training and testing observations to propagate labels to the test observations
propagated_labels <- label_propagate(top_row, full_dl)

head(propagated_labels)
tail(propagated_labels)

## -----------------------------------------------------------------------------
propagated_labels_all <- label_propagate(
    ext_sol_df,
    full_dl
)

head(propagated_labels_all)
tail(propagated_labels_all)

