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

## ---- include=FALSE------------------------------------------------------
library(zoltr)
conn <- new_connection(host = Sys.getenv("HOST"))
zoltar_authenticate(conn, Sys.getenv("USERNAME"), Sys.getenv("PASSWORD"))
conn

## ---- eval=FALSE, include=TRUE-------------------------------------------
#  library(zoltr)
#  conn <- new_connection()
#  zoltar_authenticate(conn, Sys.getenv("USERNAME"), Sys.getenv("PASSWORD"))
#  conn

## ------------------------------------------------------------------------
the_projects <- projects(conn)
project_id <- the_projects[the_projects$name == Sys.getenv("PROJECT_NAME"), 'id']  # integer(0) if not found, which is an invalid project ID
the_models <- models(conn, project_id)
model_id <- the_models[the_models$name == Sys.getenv("MODEL_NAME"), 'id']  # integer(0) if not found
the_forecasts <- forecasts(conn, model_id)
str(the_forecasts)

## ------------------------------------------------------------------------
timezero_date_str <- Sys.getenv("TIMEZERO_DATE")
timezero_date <- as.Date(timezero_date_str, format = "%Y%m%d")  # YYYYMMDD
existing_forecast_id <- the_forecasts[the_forecasts$timezero_date == timezero_date, 'id']

the_forecast_info <- forecast_info(conn, existing_forecast_id)  # `Not Found (HTTP 404)` this if forecast doesn't exist 
str(the_forecast_info)

delete_forecast(conn, the_forecast_info$id)

## ------------------------------------------------------------------------
busy_poll_upload_file_job <- function(upload_file_job_id) {
    cat(paste0("polling for status change. upload_file_job: ", upload_file_job_id, "\n"))
    while (TRUE) {
        status <- upload_info(conn, upload_file_job_id)$status
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

## ------------------------------------------------------------------------
forecast_csv_file <- Sys.getenv("FORECAST_CSV_FILE")
upload_file_job_id <- upload_forecast(conn, model_id, timezero_date_str, forecast_csv_file)
busy_poll_upload_file_job(upload_file_job_id)

## ------------------------------------------------------------------------
the_upload_info <- upload_info(conn, upload_file_job_id)
str(the_upload_info)

## ------------------------------------------------------------------------

new_forecast_id <- upload_info(conn, upload_file_job_id)$output_json$forecast_pk
the_forecast_info <- forecast_info(conn, new_forecast_id)
str(the_forecast_info)

## ------------------------------------------------------------------------
the_forecasts <- forecasts(conn, model_id)
str(the_forecasts)

