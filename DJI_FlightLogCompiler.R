#### Manual Inputs ####
day_folder <- "C:/Users/marec/Docs/UAS/IG UAS Sept-Oct 2021/2021-10-02"  #folder directory for days images

#### stuff that just needs to run ####
{
  #required packages
  require(tidyverse)
  require(lubridate)
  require(readr)
  require(exiftoolr)
  
  log_master <- tibble() #create master log to rbind to later
  
  for (f in list.files(paste0(day_folder,"/FlightLogs"))) { #iterate through dumped folders
    #read and combine all flight log data
    log_master <- read_csv(paste0(day_folder,"/FlightLogs/",f), 
                          col_types = cols(`datetime(utc)` = col_datetime(format = "%Y-%m-%d %H:%M:%S"))) %>% 
      bind_rows(log_master, .)
  }
  
  #create master flight log csv file
  write.csv(log_master, paste(day_folder, "DJIFlightLog_Master.csv", sep="/"), row.names=FALSE)
}
