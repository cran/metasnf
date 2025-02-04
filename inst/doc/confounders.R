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

## -----------------------------------------------------------------------------
library(metasnf)

library(SNFtool)
library(ggplot2)

# Generating function for the blocks-per-season of a player
generate_blocks <- function(level, position) {
    # The average blocks per season of all basketball players
    blocks <- rnorm(n = 1, mean = 500, sd = 50)
    # Effect of playing in the pro
    if (level == "pro") {
        blocks <- blocks + rnorm(n = 1, mean = 2000, sd = 100)
    } else {
        # Match the noisiness of the pro players
        blocks <- blocks + rnorm(n = 1, mean = 0, sd = 100)
    }
    # Effect of the player's position
    if (position == "pg") {
        blocks <- blocks + 0 # Just to be explicit about it
    } else if (position == "c") {
        blocks <- blocks + 500
    } else if (position == "sg") {
        blocks <- blocks + 250
    }
    return(blocks)
}

# Generating function for the assists-per-season of a player
generate_assists <- function(level, position) {
    # The average assists per season of all basketball players
    assists <- rnorm(n = 1, mean = 1000, sd = 10)
    # Effect of playing in the pro
    if (level == "pro") {
        assists <- assists + rnorm(n = 1, mean = 2500, sd = 10)
    } else {
        # Match the noisiness of the pro players
        assists <- assists + rnorm(n = 1, mean = 0, sd = 10)
    }
    # Effect of the player's position
    if (position == "pg") {
        assists <- assists + 400 # Just to be explicit about it
    } else if (position == "c") {
        assists <- assists + 0
    } else if (position == "sg") {
        assists <- assists + 200
    }
    return(assists)
}
#
# Helper function to fill in blocks and assists for a player given their
# position and level.
generate_player_data <- function(df) {
    df$"blocks" <- df |> apply(
        MARGIN = 1,
        FUN = function(x) {
            generate_blocks(x[[1]], x[[2]])
        }
    )
    df$"assists" <- df |> apply(
        MARGIN = 1,
        FUN = function(x) {
            generate_assists(x[[1]], x[[2]])
        }
    )
    return(df)
}

# Generate the data
rows <- 300
player_data <- data.frame(
    level = sample(c("regular", "pro"), size = rows, replace = TRUE),
    position = sample(c("pg", "c", "sg"), size = rows, replace = TRUE)
) |> generate_player_data()

player_data$"id" <- as.character(seq_len(nrow(player_data)))

# Plot by position
player_data |>
    ggplot(aes(x = blocks, y = assists, shape = level, colour = position)) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

## -----------------------------------------------------------------------------
set.seed(42)

metasnf_data <- dplyr::select(player_data, "id", "assists", "blocks")

dl <- data_list(
    list(
        data = metasnf_data,
        name = "player_data",
        domain = "player_data",
        type = "continuous"
    ),
    uid = "id"
)

sc <- snf_config(
    dl = dl,
    n_solutions = 1,
    possible_snf_schemes = 1,
    k_values = 20,
    alpha_values = 0.8
)

sol_df <- batch_snf(dl, sc)

cluster_solution_df <- t(sol_df)

# matching the subject names
metasnf_data$"uid" <- paste0("uid_", metasnf_data$"id")

# merging back the original data
metasnf_data <- dplyr::inner_join(metasnf_data, cluster_solution_df, by = "uid")

metasnf_data |>
    ggplot(aes(x = blocks, y = assists, colour = s1)) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

## -----------------------------------------------------------------------------
km <- kmeans(metasnf_data[, c("blocks", "assists")], centers = 2, nstart = 25)

km$"cluster"

metasnf_data$"kmeans" <- factor(km$"cluster")

metasnf_data |>
    ggplot(aes(x = blocks, y = assists, colour = kmeans)) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

## -----------------------------------------------------------------------------
player_data$"adjusted_blocks" <- resid(lm(blocks ~ level, player_data))
player_data$"adjusted_assists" <- resid(lm(assists ~ level, player_data))

# Plot by position
player_data |>
    ggplot(
        aes(
            x = adjusted_blocks,
            y = adjusted_assists,
            shape = level,
            colour = position
        )
    ) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

## -----------------------------------------------------------------------------
head(player_data)

dl <- data_list(
    list(
        data = player_data[, c("id", "blocks", "assists")],
        name = "player_data",
        domain = "player_data",
        type = "continuous"
    ),
    uid = "id"
)

# Correction list for just the level
unwanted_signal_list1 <- data_list(
    list(
        data = player_data[, c("id", "level")],
        name = "player_level",
        domain = "player_data",
        type = "categorical"
    ),
    uid = "id"
)

# Correction list for both player level and position
unwanted_signal_list2 <- data_list(
    list(
        data = player_data[, c("id", "level", "position")],
        name = "player_level",
        domain = "player_data",
        type = "categorical"
    ),
    uid = "id"
)

adjusted_dl <- linear_adjust(dl, unwanted_signal_list1)

# Combine the data from the two data_lists the second list is being merged
# only because it also has the position data, for plotting purposes
merged_df <- as.data.frame(c(adjusted_dl, unwanted_signal_list2))

merged_df |>
    ggplot(aes(x = blocks, y = assists, shape = level, colour = position)) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

# Correcting too many things!
adjusted_dl2 <- linear_adjust(dl, unwanted_signal_list2)

merged_df2 <- as.data.frame(c(adjusted_dl2, unwanted_signal_list2))

merged_df2 |>
    ggplot(aes(x = blocks, y = assists, shape = level, colour = position)) +
    geom_point(size = 5, alpha = 0.3) +
    theme_bw()

