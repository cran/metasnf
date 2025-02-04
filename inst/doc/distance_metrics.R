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
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

sc <- snf_config(
    dl = dl,
    n_solutions = 5
)

sc$"dist_fns_list"

## -----------------------------------------------------------------------------
sc <- snf_config(
    dl = dl,
    n_solutions = 10,
    cnt_dist_fns = list("standard_norm_euclidean" = sn_euclidean_distance),
    dsc_dist_fns = list("standard_norm_euclidean" = sn_euclidean_distance),
    use_default_dist_fns = TRUE
)

sc

## ----eval = FALSE-------------------------------------------------------------
# sol_df <- batch_snf(dl, sc)

## -----------------------------------------------------------------------------
sc <- snf_config(
    dl = dl,
    n_solutions = 10,
    cnt_dist_fns = list("standard_norm_euclidean" = sn_euclidean_distance),
    dsc_dist_fns = list("standard_norm_euclidean" = sn_euclidean_distance),
    ord_dist_fns = list("standard_norm_euclidean" = sn_euclidean_distance),
    mix_dist_fns = list("standard_norm_euclidean" = gower_distance),
    use_default_dist_fns = FALSE
)

sc

## -----------------------------------------------------------------------------
sc <- snf_config(
    dl = dl,
    n_solutions = 10,
    cnt_dist_fns = list(
        "standard_norm_euclidean" = sn_euclidean_distance,
        "some_other_metric" = sn_euclidean_distance
    ),
    dsc_dist_fns = list(
        "standard_norm_euclidean" = sn_euclidean_distance,
        "some_other_metric" = sn_euclidean_distance
    ),
    use_default_dist_fns = TRUE,
    continuous_distances = 1,
    discrete_distances = c(2, 3)
)

sc

## -----------------------------------------------------------------------------
sc$"weights_matrix"

## ----eval = FALSE-------------------------------------------------------------
# # random weights:
# sc <- snf_config(
#     dl = dl,
#     n_solutions = 10,
#     weights_fill = "uniform" # or fill = "exponential"
# )
# 
# sc
# 
# # custom weights
# fts <- features(dl)
# custom_wm <- matrix(nrow = 10, ncol = length(fts), rnorm(10 * length(fts))^2)
# colnames(custom_wm) <- fts
# custom_wm <- as_weights_matrix(custom_wm)
# 
# sc <- snf_config(
#     dl = dl,
#     n_solutions = 10,
#     wm = custom_wm
# )
# 
# sc

## -----------------------------------------------------------------------------
euclidean_distance

## -----------------------------------------------------------------------------
head(anxiety)

## -----------------------------------------------------------------------------
processed_anxiety <- anxiety |>
    na.omit() |> # no NAs
    dplyr::rename("uid" = "unique_id") |>
    data.frame(row.names = "uid")

head(processed_anxiety)

## -----------------------------------------------------------------------------
my_scaled_euclidean <- function(df, weights_row) {
    # this function won't apply the weights it is given
    distance_matrix <- df |>
        stats::dist(method = "euclidean") |>
        as.matrix() # make sure it's formatted as a matrix
    distance_matrix <- distance_matrix / max(distance_matrix)
    return(distance_matrix)
}

## -----------------------------------------------------------------------------
my_scaled_euclidean(processed_anxiety)[1:5, 1:5]

## -----------------------------------------------------------------------------
sc <- snf_config(
    n_solutions = 10,
    dl = dl,
    cnt_dist_fns = list(
        "my_scaled_euclidean" = my_scaled_euclidean
    ),
    use_default_dist_fns = TRUE
)

sc

