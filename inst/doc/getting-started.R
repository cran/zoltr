## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message=FALSE, 
  warning=FALSE,
  eval = nzchar(Sys.getenv("IS_DEVELOPMENT_MACHINE"))
)

## ----setup, include=FALSE-----------------------------------------------------
library(httr)  # o/w devtools::check() gets `could not find function "POST"` error

## ----include=FALSE------------------------------------------------------------
library(zoltr)
zoltar_connection <- new_connection(host = Sys.getenv("Z_HOST"))
zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))
zoltar_connection

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(zoltr)
#  zoltar_connection <- new_connection()
#  zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))
#  zoltar_connection

## -----------------------------------------------------------------------------
the_projects <- projects(zoltar_connection)
str(the_projects)

## -----------------------------------------------------------------------------
project_url <- the_projects[the_projects$name == "Docs Example Project", "url"]
the_project_info <- project_info(zoltar_connection, project_url)
names(the_project_info)
the_project_info$description

the_models <- models(zoltar_connection, project_url)
str(the_models)

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  query <- list("targets" = list("pct next week", "cases next week"), "types" = list("point"))
#  job_url <- submit_query(zoltar_connection, project_url, "forecasts", query)
#  busy_poll_job(zoltar_connection, job_url)
#  the_job_data <- job_data(zoltar_connection, job_url)
#  the_job_data

## -----------------------------------------------------------------------------
forecast_data <- do_zoltar_query(zoltar_connection, project_url, "forecasts", "docs_mod", 
                                 c("loc1", "loc2"), c("pct next week", "cases next week"),
                                 c("2011-10-02", "2011-10-09", "2011-10-16"), types = c("point", "quantile"))
forecast_data

## -----------------------------------------------------------------------------
truth_data <- do_zoltar_query(zoltar_connection, project_url, "truth", NULL, c("loc1", "loc2"),
                              c("pct next week", "cases next week"), c("2011-10-02", "2011-10-09", "2011-10-16"),
                              "2020-12-18 12:00:00 UTC")
truth_data

## -----------------------------------------------------------------------------
the_latest_forecasts <- latest_forecasts(zoltar_connection, project_url)
the_latest_forecasts

## -----------------------------------------------------------------------------
model_url <- the_models[the_models$name == "docs forecast model", "url"]
the_model_info <- model_info(zoltar_connection, model_url)
names(the_model_info)
the_model_info$name

the_forecasts <- forecasts(zoltar_connection, model_url)
str(the_forecasts)

## -----------------------------------------------------------------------------
forecast_url <- the_forecasts[1, "url"]
forecast_info <- forecast_info(zoltar_connection, forecast_url)
forecast_data <- download_forecast(zoltar_connection, forecast_url)
length(forecast_data$predictions)

## -----------------------------------------------------------------------------
forecast_data_frame <- data_frame_from_forecast_data(forecast_data)
str(forecast_data_frame)

## -----------------------------------------------------------------------------
forecast_data_frame <- quantile_data_frame_from_forecast_data(forecast_data)
str(forecast_data_frame)

