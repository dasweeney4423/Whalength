# This function is a quick converter from PDT to UTC that is 
# to be used to obtain UTC timestamps (to compare with lidar data) of video still images.
# This code is best used when pulling stills to make sure there is lidar altitude data at the time
# of the desired still.
#
# vidstart = start time of video in PDT
# mins = minutes since start of video that still was captured
# secs = seconds since start of video that still was captured (not counting minutes already input)
# weirdmillis = value shown after seconds since start of video that still was captured (this is a frame value from 0-30)

PDT2UTC <- function(vidstart, mins, secs, weirdmillis) {
  require(tidyverse)
  require(lubridate)
  ymd_hms(vidstart, 
          tz="America/Los_Angeles") %>% 
    with_tz(tzone = "UTC") +
    round((mins*60) + secs + (weirdmillis/30))
}

PDT2UTC("2021-10-05 17:36:05", #start on this date
        0,27,18)
