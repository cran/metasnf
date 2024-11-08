## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(metasnf)

# Make sure to throw in all the data you're interested in visualizing for this
# data_list, including out-of-model measures and confounding features.
data_list <- generate_data_list(
    list(income, "household_income", "demographics", "ordinal"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(fav_colour, "favourite_colour", "demographics", "categorical"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

summarize_dl(data_list)

set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 20,
    min_k = 20,
    max_k = 50
)

weights_matrix <- generate_weights_matrix(
    data_list,
    nrow = 20
)

head(weights_matrix)

## -----------------------------------------------------------------------------
# Random uniformly distributed values
generate_weights_matrix(
    data_list,
    nrow = 5,
    fill = "uniform"
)

# Random exponentially distributed values
generate_weights_matrix(
    data_list,
    nrow = 5,
    fill = "exponential"
)

## ----eval = FALSE-------------------------------------------------------------
#  batch_snf(
#      data_list = data_list,
#      settings_matrix = settings_matrix,
#      weights_matrix = weights_matrix
#  )

