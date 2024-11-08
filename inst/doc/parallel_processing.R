## ----include = FALSE----------------------------------------------------------
# Default chunk options
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>",
    fig.width = 6,
    fig.height = 4.5,
    fig.align = "center"
)

## ----eval = FALSE-------------------------------------------------------------
#  # Load the package
#  library(metasnf)
#  
#  # Setting up the data
#  data_list <- generate_data_list(
#      list(cort_t, "cortical_thickness", "neuroimaging", "continuous"),
#      list(cort_sa, "cortical_surface_area", "neuroimaging", "continuous"),
#      list(subc_v, "subcortical_volume", "neuroimaging", "continuous"),
#      list(income, "household_income", "demographics", "continuous"),
#      list(pubertal, "pubertal_status", "demographics", "continuous"),
#      uid = "unique_id"
#  )
#  
#  # Specifying 5 different sets of settings for SNF
#  set.seed(42)
#  settings_matrix <- generate_settings_matrix(
#      data_list,
#      nrow = 10,
#      max_k = 40
#  )
#  
#  solutions_matrix <- batch_snf(
#      data_list,
#      settings_matrix,
#      processes = "max" # Can also be a specific integer
#  )

## ----eval = FALSE-------------------------------------------------------------
#  progressr::with_progress({
#      solutions_matrix <- batch_snf(
#          data_list,
#          settings_matrix,
#          processes = "max"
#      )
#  })

## ----eval = FALSE-------------------------------------------------------------
#  solutions_matrix <- batch_snf(
#      data_list,
#      settings_matrix,
#      processes = 4
#  )

## ----eval = FALSE-------------------------------------------------------------
#  library(future)
#  
#  availableCores()

