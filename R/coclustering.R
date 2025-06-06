#' Create subsamples of a data list
#'
#' Given a data list, return a list of smaller data lists that are generated
#' through random sampling (without replacement). The results of this function
#' can be passed into `batch_snf_subsamples()` to obtain a list of resampled
#' solutions data frames.
#'
#' @param dl A nested list of input data from `data_list()`.
#' @param n_subsamples Number of subsamples to create.
#' @param subsample_fraction Percentage of patients to include per subsample.
#' @param n_observations Number of patients to include per subsample.
#' @return A "list" class object containing `n_subsamples` number of
#'  data lists. Each of those data lists contains a random `subsample_fraction`
#'  fraction of the observations of the provided data list.
#' @export
#' @examples
#' my_dl <- data_list(
#'     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'     list(income, "household_income", "demographics", "continuous"),
#'     list(pubertal, "pubertal_status", "demographics", "continuous"),
#'     uid = "unique_id"
#' )
#' 
#' my_dl_subsamples <- subsample_dl(
#'     my_dl,
#'     n_subsamples = 20,
#'     subsample_fraction = 0.85
#' )
subsample_dl <- function(dl,
                         n_subsamples,
                         subsample_fraction = NULL,
                         n_observations = NULL) {
    # Make sure that only one parameter was used to specify how many observations
    #  to keep in each subsample
    both_null <- is.null(subsample_fraction) & is.null(n_observations)
    neither_null <- !is.null(subsample_fraction) & !is.null(n_observations)
    if (both_null | neither_null) {
        metasnf_error(
            "Either the subsample_fraction parameter (fraction of",
            " observations) or n_observations (number of observations) must be",
            " provided. Not both (or neither)."
        )
    }
    # Calculate number of observations to keep if fraction parameter was used
    all_observations <- dl[[1]]$"data"$"uid"
    # Ensure n_observations is within 0 and the total number of observations
    if (!is.null(n_observations)) {
        if (n_observations < 0 | n_observations > length(all_observations)) {
            metasnf_error(
                "n_observations must be between 0 and the total number of",
                " observations."
            )
        } else if (as.integer(n_observations) != n_observations) {
            metasnf_error("n_observations must be an integer.")
        }
    }
    # Ensure sample fraction is a real fraction
    if (!is.null(subsample_fraction)) {
        if (subsample_fraction > 1 | subsample_fraction < 0) {
            metasnf_error("subsample_fraction must be between 0 and 1.")
        } else {
            n_observations <- round(subsample_fraction * length(all_observations))
        }
    }
    uid_subsamples <- lapply(
        rep(n_observations, n_subsamples),
        function(x) {
            return(sample(all_observations, x))
        }
    )
    dl_subsamples <- uid_subsamples |> lapply(
        function(subsample) {
            length(subsample)
            dl_subsample <- dl |> dlapply(
                function(x) {
                    chosen_rows <- x$"data"$"uid" %in% subsample
                    x$"data" <- x$"data"[chosen_rows, ]
                    return(x)
                }
            )
        }
    )
    subsample_names <- paste0("subsample_", 1:n_subsamples)
    names(dl_subsamples) <- subsample_names
    return(dl_subsamples)
}

#' Run SNF clustering pipeline on a list of subsampled data lists
#'
#' @inheritParams batch_snf
#' @param dl_subsamples A list of subsampled data lists. This object is
#'  generated by the function `batch_snf_subsamples()`.
#' @return By default, returns a one-element list: `cluster_solutions`, which
#'  is itself a list of cluster solution data frames corresponding to each of
#'  the provided data list subsamples. Setting the parameters
#'  `return_sim_mats`  and `return_solutions` to `TRUE`
#'  will turn the result of the function to a three-element list containing the
#'  corresponding solutions data frames and final fused similarity matrices of
#'  those cluster solutions, should you require these objects for your own
#'  stability calculations.
#' @export
#' @examples
#' \donttest{
#' my_dl <- data_list(
#'     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'     list(income, "household_income", "demographics", "continuous"),
#'     list(pubertal, "pubertal_status", "demographics", "continuous"),
#'     uid = "unique_id"
#' )
#' 
#' sc <- snf_config(my_dl, n_solutions = 5, max_k = 40)
#' 
#' my_dl_subsamples <- subsample_dl(
#'     my_dl,
#'     n_subsamples = 20,
#'     subsample_fraction = 0.85
#' )
#' 
#' batch_subsample_results <- batch_snf_subsamples(
#'     my_dl_subsamples,
#'     sc
#' )
#' }
batch_snf_subsamples <- function(dl_subsamples,
                                 sc,
                                 processes = 1,
                                 return_sim_mats = FALSE,
                                 sim_mats_dir = NULL) {
    # Generate a new solutions data frame for every subsampled data list
    if (!is.null(sim_mats_dir)) {
        sim_mats_dir_s <- paste0(sim_mats_dir, "/subsample-", (seq_along(dl_subsamples)))
    } else {
        sim_mats_dir_s <- lapply(seq_along(dl_subsamples), function(x) NULL)
    }
    p <- progressr::progressor(steps = length(dl_subsamples))
    if (processes == "max") {
        processes <- max(future::availableCores())
    }
    if (processes > 1) {
        future::plan(future::multisession, workers = processes)
        apply_fn <- future.apply::future_mapply
    } else {
        apply_fn <- mapply
    }
    subsample_sol_dfs <- apply_fn(
        function(x, dir_name, p) {
            sol_df <- batch_snf(
                x,
                sc = sc,
                processes = 1,
                return_sim_mats = return_sim_mats,
                sim_mats_dir = dir_name
            )
            p()
            return(sol_df)
        },
        dl_subsamples,
        sim_mats_dir_s,
        MoreArgs = list(
            p = p
        ),
        SIMPLIFY = FALSE
    )
    names(subsample_sol_dfs) <- paste0("subsample_", seq_along(dl_subsamples))
    return(subsample_sol_dfs)
}

#' Calculate pairwise adjusted Rand indices across subsamples of data
#'
#' Given a list of subsampled solutions data frames from
#' '`batch_snf_subsamples()`, this function calculates the adjusted Rand
#' indices across all the subsamples of each solution. ARI calculation between
#' two subsamples only factors in observations that were present in both
#' subsamples.
#'
#' @param subsample_solutions A list of solutions data frames from
#'  subsamples of the data. This object is generated by the function
#'  `batch_snf_subsamples()`.
#' @param verbose If TRUE, output progress to console.
#' @return A two-item list: "raw_aris", a list of inter-subsample pairwise ARI
#'  matrices (one for each full cluster solution) and "ari_summary", a
#'  data frame containing the mean and SD of the inter-subsample ARIs for each
#'  original cluster solution.
#' @export
#' @examples
#' \donttest{
#' my_dl <- data_list(
#'     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'     list(income, "household_income", "demographics", "continuous"),
#'     list(pubertal, "pubertal_status", "demographics", "continuous"),
#'     uid = "unique_id"
#' )
#' 
#' sc <- snf_config(my_dl, n_solutions = 5, max_k = 40)
#' 
#' my_dl_subsamples <- subsample_dl(
#'     my_dl,
#'     n_subsamples = 20,
#'     subsample_fraction = 0.85
#' )
#' 
#' batch_subsample_results <- batch_snf_subsamples(
#'     my_dl_subsamples,
#'     sc
#' )
#' 
#' pairwise_aris <- subsample_pairwise_aris(
#'     batch_subsample_results,
#'     verbose = TRUE
#' )
#' 
#' # Visualize ARIs 
#' ComplexHeatmap::Heatmap(
#'     pairwise_aris$"raw_aris"[[1]],
#'     heatmap_legend_param = list(
#'         color_bar = "continuous",
#'         title = "Inter-Subsample\nARI",
#'         at = c(0, 0.5, 1)
#'     ),
#'     show_column_names = FALSE,
#'     show_row_names = FALSE
#' )
#' }
subsample_pairwise_aris <- function(subsample_solutions,
                                    verbose = FALSE) {
    ###########################################################################
    # If number of subsamples is less than 3, warn that SD can't be calculated
    ###########################################################################
    if (length(subsample_solutions) < 3) {
        metasnf_warning(
            "Fewer than 3 subsamples have been provided. Standard",
            " deviation of the pairwise ARIs for each solution",
            " will not be computed."
        )
    }
    ###########################################################################
    # Skeleton to store the mean and SD of ARIs for each solution
    ###########################################################################
    pairwise_ari_df <- data.frame(
        "row" = integer(),
        "mean_ari" = double(),
        "ari_sd" = double()
    )
    # All the pairwise combinations of subsamples
    pairwise_indices <- utils::combn(length(subsample_solutions), 2)
    subsample_ari_mats <- list()
    ###########################################################################
    # Loop over all the rows of the sol_df
    ###########################################################################
    nrows <- nrow(subsample_solutions[[1]])
    for (row in seq_len(nrows)) {
        subsample_ari_mat <- matrix(
            nrow = length(subsample_solutions),
            ncol = length(subsample_solutions)
        )
        colnames(subsample_ari_mat) <- paste0(
            "subsample_",
            seq_len(length(subsample_solutions))
        )
        rownames(subsample_ari_mat) <- paste0(
            "subsample_",
            seq_len(length(subsample_solutions))
        )
        if (verbose) {
            cat(
                "Calculating pairwise ARIs for solution ", row, "/", nrows,
                "...\n", sep = ""
            )
        }
        row_adjusted_rand_indices <- vector()
        # Loop over all pairs of subsamples for that row
        for (col in seq_len(ncol(pairwise_indices))) {
            # v1 and v2 are indices of two distinct subsamples
            v1 <- pairwise_indices[1, col]
            v2 <- pairwise_indices[2, col]
            subsample_a <- t(subsample_solutions[[v1]])
            subsample_b <- t(subsample_solutions[[v2]])
            # keep column 1 (uid) and column 1 + row
            #  (the solution corresponding to that row)
            solution_a <- subsample_a[, c(1, row + 1)]
            solution_b <- subsample_b[, c(1, row + 1)]
            # remove any observations who weren't a part of both subsamples
            common_df <- dplyr::inner_join(solution_a, solution_b, by = "uid")
            # The first column of common_df contains the uid values. The
            #  2nd and 3rd columns store the two sets of cluster solutions.
            ari <- mclust::adjustedRandIndex(common_df[, 2], common_df[, 3])
            subsample_ari_mat[v1, v2] <- ari
            subsample_ari_mat[v2, v1] <- ari
            row_adjusted_rand_indices <- c(row_adjusted_rand_indices, ari)
        }
        row_df <- data.frame(
            "solution" = row,
            "mean_ari" = mean(row_adjusted_rand_indices),
            "ari_sd" = stats::sd(row_adjusted_rand_indices)
        )
        pairwise_ari_df <- rbind(pairwise_ari_df, row_df)
        diag(subsample_ari_mat) <- 1
        idx <- length(subsample_ari_mats) + 1
        subsample_ari_mats[[idx]] <- subsample_ari_mat
    }
    names(subsample_ari_mats) <- paste0("s", seq_len(nrows))
    results <- list(
        "raw_aris" = subsample_ari_mats,
        "ari_summary" = pairwise_ari_df
    )
    return(results)
}

#' Density plot of co-clustering stability across subsampled data
#'
#' This function creates a density plot that shows, for all pairs of
#' observations that originally clustered together, the distribution of the
#' the fractions that those pairs clustered together across subsampled data.
#'
#' @param cocluster_df A data frame containing co-clustering data for a single
#'  cluster solution. This object is generated by the `calculate_coclustering`
#'  function.
#' @return Density plot (class "gg", "ggplot") of the distribution of
#'  co-clustering across pairs and subsamples of the data.
#' @export
#' @examples
#' \donttest{
#' my_dl <- data_list(
#'     list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'     list(income, "household_income", "demographics", "continuous"),
#'     list(pubertal, "pubertal_status", "demographics", "continuous"),
#'     uid = "unique_id"
#' )
#' 
#' sc <- snf_config(my_dl, n_solutions = 5, max_k = 40)
#' 
#' sol_df <- batch_snf(my_dl, sc)
#' 
#' my_dl_subsamples <- subsample_dl(
#'     my_dl,
#'     n_subsamples = 20,
#'     subsample_fraction = 0.85
#' )
#' 
#' batch_subsample_results <- batch_snf_subsamples(
#'     my_dl_subsamples,
#'     sc
#' )
#'
#' coclustering_results <- calculate_coclustering(
#'     batch_subsample_results,
#'     sol_df,
#'     verbose = TRUE
#' )
#'
#' cocluster_dfs <- coclustering_results$"cocluster_dfs"
#'
#' cocluster_density(cocluster_dfs[[1]])
#' }
cocluster_density <- function(cocluster_df) {
    ###########################################################################
    # dplyr warning handling
    obs_1_clust <- ""
    obs_2_clust <- ""
    cocluster_frac <- ""
    scaled <- ""
    ###########################################################################
    cocluster_df$"obs_1_clust" <- factor(cocluster_df$"obs_1_clust")
    cocluster_df <- cocluster_df |>
        dplyr::filter(obs_1_clust == obs_2_clust)
    # Coverage check
    n_missing <- sum(is.na(cocluster_df$"cocluster_frac"))
    if (n_missing > 0) {
        cocluster_df <- stats::na.omit(cocluster_df)
        metasnf_warning(
            n_missing, " out of ", nrow(cocluster_df), " pairs of",
            " observations that were originally clustered together were",
            " never a part of the same subsampled data list. To avoid",
            " this warning, increase the value of the",
            " `subsample_fraction` or",
            " `n_subsamples` arguments when calling",
            " `subsample_dl()`."
        )
    }
    dist_plot <- cocluster_df |>
        ggplot2::ggplot(
            ggplot2::aes(
                x = cocluster_frac,
                colour = obs_1_clust
            )
        ) +
        ggplot2::labs( x = "Co-clustering Fraction",
            y = "Density",
            colour = "Cluster"
        ) +
        ggplot2::xlim(0, 1) +
        ggplot2::geom_density() +
        ggplot2::theme_bw()
    return(dist_plot)
}

#' Heatmap of observation co-clustering across resampled data
#'
#' Create a heatmap that shows the distribution of observation co-clustering
#' across resampled data.
#'
#' @param cocluster_df A data frame containing co-clustering data for a single
#' cluster solution. This object is generated by the `calculate_coclustering`
#' function.
#'
#' @param cluster_rows Argument passed to `ComplexHeatmap::Heatmap()`.
#' @param cluster_columns Argument passed to `ComplexHeatmap::Heatmap()`.
#' @param show_row_names Argument passed to `ComplexHeatmap::Heatmap()`.
#' @param show_column_names Argument passed to `ComplexHeatmap::Heatmap()`.
#' @param dl See ?similarity_matrix_heatmap.
#' @param data See ?similarity_matrix_heatmap.
#' @param left_bar See ?similarity_matrix_heatmap.
#' @param right_bar See ?similarity_matrix_heatmap.
#' @param top_bar See ?similarity_matrix_heatmap.
#' @param bottom_bar See ?similarity_matrix_heatmap.
#' @param left_hm See ?similarity_matrix_heatmap.
#' @param right_hm See ?similarity_matrix_heatmap.
#' @param top_hm See ?similarity_matrix_heatmap.
#' @param bottom_hm See ?similarity_matrix_heatmap.
#' @param annotation_colours See ?similarity_matrix_heatmap.
#' @param min_colour See ?similarity_matrix_heatmap.
#' @param max_colour See ?similarity_matrix_heatmap.
#' @param ... Arguments passed to `ComplexHeatmap::Heatmap()`.
#' @return Heatmap (class "Heatmap" from ComplexHeatmap) object showing the
#'  distribution of observation co-clustering across resampled data.
#' @export
#' @examples
#' \donttest{
#'     my_dl <- data_list(
#'         list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'         list(income, "household_income", "demographics", "continuous"),
#'         list(pubertal, "pubertal_status", "demographics", "continuous"),
#'         uid = "unique_id"
#'     )
#'     
#'     sc <- snf_config(my_dl, n_solutions = 5, max_k = 40)
#'     
#'     sol_df <- batch_snf(my_dl, sc)
#'     
#'     my_dl_subsamples <- subsample_dl(
#'         my_dl,
#'         n_subsamples = 20,
#'         subsample_fraction = 0.85
#'     )
#'     
#'     batch_subsample_results <- batch_snf_subsamples(
#'         my_dl_subsamples,
#'         sc
#'     )
#'     
#'     coclustering_results <- calculate_coclustering(
#'         batch_subsample_results, 
#'         sol_df,
#'         verbose = TRUE
#'     )
#'     
#'     cocluster_dfs <- coclustering_results$"cocluster_dfs"
#'     
#'     cocluster_heatmap(
#'         cocluster_dfs[[1]],
#'         dl = my_dl,
#'         top_hm = list(
#'             "Income" = "household_income",
#'             "Pubertal Status" = "pubertal_status"
#'         ),
#'         annotation_colours = list(
#'             "Pubertal Status" = colour_scale(
#'                 c(1, 4),
#'                 min_colour = "black",
#'                 max_colour = "purple"
#'             ),
#'             "Income" = colour_scale(
#'                 c(0, 4),
#'                 min_colour = "black",
#'                 max_colour = "red"
#'             )
#'         )
#'     )
#' }
cocluster_heatmap <- function(cocluster_df,
                              cluster_rows = TRUE,
                              cluster_columns = TRUE,
                              show_row_names = FALSE,
                              show_column_names = FALSE,
                              dl = NULL,
                              data = NULL,
                              left_bar = NULL,
                              right_bar = NULL,
                              top_bar = NULL,
                              bottom_bar = NULL,
                              left_hm = NULL,
                              right_hm = NULL,
                              top_hm = NULL,
                              bottom_hm = NULL,
                              annotation_colours = NULL,
                              min_colour = NULL,
                              max_colour = NULL,
                              ...) {
    ###########################################################################
    # dplyr warning handling
    cluster <- ""
    obs_1 <- ""
    obs_1_clust <- ""
    obs_2 <- ""
    obs_2_clust <- ""
    uid <- ""
    ###########################################################################
    # Assemble any provided data
    data <- assemble_data(data = data, dl = dl)
    ###########################################################################
    # Ensure that annotations aren't being requested when data isn't given
    check_dataless_annotations(
        list(
            left_bar,
            right_bar,
            top_bar,
            bottom_bar,
            left_hm,
            right_hm,
            top_hm,
            bottom_hm
        ),
        data
    )
    ###########################################################################
    # Coverage check
    coclustering_coverage_check(cocluster_df, action = "stop")
    ###########################################################################
    # Reconstructing the original cluster solution
    cluster_solution_s1 <- pick_cols(cocluster_df, c("obs_1", "obs_1_clust"))
    cluster_solution_s2 <- pick_cols(cocluster_df, c("obs_2", "obs_2_clust"))
    colnames(cluster_solution_s1) <- c("uid", "cluster")
    colnames(cluster_solution_s2) <- c("uid", "cluster")
    cluster_solution <- rbind(cluster_solution_s1, cluster_solution_s2) |>
        dplyr::distinct() |>
        data.frame() |>
        dplyr::arrange(cluster, uid)
    if (!is.null(dl)) {
        cluster_solution <- dplyr::left_join(
            cluster_solution,
            as.data.frame(dl),
            by = "uid"
        )
    }
    nsubs <- nrow(cluster_solution)
    # Building skeleton matrices to store same-solution and same-cluster
    # tallies
    cocluster_mat <- matrix(ncol = nsubs, nrow = nsubs)
    diag(cocluster_mat) <- 1
    colnames(cocluster_mat) <- cluster_solution$"uid"
    rownames(cocluster_mat) <- cluster_solution$"uid"
    # Loop through the co-clustering data frame and populate the matrices
    for (i in seq_len(nrow(cocluster_df))) {
        row <- cocluster_df[i, ]
        s1 <- row$"obs_1"
        s2 <- row$"obs_2"
        cocluster_mat[s1, s2]  <- row$"cocluster_frac"
        cocluster_mat[s2, s1]  <- row$"cocluster_frac"
    }
    ###########################################################################
    # Generate annotations
    rownames(data) <- data$"uid"
    data <- data[colnames(cocluster_mat), ]
    annotations_list <- generate_annotations_list(
        df = data,
        left_hm = left_hm,
        right_hm = right_hm,
        top_hm = top_hm,
        bottom_hm = bottom_hm,
        left_bar = left_bar,
        right_bar = right_bar,
        top_bar = top_bar,
        bottom_bar = bottom_bar,
        annotation_colours = annotation_colours
    )
    args_list <- list(...)
    if (is.null(args_list$"top_annotation")) {
        args_list$"top_annotation" <- annotations_list$"top_annotations"
    }
    if (is.null(args_list$"left_annotation")) {
        args_list$"left_annotation" <- annotations_list$"left_annotations"
    }
    if (is.null(args_list$"right_annotation")) {
        args_list$"right_annotation" <- annotations_list$"right_annotations"
    }
    if (is.null(args_list$"bottom_annotation")) {
        args_list$"bottom_annotation" <- annotations_list$"bottom_annotations"
    }
    ###########################################################################
    heatmap <- ComplexHeatmap::Heatmap(
        cocluster_mat,
        show_row_names = show_row_names,
        show_column_names = show_column_names,
        cluster_rows = cluster_rows,
        cluster_columns = cluster_columns,
        row_split = cluster_solution$"cluster",
        column_split = cluster_solution$"cluster",
        heatmap_legend_param = list(
            color_bar = "continuous",
            title = "Co-clustering\nFraction",
            at = c(0, 0.5, 1)
        ),
        col = circlize::colorRamp2(
            c(0, 0.5, 1),
            c("#019067", "gray", "#b5400e")
        ),
        top_annotation = annotations_list$"top_annotation",
        ...
    )
    return(heatmap)
}

#' Calculate co-clustering data
#'
#' @param subsample_solutions A list of containing cluster solutions from
#' distinct subsamples of the data. This object is generated by the function
#' `batch_snf_subsamples()`. These solutions should correspond to the ones in
#' the solutions data frame.
#'
#' @param sol_df A solutions data frame. This object is generated by the
#'  function `batch_snf()`. The solutions in the solutions data frame should
#'  correspond to those in the subsample solutions.
#' @param verbose If TRUE, output time remaining estimates to console.
#' @return A list containing the following components:
#' - cocluster_dfs: A list of data frames, one per cluster solution, that shows
#'   the number of times that every pair of observations in the original cluster
#'   solution occurred in the same subsample, the number of times that every
#'   pair clustered together in a subsample, and the corresponding fraction
#'   of times that every pair clustered together in a subsample.
#' - cocluster_ss_mats: The number of times every pair of observations occurred
#'   in the same subsample, formatted as a pairwise matrix.
#' - cocluster_sc_mats: The number of times every pair of observations occurred
#'   in the same cluster, formatted as a pairwise matrix.
#' - cocluster_cf_mats: The fraction of times every pair of observations occurred
#'   in the same cluster, formatted as a pairwise matrix.
#' - cocluster_summary: Specifically among pairs of observations that clustered
#'   together in the original full cluster solution, what fraction of those
#'   pairs remained clustered together throughout the subsample solutions. This
#'   information is formatted as a data frame with one row per cluster solution.
#' @importFrom data.table := setnames setkey as.data.table
#' @export
#' @examples
#' \donttest{
#'     my_dl <- data_list(
#'         list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#'         list(income, "household_income", "demographics", "continuous"),
#'         list(pubertal, "pubertal_status", "demographics", "continuous"),
#'         uid = "unique_id"
#'     )
#'     
#'     sc <- snf_config(my_dl, n_solutions = 5, max_k = 40)
#'     
#'     sol_df <- batch_snf(my_dl, sc)
#'     
#'     my_dl_subsamples <- subsample_dl(
#'         my_dl,
#'         n_subsamples = 20,
#'         subsample_fraction = 0.85
#'     )
#'     
#'     batch_subsample_results <- batch_snf_subsamples(
#'         my_dl_subsamples,
#'         sc
#'     )
#'     
#'     coclustering_results <- calculate_coclustering(
#'         batch_subsample_results,
#'         sol_df,
#'         verbose = TRUE
#'     )
#' }
calculate_coclustering <- function(subsample_solutions,
                                   sol_df,
                                   verbose = FALSE) {
    t_solutions <- lapply(
        subsample_solutions,
        function(x) {
            x <- t(x)
            rownames(x) <- x$"uid"
            return(x)
        }
    )
    ###########################################################################
    # no visible global function definition handling
    cluster <- ""
    obs_1_clust <- ""
    obs_2_clust <- ""
    obs_1 <- ""
    obs_2 <- ""
    in_current_ss <- ""
    uid <- ""
    . <- ""
    same_cluster <- ""
    same_solution <- ""
    cocluster_frac <- ""
    ###########################################################################
    # Data frame that will store summary data
    cocluster_frac_df <- data.frame()
    # List that will optionally track raw co-clustering data
    cocluster_dfs <- list()
    cocluster_ss_mats <- list()
    cocluster_sc_mats <- list()
    cocluster_cf_mats <- list()
    # Data frame containing the cluster solutions from the full data list
    cluster_solutions <- t(sol_df)
    uids <- cluster_solutions$"uid"
    base_cocluster_df <- data.frame(t(utils::combn(uids, 2)))
    colnames(base_cocluster_df) <- c("obs_1", "obs_2")
    n_obs <- length(uids)
    cocluster_mat <- matrix(0, ncol = n_obs, nrow = n_obs)
    diag(cocluster_mat) <- length(t_solutions)
    colnames(cocluster_mat) <- uids
    rownames(cocluster_mat) <- uids
    # Looping over all cluster solutions
    for (idx in seq_len(nrow(sol_df))) {
        if (verbose) {
            cat("Processing solution ", idx, "/", nrow(sol_df), "\n", sep = "")
        }
        cluster_solution <- cluster_solutions[, c(1, idx + 1)]
        # data frame storing all pairs of uids in the full solution
        cocluster_df <- base_cocluster_df
        #----------------------------------------------------------------------
        # Perform the first join
        cocluster_df <- dplyr::left_join(cocluster_df, cluster_solution, dplyr::join_by(obs_1 == uid))
        cocluster_df <- dplyr::left_join(cocluster_df, cluster_solution, dplyr::join_by(obs_2 == uid))
        colnames(cocluster_df)[3:4] <- c("obs_1_clust", "obs_2_clust")
        cocluster_df$"same_solution" <- 0
        cocluster_df$"same_cluster" <- 0
        cocluster_df <- as.data.table(cocluster_df)
        # Process each subsample
        for (subsample in t_solutions) {
            current_ss <- as.data.table(subsample[, c(1, idx + 1)])
            setnames(current_ss, c("uid", "cluster"))
            setkey(current_ss, uid)
            cocluster_df[, in_current_ss := obs_1 %in% current_ss$uid & obs_2 %in% current_ss$uid]
            cocluster_df[in_current_ss == TRUE, same_solution := same_solution + 1]
            cocluster_df[in_current_ss == TRUE & current_ss[.(obs_1)]$cluster == current_ss[.(obs_2)]$cluster, same_cluster := same_cluster + 1]
            cocluster_df[, in_current_ss := NULL]
        }
        cocluster_df <- as.data.frame(cocluster_df)
        cocluster_df_selected <- cocluster_df[, c("obs_1", "obs_2", "same_solution", "same_cluster")]
        new_rows <- data.frame(
          obs_1 = uids,
          obs_2 = uids,
          same_solution = rep(length(t_solutions), length(uids)),
          same_cluster = rep(length(t_solutions), length(uids))
        )
        cocluster_df_full <- rbind(cocluster_df_selected, new_rows)
        ss_mini <- stats::xtabs(cocluster_df_full[, 3] ~ cocluster_df_full[, 1] + cocluster_df_full[, 2])
        sc_mini <- stats::xtabs(cocluster_df_full[, 4] ~ cocluster_df_full[, 1] + cocluster_df_full[, 2])
        cocluster_ss_mat <- unclass(ss_mini + t(ss_mini) - diag(diag(ss_mini)))
        cocluster_sc_mat <- unclass(sc_mini + t(sc_mini) - diag(diag(sc_mini)))
        names(dimnames(cocluster_ss_mat)) <- NULL
        attr(cocluster_ss_mat, "call") <- NULL
        names(dimnames(cocluster_sc_mat)) <- NULL
        attr(cocluster_sc_mat, "call") <- NULL
        cocluster_df$cocluster_frac <- cocluster_df$same_cluster / cocluster_df$same_solution
        cocluster_cf_mat <- cocluster_sc_mat / cocluster_ss_mat
        avg_cocluster_frac <- mean(
            cocluster_df$"cocluster_frac"[
                cocluster_df$"obs_1_clust" == cocluster_df$"obs_2_clust"
            ],
            na.rm = TRUE
        )
        cocluster_frac_df <- rbind(
            cocluster_frac_df,
            data.frame("row" = idx, "avg_cocluster_frac" = avg_cocluster_frac)
        )
        idx <- length(cocluster_dfs) + 1
        cocluster_dfs[[idx]] <- cocluster_df
        cocluster_ss_mats[[idx]] <- cocluster_ss_mat
        cocluster_sc_mats[[idx]] <- cocluster_sc_mat
        cocluster_cf_mats[[idx]] <- cocluster_cf_mat
    }
    incomplete_coverage <- sum(cocluster_df$"same_solution" == 0)
    if (incomplete_coverage > 0) {
        metasnf_warning(
            incomplete_coverage,
            " out of ", nrow(cocluster_df), " originally",
            " co-clustered pairs of observations did not appear in",
            " any of the data list subsamples together. Estimates",
            " of co-clustering quality may be skewed as a result.",
            " Consider increasing the value of the",
            " `subsample_fraction` or",
            " `n_subsamples` arguments when calling",
            " `subsample_dl()`."
        )
    }
    names(cocluster_dfs) <- paste0("row_", length(cocluster_dfs))
    results <- list(
        "cocluster_dfs" = cocluster_dfs,
        "cocluster_ss_mats" = cocluster_ss_mats,
        "cocluster_sc_mats" = cocluster_sc_mats,
        "cocluster_cf_mats" = cocluster_cf_mats,
        "cocluster_summary" = cocluster_frac_df
    )
    return(results)
}

#' Co-clustering coverage check
#'
#' Check if co-clustered data has at least one subsample in which every pair
#' of observations were a part of simultaneously.
#'
#' @keywords internal
#' @param cocluster_df data frame containing co-clustering data.
#' @param action Control if parent function should warn or stop.
#' @return This function does not return any value. It checks a `cocluster_df`
#'  for complete coverage (all pairs occur in the same solution at least once).
#'  Will raise a warning or error if coverage is incomplete depending on the
#'  value of the action parameter.
coclustering_coverage_check <- function(cocluster_df, action = "warn") {
    missing_coclustering <- sum(cocluster_df$"same_solution" == 0)
    if (missing_coclustering > 0) {
        if (action == "warn") {
            metasnf_warning(
                missing_coclustering, " out of ", nrow(cocluster_df),
                " pairs of observations did not appear in",
                " any of the data list subsamples together.",
                " To avoid this warning",
                " try increasing the value of the `subsample_fraction` or",
                " `n_subsamples` when calling `subsample_dl()`."
            )
        } else if (action == "stop") {
            metasnf_error(
                missing_coclustering, " out of ", nrow(cocluster_df),
                " pairs of observations did not appear in",
                " any of the data list subsamples together. This function",
                " requires all pairs of observations to have occurred",
                " in at least 1 subsampled cluster solution.",
                " Try increasing the value of the `subsample_fraction` or",
                " `n_subsamples` when calling `subsample_dl()`."
            )
        }
    }
}
