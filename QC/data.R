
# packages
library(RODBC)
library(icesTAF)
library(jsonlite)

# utilities
source("QC/utilities.R")

# settings
config <- read_json("QC/config.json", simplifyVector = TRUE)

# create directories
mkdir(config$data_dir)

# connect to DB
conn <- odbcDriverConnect(connection = config$db_connection)

for (country in config$countries) {
  msg("downloading LE data for ... ", country)
  
  # set up sql command
  sqlq <- sprintf("SELECT * FROM dbo._ICES_VMS_Datacall_LE WHERE country = '%s' order by year, ICES_rectangle, gear_code, LE_MET_level6, month, vessel_length_category, fishing_days, vms_enabled", country)
  fname <- paste0(config$data_dir, "/ICES_LE_", country, ".csv")
  
  # fetch
  out <- sqlQuery(conn, sqlq)
  # save to file
  write.csv(out, file = fname, row.names = FALSE)
}


for (country in config$countries) {
  msg("downloading VMS data for ... ", country)
  
  # set up sql command
  sqlq <- sprintf("SELECT * FROM [dbo].[_ICES_VMS_Datacall_VMS] WHERE country = '%s' order by year, c_square, gear_code, LE_MET_level6, month, vessel_length_category, fishing_hours, avg_fishing_speed", country)
  fname <- paste0(config$data_dir, "/ICES_VE_", country, ".csv")
  
  # fetch
  out <- sqlQuery(conn, sqlq)
  # save to file
  write.csv(out, file = fname, row.names = FALSE)
}

# disconnect
odbcClose(conn)
