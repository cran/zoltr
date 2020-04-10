## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  message=FALSE, 
  warning=FALSE,
  eval = nzchar(Sys.getenv("IS_DEVELOPMENT_MACHINE"))
)

## ----setup, include=FALSE-----------------------------------------------------
library(httr)  # o/w devtools::check() gets `could not find function "POST"` error

## ---- include=FALSE-----------------------------------------------------------
library(zoltr)
zoltar_connection <- new_connection(host = Sys.getenv("Z_HOST"))
zoltar_authenticate(zoltar_connection, Sys.getenv("Z_USERNAME"), Sys.getenv("Z_PASSWORD"))

## ---- eval=FALSE, include=TRUE------------------------------------------------
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
                     "home_url" = "http://example.com/",
                     "aux_data_url" = "http://example.com/")
model_url <- create_model(zoltar_connection, project_url, model_config)

## -----------------------------------------------------------------------------
busy_poll_upload_file_job <- function(zoltar_connection, upload_file_job_url) {
  cat(paste0("polling for status change. upload_file_job: ", upload_file_job_url, "\n"))
  while (TRUE) {
    status <- upload_info(zoltar_connection, upload_file_job_url)$status
    cat(paste0(status, "\n"))
    if (status == "FAILED") {
      cat(paste0("x failed\n"))
      break
    }
    if (status == "SUCCESS") {
      break
    }
    Sys.sleep(1)
  }
}

## -----------------------------------------------------------------------------
forecast_data <- jsonlite::read_json("docs-predictions.json")
upload_file_job_url <- upload_forecast(zoltar_connection, model_url, "2011-10-02", forecast_data)
busy_poll_upload_file_job(zoltar_connection, upload_file_job_url)

## -----------------------------------------------------------------------------
the_upload_info <- upload_info(zoltar_connection, upload_file_job_url)
forecast_url <- upload_info_forecast_url(zoltar_connection, the_upload_info)
the_forecast_info <- forecast_info(zoltar_connection, forecast_url)
the_forecasts <- forecasts(zoltar_connection, the_forecast_info$forecast_model_url)
str(the_forecasts)

## -----------------------------------------------------------------------------
delete_project(zoltar_connection, project_url)

