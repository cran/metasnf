#' Run variations of SNF
#'
#' This is the core function of the `metasnf` package. Using the information
#' stored in a settings_df (see ?settings_df) and a data list
#' (see ?data_list), run repeated complete SNF pipelines to generate
#' a broad space of post-SNF cluster solutions.
#'
#' @param dl A nested list of input data from `data_list()`.
#' @param sc An `snf_config` class object which stores all sets of
#'  hyperparameters used to transform data in dl into a cluster solutions. See
#'  `?settings_df` or
#'  https://branchlab.github.io/metasnf/articles/settings_df.html for more
#'  details.
#' @param processes Specify number of processes used to complete SNF iterations
#'  * `1` (default) Sequential processing: function will iterate through the
#'    `settings_df` one row at a time with a for loop. This option will
#'     not make use of multiple CPU cores, but will show a progress bar.
#'  * `2` or higher: Parallel processing will use the
#'    `future.apply::future_apply` to distribute the SNF iterations across
#'    the specified number of CPU cores. If higher than the number of
#'    available cores, a warning will be raised and the maximum number of
#'    cores will be used.
#'  * `max`: All available cores will be used.
#' @param return_sim_mats If TRUE, function will return a list where
#'  the first element is the solutions data frame and the second element is a list
#'  of similarity matrices for each row in the sol_df. Default FALSE.
#' @param sim_mats_dir If specified, this directory will be used to
#'  save all generated similarity matrices.
#' @return By default, returns a solutions data frame (class "data.frame"), a
#'  a data frame containing one row for every row of the provided settings
#'  matrix, all the original columns of that settings data frame, and new columns
#'  containing the assigned cluster of each observation from the cluster
#'  solution derived by that row's settings. If `return_sim_mats` is
#'  TRUE, the function will instead return a list containing the
#'  solutions data frame as well as a list of the final similarity matrices (class
#'  "matrix") generated by SNF for each row of the settings data frame. If
#'  `suppress_clustering` is TRUE, the solutions data frame will not be returned
#'  in the output.
#' @export
#' @examples
#' input_dl <- data_list(
#'     list(gender_df, "gender", "demographics", "categorical"),
#'     list(diagnosis_df, "diagnosis", "clinical", "categorical"),
#'     uid = "patient_id"
#' )
#'
#' sc <- snf_config(input_dl, n_solutions = 3)
#'
#' # A solutions data frame without similarity matrices:
#' sol_df <- batch_snf(input_dl, sc)
#'
#' # A solutions data frame with similarity matrices:
#' sol_df <- batch_snf(input_dl, sc, return_sim_mats = TRUE)
#' sim_mats_list(sol_df)
batch_snf <- function(dl,
                      sc,
                      processes = 1,
                      return_sim_mats = FALSE,
                      sim_mats_dir = NULL) {
    sdf <- sc$"settings_df"
    wm <- sc$"weights_matrix"
    dfl <- sc$"dist_fns_list"
    cfl <- sc$"clust_fns_list"
    check_valid_sc(sc)
    check_valid_k(sdf, dl)
    check_compatible_sdf_wm(sdf, wm)
    check_compatible_sdf_cfl(sdf, cfl)
    check_compatible_sdf_dfl(sdf, dfl)
    # Run SNF
    p <- progressr::progressor(steps = nrow(sdf))
    if (processes == "max") {
        processes <- max(future::availableCores())
    }
    if (processes > 1) {
        future::plan(future::multisession, workers = processes)
        apply_fn <- future.apply::future_lapply
    } else {
        apply_fn <- lapply
    }
    run_snf_results <- apply_fn(
        seq_len(nrow(sdf)),
        run_snf,
        dl = dl,
        sc = sc,
        return_sim_mats = return_sim_mats,
        sim_mats_dir = sim_mats_dir,
        p = p
    )
    if (processes > 1) {
        future::plan(future::sequential)
    }
    # solutions data frame-like object
    sol_dfl <- data.frame(t(sapply(run_snf_results, function(x) x[[1]])))
    colnames(sol_dfl) <- uids(dl)
    sol_dfl$"nclust" <- apply(sol_dfl, 1, function(x) length(unique(x)))
    sol_dfl$"solution" <- as.integer(seq_len(nrow(sol_dfl)))
    sol_dfl$"mc" <- NA_character_
    sol_dfl <- sol_df_col_order(sol_dfl)
    # similarity matrix list-like object
    smll <- lapply(run_snf_results, function(x) x[[2]])
    # initialize and return solutions data frame
    sol_df <- solutions_df(sol_dfl, smll, sc, dl)
    return(sol_df)
}

#' Run SNF
#'
#' Helper function for running a single SNF config pipeline.
#'
#' @keywords internal
#' @inheritParams batch_snf
#' @param i Row of settings_df and weights_matrix within SNF config to use.
#' @return A list containing a cluster solution (numeric vector) and a
#'  the fused network used to create that cluster solution. The fused network
#'  is NULL if return_sim_mats is FALSE.
run_snf <- function(i, dl, sc, return_sim_mats, sim_mats_dir, p) {
    sdf_row <- sc[["settings_df"]][i, ]
    filtered_dl <- drop_inputs(sdf_row, dl)
    if (isTRUE(is.na(filtered_dl))) {
        return(
            list(
                "solution" = rep(NA, n_observations(dl)),
                "fused_network" = NULL
            )
        )
    }
    fused_network <- snf_step(
        dl = drop_inputs(sdf_row, dl),
        scheme = sdf_row$"snf_scheme",
        k = sdf_row$"k",
        alpha = sdf_row$"alpha",
        t = sdf_row$"t",
        cnt_dist_fn = sc$"dist_fns_list"$"cnt_dist_fns"[[sdf_row$"cnt_dist"]],
        dsc_dist_fn = sc$"dist_fns_list"$"dsc_dist_fns"[[sdf_row$"dsc_dist"]],
        ord_dist_fn = sc$"dist_fns_list"$"ord_dist_fns"[[sdf_row$"ord_dist"]],
        cat_dist_fn = sc$"dist_fns_list"$"cat_dist_fns"[[sdf_row$"cat_dist"]],
        mix_dist_fn = sc$"dist_fns_list"$"mix_dist_fns"[[sdf_row$"mix_dist"]],
        weights_row = sc$"weights_matrix"[i, , drop = FALSE]
    )
    solution <- sc$"clust_fns_list"[[sdf_row$"clust_alg"]](fused_network)
    if (!is.null(sim_mats_dir)) {
        path <- similarity_matrix_path(sim_mats_dir, i)
        if (!dir.exists(sim_mats_dir)) {
            metasnf_alert("Creating folder ", sim_mats_dir)
            dir.create(sim_mats_dir, recursive = TRUE)
        }
        utils::write.csv(
            x = fused_network,
            file = path,
            row.names = TRUE
        )
    }
    if (!return_sim_mats) {
        fused_network <- NULL
    }
    if (!is.null(p)) {
        p()
    }
    return(list("solution" = solution, "fused_network" = fused_network))
}

#' Check if SNF config has valid structure
#'
#' @keywords internal
#' @param sc An `snf_config` class object.
#' @return Doesn't return any value. Raises error if snf_config is not an
#'  `snf_config` class object.
check_valid_sc <- function(sc) {
    if (!inherits(sc, "snf_config")) {
        metasnf_error("`sc` must be a `snf_config` class object.")
    }
}

#' Check if max K exceeds the number of observations
#'
#' @keywords internal
#' @inheritParams batch_snf
#' @param sdf A `settings_df` class object.
#' @return Doesn't return any value. Raises error if max K exceeds the number
#'  of observations.
check_valid_k <- function(sdf, dl) {
    max_k <- max(sdf$"k")
    n_observations <- n_observations(dl)
    if (max_k >= n_observations) {
        metasnf_error(
            "Maximum k ({max_k}) cannot exceed number of observations",
            " ({n_observations})."
        )
    }
}

#' Check if settings_df and weights_matrix have same number of rows
#'
#' @keywords internal
#' @param sdf A `settings_df` class object.
#' @param wm A `weights_matrix` class object.
#' @return Doesn't return any value. Raises error if sdf and wm don't have the
#'  same number of rows.
check_compatible_sdf_wm <- function(sdf, wm) {
    if (nrow(sdf) != nrow(wm)) {
        metasnf_error(
            "settings_df and weights_matrix should have equal numbers of rows."
        )
    }
}

#' Check if settings_df exceeds bounds of clust_fns_list
#'
#' @keywords internal
#' @param sdf A `settings_df` class object.
#' @param cfl A `clust_fns_list` class object.
#' @return Doesn't return any value. Raises error if sdf calls for a clustering
#'  function outside the range of cfl.
check_compatible_sdf_cfl <- function(sdf, cfl) {
    if (max(sdf$"clust_alg") > length(cfl)) {
        metasnf_error(
            "Largest clustering algorithm specified in settings data frame (",
            max(sdf$"clust_alg"), ") exceeds length of clustering functions",
            " list (", length(cfl), ")."
        )
    }
}

#' Check if settings_df exceeds bounds of dist_fns_list
#'
#' @keywords internal
#' @param sdf A `settings_df` class object.
#' @param dfl A `dist_fns_list` class object.
#' @return Doesn't return any value. Raises error if sdf calls for a distance
#'  function outside the range of dfl.
check_compatible_sdf_dfl <- function(sdf, dfl) {
    valid_cnt <- max(sdf$"cnt_dist") <= length(dfl$"cnt_dist_fns")
    valid_dsc <- max(sdf$"dsc_dist") <= length(dfl$"dsc_dist_fns")
    valid_ord <- max(sdf$"ord_dist") <= length(dfl$"ord_dist_fns")
    valid_cat <- max(sdf$"cat_dist") <= length(dfl$"cat_dist_fns")
    valid_mix <- max(sdf$"mix_dist") <= length(dfl$"mix_dist_fns")
    valid_dist <- all(valid_cnt, valid_dsc, valid_ord, valid_cat, valid_mix)
    if (!valid_dist) {
        metasnf_error(
            "Largest distance function specified in settings data frame",
            " exceeds length of distance functions list for at least one",
            " distance type."
        )
    }
}

#' Execute inclusion
#'
#' Given a data list and a settings data frame row, returns a data list of
#' selected inputs.
#'
#' @keywords internal
#' @param sdf_row Row of a settings data frame.
#' @param dl A nested list of input data from `data_list()`.
#' @return A data list (class "list") in which any component with a
#'  corresponding 0 value in the provided settings data frame row has been removed.
drop_inputs <- function(sdf_row, dl) {
    if (!inherits(sdf_row, "settings_df")) {
        metasnf_error(
            "`drop_inputs` requires a row of a `settings_df`-class",
            " object."
        )
    }
    # data frame just of the inclusion features
    inc_df <- sdf_row |>
        data.frame()
    inc_df <- gselect(inc_df, "^inc_")
    # The subset of columns that are in 'keep' (1) mode
    keepcols <- colnames(inc_df)[inc_df[1, ] == 1]
    # The list of data list elements that are to be selected
    in_keeps_list <- lapply(dl,
        function(x) {
            paste0("inc_", x$"name") %in% keepcols
        }
    ) # Converting to a logical type to do the selection
    in_keeps_log <- c(unlist(in_keeps_list))
    if (!any(as.logical(in_keeps_log) == TRUE)) {
        metasnf_warning(
            "No data list components selected for inclusion in solution ",
            sdf_row$"solution", "." 
        )
        return(NA)
    }
    # The selection
    selected_dl <- dl[in_keeps_log]
    return(selected_dl)
}

#' Calculate distance matrices
#'
#' Given a data frame of numerical features, return a euclidean distance matrix.
#'
#' @keywords internal
#' @param df Raw data frame with subject IDs in column "uid"
#' @param input_type Either "numeric" (resulting in euclidean distances),
#'  "categorical" (resulting in binary distances), or "mixed" (resulting in
#'  gower distances)
#' @param cnt_dist_fn distance metric function for continuous data
#' @param dsc_dist_fn distance metric function for discrete data
#' @param ord_dist_fn distance metric function for ordinal data
#' @param cat_dist_fn distance metric function for categorical data
#' @param mix_dist_fn distance metric function for mixed data
#' @param weights_row Single-row data frame where the column names contain the
#'  column names in df and the row contains the corresponding weights_row.
#' @return dist_matrix Matrix of inter-observation distances.
get_dist_matrix <- function(df,
                            input_type,
                            cnt_dist_fn,
                            dsc_dist_fn,
                            ord_dist_fn,
                            cat_dist_fn,
                            mix_dist_fn,
                            weights_row) {
    # Move subject keys into data frame row names
    df <- data.frame(df, row.names = "uid")
    # Trim down of the full weights row
    weights_row_trim <-
        weights_row[, colnames(weights_row) %in% colnames(df), drop = FALSE]
    # Use 1 for anything that is not present in weights_row
    missing_weights <-
        df[1, !colnames(df) %in% colnames(weights_row_trim), drop = FALSE]
    missing_weights[, ] <- 1
    weights_row_trim <- cbind(weights_row_trim, missing_weights)
    weights_row_trim <- weights_row_trim[, colnames(df)]
    dist_fns <- list(
        "continuous" = cnt_dist_fn,
        "discrete" = dsc_dist_fn,
        "ordinal" = ord_dist_fn,
        "categorical" = cat_dist_fn,
        "mixed" = mix_dist_fn
    )
    dist_matrix <- dist_fns[[input_type]](df, weights_row_trim)
    return(dist_matrix)
}

#' Helper function for using the correct SNF scheme
#'
#' @keywords internal
#' @param dl A nested list of input data from `data_list()`.
#' @param scheme Which SNF system to use to achieve the final fused network.
#' @param k k hyperparameter.
#' @param alpha alpha/eta/sigma hyperparameter.
#' @param t SNF number of iterations hyperparameter.
#' @param cnt_dist_fn distance metric function for continuous data.
#' @param dsc_dist_fn distance metric function for discrete data.
#' @param ord_dist_fn distance metric function for ordinal data.
#' @param cat_dist_fn distance metric function for categorical data.
#' @param mix_dist_fn distance metric function for mixed data.
#' @param weights_row data frame row containing feature weights.
#' @return A fused similarity network (matrix).
snf_step <- function(dl,
                     scheme,
                     k = 20,
                     alpha = 0.5,
                     t = 20,
                     cnt_dist_fn,
                     dsc_dist_fn,
                     ord_dist_fn,
                     cat_dist_fn,
                     mix_dist_fn,
                     weights_row) {
    fns <- list(
        individual,
        domain_merge,
        two_step_merge
    )
    fused_network <- fns[[scheme]](
        dl,
        k = k,
        alpha = alpha,
        t = t,
        cnt_dist_fn = cnt_dist_fn,
        dsc_dist_fn = dsc_dist_fn,
        ord_dist_fn = ord_dist_fn,
        cat_dist_fn = cat_dist_fn,
        mix_dist_fn = mix_dist_fn,
        weights_row = weights_row
    )
    return(fused_network)
}

#' SNF schemes
#'
#' These functions manage the way in which input data frames are passed into
#' SNF to yield a final fused network.
#'
#' individual: The "vanilla" scheme - does distance matrix conversions of each input
#' data frame separately before a single call to SNF fuses them into the final
#' fused network.
#'
#' domain_merge: Given a data list, returns a new data list where all data objects of
#' a particular domain have been concatenated.
#'
#' two_step_merge: Individual data frames into individual similarity matrices into one fused
#' network per domain into one final fused network.
#'
#' @inheritParams snf_step
#' @name snf_scheme
#' @keywords internal
NULL

#' @keywords internal
#' @rdname snf_scheme
two_step_merge <- function(dl,
                           k = 20,
                           alpha = 0.5,
                           t = 20,
                           cnt_dist_fn,
                           dsc_dist_fn,
                           ord_dist_fn,
                           cat_dist_fn,
                           mix_dist_fn,
                           weights_row) {
    dist_list <- lapply(
        dl,
        function(x) {
            get_dist_matrix(
                df = x$"data",
                input_type = x$"type",
                cnt_dist_fn = cnt_dist_fn,
                dsc_dist_fn = dsc_dist_fn,
                ord_dist_fn = ord_dist_fn,
                cat_dist_fn = cat_dist_fn,
                mix_dist_fn = mix_dist_fn,
                weights_row = weights_row
            )
        }
    )
    sim_list <- lapply(
        dist_list,
        function(x) {
            SNFtool::affinityMatrix(x, K = k, sigma = alpha)
        }
    )
    similarity_list <- dl
    for (i in seq_along(similarity_list)) {
        similarity_list[[i]]$"data" <- sim_list[[i]]
    }
    similarity_unique_dl <- list()
    unique_domains <- unique(unlist(domains(similarity_list)))
    for (i in seq_along(unique_domains)) {
        similarity_unique_dl <- append(similarity_unique_dl, list(list()))
    }
    names(similarity_unique_dl) <- unique_domains
    for (i in seq_along(similarity_list)) {
        al_current_domain <- similarity_list[[i]]$"domain"
        al_current_amatrix <- similarity_list[[i]]$"data"
        audl_domain_pos <- which(
            names(similarity_unique_dl) == al_current_domain
        )
        similarity_unique_dl[[audl_domain_pos]] <- append(
            similarity_unique_dl[[audl_domain_pos]],
            list(al_current_amatrix)
        )
    }
    # Fusing individual matrices into domain similarity matrices
    step_one <- lapply(
        similarity_unique_dl,
        function(x) {
            if (length(x) == 1) {
                x[[1]]
            } else {
                SNFtool::SNF(Wall = x, K = k, t = t)
            }
        }
    )
    # Fusing domain similarity matrices into final fused network
    if (length(step_one) > 1) {
        fused_network <- SNFtool::SNF(Wall = step_one, K = k, t = t)
    } else {
        fused_network <- step_one[[1]]
    }
    return(fused_network)
}

#' @keywords internal
#' @rdname snf_scheme
domain_merge <- function(dl,
                         cnt_dist_fn,
                         dsc_dist_fn,
                         ord_dist_fn,
                         cat_dist_fn,
                         mix_dist_fn,
                         weights_row,
                         k,
                         alpha,
                         t) {
    # list to store all the possible values
    merged_dl <- list()
    for (i in seq_along(dl)) {
        current_domain <- dl[[i]]$"domain"
        current_data <- dl[[i]]$"data"
        current_type <- dl[[i]]$"type"
        merged_dl_domains <- unique(sapply(merged_dl, function(x) x$"domain"))
        if (current_domain %in% merged_dl_domains) {
            # the index of the new data list that already has the domain of the
            #  ith component of the original data list
            existing_pos <- which(merged_dl_domains == current_domain)
            existing_component <- merged_dl[[existing_pos]]
            existing_data <- existing_component$"data"
            existing_type <- existing_component$"type"
            new_data <- dplyr::inner_join(
                existing_data,
                current_data,
                by = "uid"
            )
            if (current_type == existing_type) {
                new_type <- existing_type
            } else {
                new_type <- "mixed"
            }
            merged_dl[[existing_pos]]$"data" <- new_data
            merged_dl[[existing_pos]]$"type" <- new_type
        } else {
            merged_dl[[length(merged_dl) + 1]] <- dl[[i]]
        }
    }
    merged_dl <- merged_dl |>
        lapply(
            function(x) {
                x$"name" <- paste0("merged_", x$"domain")
                return(x)
            }
        )
    # now that we have the merged data list, complete the conversion to
    #  distance and similarity matrices
    dist_list <- lapply(merged_dl,
        function(x) {
            get_dist_matrix(
                df = x$"data",
                input_type = x$"type",
                cnt_dist_fn = cnt_dist_fn,
                dsc_dist_fn = dsc_dist_fn,
                ord_dist_fn = ord_dist_fn,
                cat_dist_fn = cat_dist_fn,
                mix_dist_fn = mix_dist_fn,
                weights_row = weights_row
            )
        }
    )
    sim_list <- lapply(
        dist_list,
        function(x) {
            similarity_matrix <- SNFtool::affinityMatrix(
                x,
                K = k,
                sigma = alpha
            )
            return(similarity_matrix)
        }
    )
    if (length(sim_list) > 1) {
        fused_network <- SNFtool::SNF(Wall = sim_list, K = k, t = t)
    } else {
        fused_network <- sim_list[[1]]
    }
    return(fused_network)
}

#' @keywords internal
#' @rdname snf_scheme
individual <- function(dl,
                       k = 20,
                       alpha = 0.5,
                       t = 20,
                       cnt_dist_fn,
                       dsc_dist_fn,
                       ord_dist_fn,
                       cat_dist_fn,
                       mix_dist_fn,
                       weights_row) {
    dist_list <- lapply(
        dl,
        function(x) {
            get_dist_matrix(
                df = x$"data",
                input_type = x$"type",
                cnt_dist_fn = cnt_dist_fn,
                dsc_dist_fn = dsc_dist_fn,
                ord_dist_fn = ord_dist_fn,
                cat_dist_fn = cat_dist_fn,
                mix_dist_fn = mix_dist_fn,
                weights_row = weights_row
            )
        }
    )
    sim_list <- lapply(
        dist_list,
        function(x) {
            SNFtool::affinityMatrix(x, K = k, sigma = alpha)
        }
    )
    # If only a single similarity matrix is in the sim_list, no need for SNF
    if (length(sim_list) > 1) {
        fused_network <- SNFtool::SNF(Wall = sim_list, K = k, t = t)
    } else {
        fused_network <- sim_list[[1]]
    }
    return(fused_network)
}
