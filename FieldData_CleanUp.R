# Before running this code to process your UAS data from the file format used 
# when quickly dumping data onto a harddrive while in the field, make sure that you have installed the
# "tidyverse", "lubridate", "readr", and "exiftoolr" packages. These four packages are used in the following code
# to organize all of the lidar data files and to copy and then rename the videos and images.

# Once all of the packages are installed, simply change the filepath found below ("Manual Inputs")
# to specify a folder with the day's data that you wish to process. Once the filepath is specified, 
# run this entire R script and it should all work automatically. Once finished running, videos and photos,
# will be renamed using the format yyyymmddhhmmss-drone.MOV. A new file titled LidarLog_DailyMaster.csv
# will also be created that contains all of the lidar data collected throughout the entire day into one csv file.
# All new files and renamed images and videos will be saved in the day's folder.

# This code only copies and pastes newly named versions of all of the collected data. So, you will still have access 
# to the original files within the folders named after the respective drones that collected the data. If you no longer
# need to reference the folder structure used to quickly download and save data while in the field, you can delete those
# drone-named folders to save room on you computer or storage device. HOWEVER, be aware that the newly named videos are 
# not named with the exact start time of the video as marked by the mobile demands. So, if you are going to be comparing lidar
# data times with videos using the file name timestamp, you will need to adjust for this timing issue. The corrected times for
# each video are in the tFlights spreadsheet within each daily database. If you are having trouble getting the correct
# video start time, please let me, David, know and I'd be happy to help.

# Also, please let me know if you have ideas for ways to improve this process, as our Sept-Oct 2021 
# IG trip was the first time this process was used. This folder structure and data management 
#methodology was designed to make saving data quick and easy while in the field while also allowing for 
# easy data management to get all data into the format requirements for the Whalength app used to measure whales.
# There are likely ways to improve things, and I already have a few ideas for our next trips, but any ideas are always welcome.

# Unless you run into problems, you shouldn't need to change the code found under "stuff that just needs to run",
# so ignore that for now. As always, let me, David, know if you have any questions by emailing me
# at dsweeney@marecotel.org or by calling me at +1 224-804-7754.

#### Manual Inputs ####
day_folder <- "C:/Users/marec/Docs/UAS/IG UAS Sept-Oct 2021/2021-10-06"  #folder directory for days images

#### stuff that just needs to run ####
{
  #required packages
  require(tidyverse)
  require(lubridate)
  require(readr)
  require(exiftoolr)
  
  lidar_master <- tibble() #starts dataset

  if ("METRInspire1" %in% list.files(day_folder)) {
    METRInsp1_folders <- list.files(paste(day_folder, "METRInspire1", sep="/")) #folder names for inspire1 where each round of data was dumped
  }
  if ("METRInspire2" %in% list.files(day_folder)) {
    METRInsp2_folders <- list.files(paste(day_folder, "METRInspire2", sep="/")) #folder names for inspire2 where each round of data was dumped
  }
  if ("METRMavic1" %in% list.files(day_folder)) {
    METRMav1_folders <- list.files(paste(day_folder, "METRMavic1", sep="/")) #folder names for mavic1 where each round of data was dumped
  }
  if (length(METRInsp1_folders)>0) {METRInsp1_folders <- paste0("METRInspire1/", METRInsp1_folders)}
  if (length(METRInsp2_folders)>0) {METRInsp2_folders <- paste0("METRInspire2/", METRInsp2_folders)}
  if (length(METRMav1_folders)>0) {METRMav1_folders <- paste0("METRMavic1/", METRMav1_folders)}
  
  for (f in c(METRInsp1_folders, METRInsp2_folders, METRMav1_folders)) { #iterate through dumped folders
    drone <- strsplit(f, "/")[[1]][1] #get which drone these files are from

    #create lidar data master file
    ffiles <- list.files(paste(day_folder, f, sep="/")) #files within individual dumped folder
    lfiles <- ffiles[which(grepl("LOG_",ffiles))] #just the dumped lidar files within folder
    for (l in lfiles) { #iterate through lidar files
      #read and combine all lidar data
      lidar_log <- read_delim(paste(day_folder, f, l, sep="/"), 
                                 delim = "\t", escape_double = FALSE, 
                                 trim_ws = TRUE, skip = 2,
                                 show_col_types = FALSE)
      if (nrow(lidar_log) > 0) {
        lidar_log <- lidar_log %>% 
        mutate(gmt_time = as.character(gmt_time),
               longitude = as.character(longitude),
               latitude = as.character(latitude),
               SOG_kt = as.character(SOG_kt),
               COG = as.character(COG),
               HDOP = as.character(HDOP)) %>% 
        filter(gmt_time != "INVALID", `#gmt_date` != "INVALID")
      }
      if (nrow(lidar_log) > 0) {
        lidar_master <- lidar_log %>% 
          rename(gmt_date = `#gmt_date`) %>% 
          mutate(DateTime = as.character(ymd_hms(paste0("20", gmt_date, " ", gmt_time)))) %>% 
          bind_rows(lidar_master, .)
      }
    }
    
    #rename and move all images and videos to day folder
    dfiles <- ffiles[which(grepl("DJI_",ffiles))] #images and video files from drone (if not using DJI, may need to adjust this line)
    
    for (d in dfiles) { #create unique file numbers throughout day
      filetype <- strsplit(paste(day_folder, f, d, sep="/"),"DJI_")[[1]][2] #determine if video or image
      filetype <- strsplit(filetype, "[.]")[[1]][2] #still determining if video or image
      
      #get the datetime of the start of the created media from exif data
      cd <- ymd_hms(exif_read(paste(day_folder, f, d, sep="/"), "CreateDate")$CreateDate, tz="America/Los_Angeles")
      yyyy <- year(cd)
      mm <- if_else(nchar(month(cd)) == 2, as.character(month(cd)), paste0(0,month(cd)))
      dd <- if_else(nchar(day(cd)) == 2, as.character(day(cd)), paste0(0,day(cd)))
      hh <- if_else(nchar(hour(cd)) == 2, as.character(hour(cd)), paste0(0,hour(cd)))
      minmin <- if_else(nchar(minute(cd)) == 2, as.character(minute(cd)), paste0(0,minute(cd)))
      ss <- if_else(nchar(second(cd)) == 2, as.character(second(cd)), paste0(0,second(cd)))
      
      file.copy(from = paste(day_folder, f, d, sep="/"), #rename file using datetime and add date to file name
                to = paste(day_folder, paste0(yyyy,mm,dd,hh,minmin,ss,
                                              "_",drone,".",filetype), sep="/"))
    }
  }
  
  #create master lidar csv file
  write.csv(lidar_master, paste(day_folder, "LidarLog_DailyMaster.csv", sep="/"), row.names=FALSE)
}