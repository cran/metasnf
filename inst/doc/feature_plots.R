## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

data_list <- generate_data_list(
    list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "continuous"),
    list(fav_colour, "favourite_colour", "misc", "categorical"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

# Build space of settings to cluster over
set.seed(42)
settings_matrix <- generate_settings_matrix(
    data_list,
    nrow = 2,
    min_k = 20,
    max_k = 50
)

# Clustering
solutions_matrix <- batch_snf(data_list, settings_matrix)

sm_row <- solutions_matrix[1, ]

## -----------------------------------------------------------------------------
plot_list <- auto_plot(
    solutions_matrix_row = sm_row,
    data_list = data_list
)

names(plot_list)

plot_list$"household_income"

plot_list$"smri_vol_scs_csf"

plot_list$"colour"

## -----------------------------------------------------------------------------
plot_list$"colour" +
    ggplot2::labs(
        fill = "Favourite Colour",
        x = "Cluster",
        title = "Favourite Colour by Cluster"
    ) +
    ggplot2::scale_fill_manual(
        values = c(
            "green" = "forestgreen",
            "red" = "firebrick3",
            "yellow" = "darkgoldenrod1"
        )
    )

