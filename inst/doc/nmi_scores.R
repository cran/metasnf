## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
library(metasnf)

data_list <- generate_data_list(
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    min_k = 20,
    max_k = 50
)

# Generation of 20 cluster solutions
solutions_matrix <- batch_snf(data_list, settings_matrix)

# Let's just calculate NMIs of the anxiety and depression data types for the
# first 5 cluster solutions to save time:
feature_nmis <- batch_nmi(data_list[4:5], solutions_matrix[1:5, ])

print(feature_nmis)

