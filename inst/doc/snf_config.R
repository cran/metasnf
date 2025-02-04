## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

dl <- data_list(
    list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

sc <- snf_config(dl, n_solutions = 5)

sc

## -----------------------------------------------------------------------------
sc$"settings_df"

# Printed as a regular data frame
sc$"settings_df" |> as.data.frame()

## -----------------------------------------------------------------------------
dfl <- sc$"dist_fns_list"

dfl

names(dfl)

dfl$"cnt_dist_fns"[[1]]

## -----------------------------------------------------------------------------
cfl <- sc$"clust_fns_list"

cfl

names(cfl)

cfl[[1]]

## -----------------------------------------------------------------------------
wm <- sc$"weights_matrix"

wm

class(wm) <- "matrix"

wm[1:5, 1:5]

## -----------------------------------------------------------------------------
# Through minimums and maximums
sc <- snf_config(
    dl,
    n_solutions = 100
)

sc

## -----------------------------------------------------------------------------
# Through minimums and maximums
sc <- snf_config(
    dl,
    n_solutions = 100,
    min_k = 10,
    max_k = 60,
    min_alpha = 0.3,
    max_alpha = 0.8
)

# Through specific value sampling
sc <- snf_config(
    dl,
    n_solutions = 20,
    k_values = c(10, 25, 50),
    alpha_values = c(0.4, 0.8)
)

## -----------------------------------------------------------------------------
# Exponential dropping
sc <- snf_config(
    dl,
    n_solutions = 20,
    dropout_dist = "exponential" # the default behaviour
)

sc

# Uniform dropping
sc <- snf_config(
    dl,
    n_solutions = 20,
    dropout_dist = "uniform"
)

sc

# No dropping
sc <- snf_config(
    dl,
    n_solutions = 20,
    dropout_dist = "none"
)

sc

## -----------------------------------------------------------------------------
sc <- snf_config(
    dl,
    n_solutions = 20,
    min_removed_inputs = 3
)

# No row will exclude fewer than 3 data frames during SNF
sc

## -----------------------------------------------------------------------------
sc <- snf_config(
    dl,
    n_solutions = 10,
    alpha_values = c(0.3, 0.5, 0.8),
    k_values = c(20, 40, 60),
    dropout_dist = "none"
)

sc

## -----------------------------------------------------------------------------
set.seed(42)
sc_1 <- snf_config(
    dl,
    n_solutions = 25,
    k_values = 50
)

sc_2 <- snf_config(
    dl,
    n_solutions = 25,
    k_values = 80
)

full_sc <- merge(sc_1, sc_2)

