## ----include = FALSE----------------------------------------------------------
# Default chunk options
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>",
    fig.width = 6,
    fig.height = 4.5,
    fig.align = "center"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## ----eval = FALSE-------------------------------------------------------------
# # Load the package
# library(metasnf)
# 
# # Setting up the data
# dl <- data_list(
#     list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
#     list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
#     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#     list(income, "household_income", "demographics", "continuous"),
#     list(pubertal, "pubertal_status", "demographics", "continuous"),
#     uid = "unique_id"
# )
# 
# # Specifying 10 different sets of settings for SNF
# set.seed(42)
# sc <- snf_config(
#     dl = dl,
#     n_solutions = 10,
#     max_k = 40
# )
# 
# sol_df <- batch_snf(
#     dl,
#     sc,
#     processes = "max" # Can also be a specific integer
# )

## ----eval = FALSE-------------------------------------------------------------
# progressr::with_progress({
#     sol_df <- batch_snf(
#         dl,
#         sc,
#         processes = "max"
#     )
# })

## ----eval = FALSE-------------------------------------------------------------
# sol_df <- batch_snf(
#     dl,
#     sc,
#     processes = 4
# )

## ----eval = FALSE-------------------------------------------------------------
# future::availableCores()

