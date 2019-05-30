## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message=FALSE, 
  warning=FALSE,
  eval = nzchar(Sys.getenv("IS_DEVELOPMENT_MACHINE"))
)

## ----setup, include=FALSE------------------------------------------------
library(httr)  # o/w devtools::check() gets `could not find function "POST"` error

## ------------------------------------------------------------------------
library(zoltr)
conn <- new_connection()
conn

## ------------------------------------------------------------------------
the_projects <- projects(conn)
str(the_projects)

## ------------------------------------------------------------------------
project_id <- the_projects[the_projects$name == "CDC Flu challenge", 'id']  # integer(0) if not found, which is an invalid project ID
the_project_info <- project_info(conn, project_id)
names(the_project_info)
the_project_info$description

the_models <- models(conn, project_id)  # may take some time
str(the_models)

score_data <- scores(conn, project_id)
score_data

## ------------------------------------------------------------------------
model_id <- the_models[the_models$name == "SARIMA model with seasonal differencing", 'id']  # integer(0) if not found
the_model_info <- model_info(conn, model_id)
names(the_model_info)
the_model_info$description

the_forecasts <- forecasts(conn, model_id)
str(the_forecasts)

## ------------------------------------------------------------------------
first_forecast_id <- the_forecasts[1, 'id']  # assumes at least one exists

forecast_data <- forecast_data(conn, first_forecast_id, is_json=TRUE)
forecast_data$locations[[1]]$name
forecast_data$locations[[1]]$targets[[1]]$name
forecast_data$locations[[1]]$targets[[1]]$bins[[1]]

## ------------------------------------------------------------------------
forecast_data <- suppressMessages(forecast_data(conn, first_forecast_id, is_json=FALSE))
forecast_data

