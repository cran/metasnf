## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

# We'll just use the first few columns for this demo
cort_sa_minimal <- cort_sa[, 1:5]

# And one more mock categorical feature for demonstration purposes
city <- fav_colour
city$"city" <- sample(
    c("toronto", "montreal", "vancouver"),
    size = nrow(city),
    replace = TRUE
)
city <- city |> dplyr::select(-"colour")

# Make sure to throw in all the data you're interested in visualizing for this
# data_list, including out-of-model measures and confounding features.
data_list <- generate_data_list(
    list(cort_sa_minimal, "cortical_sa", "neuroimaging", "continuous"),
    list(income, "household_income", "demographics", "ordinal"),
    list(pubertal, "pubertal_status", "demographics", "continuous"),
    list(fav_colour, "favourite_colour", "demographics", "categorical"),
    list(city, "city", "demographics", "categorical"),
    list(anxiety, "anxiety", "behaviour", "ordinal"),
    list(depress, "depressed", "behaviour", "ordinal"),
    uid = "unique_id"
)

summarize_dl(data_list)

# This matrix contains all the pairwise association p-values
assoc_pval_matrix <- calc_assoc_pval_matrix(data_list)

assoc_pval_matrix[1:3, 1:3]

## ----eval = FALSE-------------------------------------------------------------
#  ap_heatmap <- assoc_pval_heatmap(
#      assoc_pval_matrix
#  )
#  
#  save_heatmap(
#      ap_heatmap,
#      "assoc_pval_heatmap.png",
#      width = 650,
#      height = 500,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  ap_heatmap2 <- assoc_pval_heatmap(
#      assoc_pval_matrix,
#      confounders = list(
#          "Colour" = "colour",
#          "Pubertal Status" = "pubertal_status"
#      ),
#      out_of_models = list(
#          "City" = "city"
#      )
#  )
#  
#  save_heatmap(
#      ap_heatmap2,
#      "assoc_pval_heatmap2.png",
#      width = 680,
#      height = 500,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  ap_heatmap3 <- assoc_pval_heatmap(
#      assoc_pval_matrix,
#      confounders = list(
#          "Colour" = "colour",
#          "Pubertal Status" = "pubertal_status"
#      ),
#      out_of_models = list(
#          "City" = "city"
#      ),
#      row_km = 3,
#      column_km = 3
#  )
#  
#  save_heatmap(
#      ap_heatmap3,
#      "assoc_pval_heatmap3.png",
#      width = 680,
#      height = 500,
#      res = 100
#  )

## ----eval = FALSE-------------------------------------------------------------
#  ap_heatmap4 <- assoc_pval_heatmap(
#      assoc_pval_matrix,
#      confounders = list(
#          "Colour" = "colour",
#          "Pubertal Status" = "pubertal_status"
#      ),
#      out_of_models = list(
#          "City" = "city"
#      ),
#      data_list = data_list,
#      split_by_domain = TRUE
#  )
#  
#  save_heatmap(
#      ap_heatmap4,
#      "assoc_pval_heatmap4.png",
#      width = 700,
#      height = 500,
#      res = 100
#  )

