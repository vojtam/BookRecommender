if (file.exists("renv")) {
  #Sys.setenv(RENV_DOWNLOAD_FILE_METHOD = "libcurl")
  #options(repos="http://cran.rstudio.com/")
  #options(renv.download.override = utils::download.file)
  source("renv/activate.R")
} else {
  # The `renv` directory is automatically skipped when deploying with rsconnect.
  message("No 'renv' directory found; renv won't be activated.")
}

# Allow absolute module imports (relative to the app root).
options(box.path = getwd())

