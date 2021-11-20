# This R script is used to pull the still images captured from drone videos along with the lidar data 
# collected during that day and then create the excel spreadsheet required by the Whalength app
# in order to measure each whale. The most important part of this script is the timestamp corrections
# applied to the video start times due to the observed issue with the DJI media created times being different 
# than the lidar times. Thus, we are using the GPS times from the mobile demands to standardize the times
# across systems.

# This script should be fulling functional by the time you are using it. Therefore, all you will need to do 
# when using this code is edit the first three lines under "Manual Inputs" where you are asked to specify the
# filepath to the folder containing the day's images, videos, and lidar data. You then must also specify
# the folder name within the day folder where the still images that are to be measured are stored.
# Finally, you are able to indicate whether you would like to describe the content of each image and some notes 
# about the image that will later be saved to the Whalength app's input excel file. Note that although you can specify
# content and notes about the still images, this can of course also be done manually after running this script.
# Also, you are able to specify within the Whalength app which whale ID number you are measuring, thus making these notes
# and content information less important.

# In order to use the following code, you need to make sure you have the following R packages installed on your computer:
# "tidyverse", "lubridate", "readr", "xlsx", "png", "grid". Without these R packages, this code will not work.

# Unless you run into problems, you shouldn't need to change the code found under "stuff that just needs to run",
# so ignore that for now. As always, let me, David, know if you have any questions by emailing me
# at dsweeney@marecotel.org or by calling me at +1 224-804-7754.

#### Manual Inputs ####
day_folder <- "C:/Users/marec/Docs/UAS/IG UAS Sept-Oct 2021/2021-10-01"  #folder directory for days images
images_folder <- "C:/Users/marec/Docs/UAS/IG UAS Sept-Oct 2021/2021-10-01/Stills/Measured"  #folder directory where stills were stored
img_comment <- FALSE  #TRUE if you wish to add notes and describe the content of each image, FALSE otherwise (if you wish to add comments and use a second app for image viewing, it'll be faster but you'll have to use more screens whereas R can show you the images but they may take a little while to load each time)
Takeoff_alt <- NA #altitude at takeoff (used to standardize barometric pressure reading), put NA if unknown

#### stuff that just needs to run ####
{
  #required packages
  require(tidyverse)
  require(lubridate)
  require(readr)
  require(xlsx)
  require(png)
  require(grid)
  
  #create actual whalength sheet
  image_files <- list.files(images_folder) #file names of images (likely stills) within folder
  day_files <- list.files(day_folder) #all file names within day folder
  
  if ("LidarLog_DailyMaster.csv" %in% day_files == FALSE) { #make sure that all dumped files have been organized and master lidar file is created and in day folder
    # stop("LidarLog_DailyMaster.csv not in day_folder, make sure all images, videos, flightlogs, and lidar data are in day folder")
    stop("LidarLog_DailyMaster.csv not in day_folder, make sure all images, videos, and lidar data are in day folder")
  }
  # if ("DJIFlightLog_Master.csv" %in% day_files == FALSE) { #make sure master flightlog file is created and in day folder
  #   stop("DJIFlightLog_Master.csv not in day_folder, make sure all images, videos, and lidar data are in day folder")
  # }
  
  lidar_data <- read.csv(paste(day_folder, "LidarLog_DailyMaster.csv", sep="/")) %>% #create lidar dataset with posixct datetime column
    filter(!is.na(DateTime)) %>% 
    mutate(DateTime = ymd_hms(DateTime))
  # flightlog_data <- read.csv(paste(day_folder, "DJIFlightLog_Master.csv", sep="/")) %>% #create flightlog dataset with posixct datetime column
  #   mutate(datetime.utc. = ymd_hms(datetime.utc.))
  
  excel_file <- tibble() #initialize dataset
  
  video_files <- unique(paste0(matrix(unlist(strsplit(image_files, ".MOV")),ncol=2,byrow = TRUE)[,1], ".MOV")) #get names of all videos from which stills were obtained
  for (f in 1:length(video_files)) { #iterate through all necessary video files
    
    #determine start datetime of video
    hhmmss <- readline(paste0("When did ", video_files[f], " start? (hhmmss): "))
    vid_start_local <- ymd_hms(paste0(substr(video_files[f], 1, 4),"-",substr(video_files[f], 5,6),"-",substr(video_files[f], 7,8),
                                      substr(hhmmss, 1,2),":",substr(hhmmss, 3,4),":",substr(hhmmss, 5,6)), 
                               tz="America/Los_Angeles")
    vid_start <- vid_start_local %>% with_tz(tzone="UTC")
    
    
    #prepare info about each still image
    vid_stills <- image_files[grepl(video_files[f], image_files)] #still images associated with this video file
    for (s in 1:length(vid_stills)) { #iterate through stills
      `best image` <- vid_stills[s] #still image name
      
      #pull out time from file name of still
      still_times_vec <- as.numeric(strsplit(strsplit(`best image`, "[.]")[[1]][3], "_")[[1]])
      still_secs <- round((still_times_vec[1]*60*60) + 
                            (still_times_vec[2]*60) + 
                            still_times_vec[3] + 
                            (still_times_vec[4]/30))
      `Corrected time` <- vid_start + still_secs
      
      lidarrow <- which.min(abs(difftime(lidar_data$DateTime, `Corrected time`, units = "secs"))) #determine lidar data row that is when this image was taken
      # logrow <- which.min(abs(difftime(flightlog_data$datetime.utc., `Corrected time`, units = "secs"))) #determine flight log data row that is when this image was taken
      
      #add commenting and notes to image if desired (can also be done after the fact)
      if (img_comment) {
        img <- readPNG(paste(stills_folder, vid_stills[s], sep="/")) #display image in R session
        print("Image loading in plots window...")
        grid.raster(img)
        print("What are the contents of this image?")
        Content <- readline("") #write content of image
        print("Do you wish to provide any notes on this image\nthat will be displayed when measuring within the Whalelength app?")
        notes <- readline("") #write notes on image
      } else {
        Content <- notes <- "" #if not adding this stuff, leave blank
      }
      
      #create each row of the master excel file that is used by the Whalength app
      excel_file <- bind_rows(excel_file,
                              tibble(Folder = paste0(strsplit(images_folder, "/")[[1]][(length(strsplit(images_folder,"/")[[1]])-1):length(strsplit(images_folder,"/")[[1]])], collapse="/"),
                                     Content, notes,
                                     `best image`,
                                     VideoStartLocal = vid_start_local, 
                                     VideoStartUTC = vid_start,
                                     `Corrected time`,
                                     Drone = strsplit(strsplit(`best image`, "[.]")[[1]][1],"_")[[1]][2],
                                     Tilt = lidar_data$tilt_deg[lidarrow],
                                     Lidar = lidar_data$laser_altitude_cm[lidarrow],
                                     Bar_alt_uncorrected.m. = "get from flight logs",
                                     Takeoff_alt.m. = Takeoff_alt,
                                     long = lidar_data$longitude[lidarrow],
                                     lat = lidar_data$latitude[lidarrow]) %>% 
                                bind_cols(., lidar_data[lidarrow, c(12:17)]))
    }
  }
  
  #write the excel file into the day folder with the date
  write.xlsx(data.frame(excel_file, check.names = FALSE, fix.empty.names = FALSE), 
             file = paste0(day_folder, "/Whalength_inputdata_", gsub("-", "", strsplit(day_folder, "/")[[1]][length(strsplit(day_folder, "/")[[1]])]), ".xlsx"),
             sheetName = gsub("-", "", strsplit(day_folder, "/")[[1]][length(strsplit(day_folder, "/")[[1]])]),
             row.names = FALSE, append = FALSE, showNA = FALSE)
}

