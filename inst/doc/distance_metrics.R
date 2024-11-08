## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## -----------------------------------------------------------------------------
library(metasnf)

distance_metrics_list <- generate_distance_metrics_list()

## -----------------------------------------------------------------------------
summarize_dml(distance_metrics_list)

## -----------------------------------------------------------------------------
my_distance_metrics <- generate_distance_metrics_list(
    continuous_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance
    ),
    discrete_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance
    )
)

summarize_dml(my_distance_metrics)

## -----------------------------------------------------------------------------
library(SNFtool)

data(Data1)
data(Data2)

Data1$"patient_id" <- 101:(nrow(Data1) + 100) # nolint
Data2$"patient_id" <- 101:(nrow(Data2) + 100) # nolint

data_list <- generate_data_list(
    list(Data1, "genes_1_and_2_exp", "gene_expression", "continuous"),
    list(Data2, "genes_1_and_2_meth", "gene_methylation", "continuous"),
    uid = "patient_id"
)

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    distance_metrics_list = my_distance_metrics
)

# showing just the columns that are related to distances
settings_matrix |> dplyr::select(dplyr::ends_with("dist"))

## ----eval = FALSE-------------------------------------------------------------
#  solutions_matrix <- batch_snf(
#      data_list,
#      settings_matrix,
#      distance_metrics_list = my_distance_metrics
#  )

## -----------------------------------------------------------------------------
no_default_metrics <- generate_distance_metrics_list(
    continuous_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance
    ),
    discrete_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance
    ),
    ordinal_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance
    ),
    categorical_distances = list(
        "standard_norm_euclidean" = gower_distance
    ),
    mixed_distances = list(
        "standard_norm_euclidean" = gower_distance
    ),
    keep_defaults = FALSE
)

summarize_dml(no_default_metrics)

## -----------------------------------------------------------------------------
my_distance_metrics <- generate_distance_metrics_list(
    continuous_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance,
        "some_other_metric" = sn_euclidean_distance
    ),
    discrete_distances = list(
        "standard_norm_euclidean" = sn_euclidean_distance,
        "some_other_metric" = sn_euclidean_distance
    )
)

summarize_dml(my_distance_metrics)

settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    distance_metrics_list = my_distance_metrics,
    continuous_distances = 1,
    discrete_distances = c(2, 3)
)

settings_matrix |> dplyr::select(dplyr::ends_with("dist"))

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    distance_metrics_list = my_distance_metrics,
    continuous_distances = 1,
    discrete_distances = c(2, 3)
)

settings_matrix <- add_settings_matrix_rows(
    settings_matrix,
    nrow = 10,
    distance_metrics_list = my_distance_metrics,
    continuous_distances = 3,
    discrete_distances = 1
)

settings_matrix |> dplyr::select(dplyr::ends_with("dist"))

## -----------------------------------------------------------------------------
weights_matrix <- generate_weights_matrix(
    data_list
)

weights_matrix

## -----------------------------------------------------------------------------
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 10,
    distance_metrics_list = my_distance_metrics,
    continuous_distances = 1,
    discrete_distances = c(2, 3)
)

weights_matrix <- generate_weights_matrix(
    data_list,
    nrow = nrow(settings_matrix)
)

weights_matrix[1:5, ]

solutions_matrix_1 <- batch_snf(
    data_list,
    settings_matrix,
    distance_metrics_list = my_distance_metrics,
    weights_matrix = weights_matrix
)

solutions_matrix_2 <- batch_snf(
    data_list,
    settings_matrix,
    distance_metrics_list = my_distance_metrics
)

identical(
    solutions_matrix_1,
    solutions_matrix_2
) # Try this on your machine - It'll evaluate to TRUE

## ----eval = FALSE-------------------------------------------------------------
#  weights_matrix <- generate_weights_matrix(
#      data_list,
#      nrow = nrow(settings_matrix),
#      fill = "uniform" # or fill = "exponential"
#  )

## -----------------------------------------------------------------------------
euclidean_distance

## -----------------------------------------------------------------------------
head(anxiety)

## -----------------------------------------------------------------------------
processed_anxiety <- anxiety |>
    na.omit() |> # no NAs
    dplyr::rename("subjectkey" = "unique_id") |>
    data.frame(row.names = "subjectkey")

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
my_distance_metrics <- generate_distance_metrics_list(
    continuous_distances = list(
        "my_scaled_euclidean" = my_scaled_euclidean
    )
)

