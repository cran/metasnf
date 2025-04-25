## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

dl <- data_list(
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

set.seed(42)
sc <- snf_config(
    dl = dl,
    n_solutions = 2,
    min_k = 20,
    max_k = 50
)

# Generation of 20 cluster solutions
sol_df <- batch_snf(dl, sc)

# Let's just calculate NMIs of the anxiety and depression data types for the
# first 5 cluster solutions to save time:
feature_nmis <- calc_nmis(dl[4:5], sol_df)

print(feature_nmis)

