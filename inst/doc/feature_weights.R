## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

# Make sure to throw in all the data you're interested in visualizing for this
# data_list, including out-of-model measures and confounding features.
dl <- data_list(
    list(income, "household_income", "demographics", "ordinal"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(fav_colour, "favourite_colour", "demographics", "categorical"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

summary(dl)

set.seed(42)
sc <- snf_config(
    dl,
    n_solutions = 20,
    min_k = 20,
    max_k = 50
)

sc$"weights_matrix"

## -----------------------------------------------------------------------------
# Random uniformly distributed values
sc <- snf_config(
    dl,
    n_solutions = 20,
    min_k = 20,
    max_k = 50,
    weights_fill = "uniform"
)

sc$"weights_matrix"

# Random exponentially distributed values
sc <- snf_config(
    dl,
    n_solutions = 20,
    min_k = 20,
    max_k = 50,
    weights_fill = "exponential"
)

sc$"weights_matrix"

## ----eval = FALSE-------------------------------------------------------------
# batch_snf(dl = dl, sc = sc)

