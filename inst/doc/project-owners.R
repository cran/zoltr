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

## ----eval=FALSE, include=TRUE-------------------------------------------------
#  library(zoltr)
#  zoltar_connection <- new_connection()
#  zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))

## -----------------------------------------------------------------------------
project_config <- jsonlite::read_json("docs-project.json")  # "name": "My project"
project_url <- create_project(zoltar_connection, project_config)
the_project_info <- project_info(zoltar_connection, project_url)

## -----------------------------------------------------------------------------
model_config <- list("name" = "a model_name",
                     "abbreviation" = "an abbreviation",
                     "team_name" = "a team_name",
                     "description" = "a description",
                     "contributors" = "the contributors",
                     "license" = "other",
                     "notes" = "some notes",
                     "citation" = "a citation",
                     "methods" = "the methods",
                     "home_url" = "http://example.com/",
                     "aux_data_url" = "http://example.com/")
model_url <- create_model(zoltar_connection, project_url, model_config)

## -----------------------------------------------------------------------------
forecast_data <- jsonlite::read_json("docs-predictions.json")
job_url <- upload_forecast(zoltar_connection, model_url, "2011-10-02", forecast_data, TRUE)
busy_poll_job(zoltar_connection, job_url)

## -----------------------------------------------------------------------------
the_job_info <- job_info(zoltar_connection, job_url)
forecast_url <- job_info_forecast_url(zoltar_connection, the_job_info)
the_forecast_info <- forecast_info(zoltar_connection, forecast_url)
the_forecasts <- forecasts(zoltar_connection, the_forecast_info$forecast_model_url)
str(the_forecasts)

## -----------------------------------------------------------------------------
delete_project(zoltar_connection, project_url)

