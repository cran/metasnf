## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

# It's best to list out the individual elements with names, i.e. data = ...,
#  name = ..., domain = ..., type = ..., but we'll skip that here for brevity.
data_list <- generate_data_list(
    list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
    list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    uid = "unique_id"
)

settings_matrix <- generate_settings_matrix(
    data_list
)

head(settings_matrix)

## -----------------------------------------------------------------------------
# Through minimums and maximums
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 100,
)

head(settings_matrix)

## -----------------------------------------------------------------------------
# Through minimums and maximums
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 100,
    min_k = 10,
    max_k = 60,
    min_alpha = 0.3,
    max_alpha = 0.8,
    min_t = 15,
    max_t = 30
)

# Through specific value sampling
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    k_values = c(10, 25, 50),
    alpha_values = c(0.4, 0.8),
    t_values = c(20, 30)
)


## -----------------------------------------------------------------------------
# Exponential dropping
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    dropout_dist = "exponential" # the default behaviour
)

head(settings_matrix)

# Uniform dropping
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    dropout_dist = "uniform"
)

head(settings_matrix)


# No dropping
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    dropout_dist = "none"
)

head(settings_matrix)

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    min_removed_inputs = 3
)

# No row will exclude fewer than 3 dataframes during SNF
head(settings_matrix)

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    alpha_values = c(0.3, 0.5, 0.8),
    k_values = c(20, 40, 60),
    dropout_dist = "none"
)

## -----------------------------------------------------------------------------

settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 50,
    k_values = 50
)

settings_matrix <- add_settings_matrix_rows(
    settings_matrix,
    nrow = 50,
    k_values = 80
)

dim(settings_matrix)

settings_matrix$"k"

