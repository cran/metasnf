## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
library(metasnf)

# Start by making a data list containing all our dataframes to more easily
# identify subjects without missing data
all_subjects <- generate_data_list(
    list(cort_t, "cort_t", "neuroimaging", "continuous"),
    list(cort_sa, "cort_sa", "neuroimaging", "continuous"),
    list(subc_v, "subc_v", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

# Get a vector of all the subjects
all_subjects <- get_dl_subjects(all_subjects)

# Dataframe assigning 80% of subjects to train and 20% to test
train_test_split <- train_test_assign(
    train_frac = 0.8,
    subjects = all_subjects
)

# Pulling the training and testing subjects specifically
train_subs <- train_test_split$"train"
test_subs <- train_test_split$"test"

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

# Find cluster solutions in the training set
train_data_list <- generate_data_list(
    list(train_cort_t, "cort_t", "neuroimaging", "continuous"),
    list(train_cort_sa, "cortical_sa", "neuroimaging", "continuous"),
    list(train_subc_v, "subc_v", "neuroimaging", "continuous"),
    list(train_income, "household_income", "demographics", "continuous"),
    list(train_pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

# We'll pick a solution that has good separation over our target features
train_target_list <- generate_data_list(
    list(train_anxiety, "anxiety", "behaviour", "ordinal"),
    list(train_depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

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

# Determining solution with the lowest minimum p-value
lowest_min_pval <- min(extended_solutions_matrix$"min_pval")
which(extended_solutions_matrix$"min_pval" == lowest_min_pval)
top_row <- extended_solutions_matrix[4, ]

# Propagate that solution to the subjects in the test set
# data list below has both training and testing subjects
full_data_list <- generate_data_list(
    list(cort_t, "cort_t", "neuroimaging", "continuous"),
    list(cort_sa, "cort_sa", "neuroimaging", "continuous"),
    list(subc_v, "subc_v", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

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

