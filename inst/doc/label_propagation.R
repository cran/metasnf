## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

# Function to identify obervations with complete data
uids_with_complete_obs <- get_complete_uids(
    list(
        cort_t,
        cort_sa,
        subc_v,
        income,
        pubertal,
        anxiety,
        depress
    ),
    uid = "unique_id"
)

# Dataframe assigning 80% of observations to train and 20% to test
train_test_split <- train_test_assign(
    train_frac = 0.8,
    uids = uids_with_complete_obs
)

# Pulling the training and testing observations specifically
train_obs <- train_test_split$"train"
test_obs <- train_test_split$"test"

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

# Find cluster solutions in the training set
train_dl <- data_list(
    list(train_cort_t, "cort_t", "neuroimaging", "continuous"),
    list(train_cort_sa, "cortical_sa", "neuroimaging", "continuous"),
    list(train_subc_v, "subc_v", "neuroimaging", "continuous"),
    list(train_income, "household_income", "demographics", "continuous"),
    list(train_pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# We'll pick a solution that has good separation over our target features
train_target_dl <- data_list(
    list(train_anxiety, "anxiety", "behaviour", "ordinal"),
    list(train_depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

set.seed(42)
sc <- snf_config(
    train_dl,
    n_solutions = 5,
    min_k = 10,
    max_k = 30
)

train_sol_df <- batch_snf(
    train_dl,
    sc,
    return_sim_mats = TRUE
)

ext_sol_df <- extend_solutions(
    train_sol_df,
    train_target_dl
)

# Determining solution with the lowest minimum p-value
lowest_min_pval <- min(ext_sol_df$"min_pval")
which(ext_sol_df$"min_pval" == lowest_min_pval)
top_row <- ext_sol_df[1, ]

# Propagate that solution to the observations in the test set
# data list below has both training and testing observations
full_dl <- data_list(
    list(cort_t, "cort_t", "neuroimaging", "continuous"),
    list(cort_sa, "cort_sa", "neuroimaging", "continuous"),
    list(subc_v, "subc_v", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# Use the solutions data frame from the training observations and the data list from
# the training and testing observations to propagate labels to the test observations
propagated_labels <- label_propagate(top_row, full_dl)

head(propagated_labels)
tail(propagated_labels)

## -----------------------------------------------------------------------------
propagated_labels_all <- label_propagate(ext_sol_df, full_dl)

head(propagated_labels_all)
tail(propagated_labels_all)

