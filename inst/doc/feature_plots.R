## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----echo = FALSE-------------------------------------------------------------
options(crayon.enabled = FALSE, cli.num_colors = 0)

## -----------------------------------------------------------------------------
library(metasnf)

dl <- data_list(
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
sc <- snf_config(
    dl = dl,
    n_solutions = 2,
    min_k = 20,
    max_k = 50
)

# Clustering
sol_df <- batch_snf(dl, sc)

sol_df_row <- sol_df[1, ]

## -----------------------------------------------------------------------------
plot_list <- auto_plot(
    sol_df_row = sol_df_row,
    dl = dl,
    verbose = TRUE
)

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

