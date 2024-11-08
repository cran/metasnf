## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## -----------------------------------------------------------------------------
library(metasnf)

# Preparing some mock data
heart_rate_df <- data.frame(
    patient_id = c("1", "2", "3"),
    var1 = c(0.04, 0.1, 0.3),
    var2 = c(30, 2, 0.3)
)

personality_test_df <- data.frame(
    patient_id = c("1", "2", "3"),
    var3 = c(900, 1990, 373),
    var4 = c(509, 2209, 83)
)

survey_response_df <- data.frame(
    patient_id = c("1", "2", "3"),
    var5 = c(1, 3, 3),
    var6 = c(2, 3, 3)
)

city_df <- data.frame(
    patient_id = c("1", "2", "3"),
    var7 = c("toronto", "montreal", "vancouver")
)

# Generating a data_list explicitly (Name each nested list element):
data_list <- generate_data_list(
    list(
        data = heart_rate_df,
        name = "heart_rate",
        domain = "clinical",
        type = "continuous"
    ),
    list(
        data = personality_test_df,
        name = "personality_test",
        domain = "surveys",
        type = "continuous"
    ),
    list(
        data = survey_response_df,
        name = "survey_response",
        domain = "surveys",
        type = "ordinal"
    ),
    list(
        data = city_df,
        name = "city",
        domain = "location",
        type = "categorical"
    ),
    uid = "patient_id"
)

# Achieving the same result compactly:
data_list <- generate_data_list(
    list(heart_rate_df, "heart_rate", "clinical", "continuous"),
    list(personality_test_df, "personality_test", "surveys", "continuous"),
    list(survey_response_df, "survey_response", "surveys", "ordinal"),
    list(city_df, "city", "location", "categorical"),
    uid = "patient_id"
)

# Printing data_list summaries
summarize_dl(data_list)

## -----------------------------------------------------------------------------
list_of_lists <- list(
    list(heart_rate_df, "data1", "domain1", "continuous"),
    list(personality_test_df, "data2", "domain2", "continuous")
)

## -----------------------------------------------------------------------------
dl <- generate_data_list(
    list_of_lists,
    uid = "patient_id"
)

summarize_dl(dl)

