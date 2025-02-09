# Build the OpenTable dataset using RSelenium


# Notes
# 1. Currently having a spot of bother getting RSelenium to work on a Github runner, so need to run this locally everyday instead. Hopefully a temp fix.
# 2. RSelenium requires XML pkg and that pkg isn't maintained for R 3.6.2, so I think the problem might be resolved if I update to R 4.0.2


# text me if there's an error
options(error = function() { 
      library(RPushbullet)
      pbPost("note", "Error", geterrmessage())
      if(!interactive()) stop(geterrmessage())
})


setwd("~/R/Projects/Indiana-COVID-19-Tracker")

library(RSelenium); library(glue); library(dplyr)

windows_tasks <- installr::get_tasklist()
java_pid <- windows_tasks %>% 
      filter(stringr::str_detect(`Image Name`, "java.exe")) %>% 
      pull(PID)

chrome_pid <- windows_tasks %>% 
      filter(stringr::str_detect(`Image Name`, "chromedriver.exe")) %>% 
      pull(PID)

tools::pskill(pid = java_pid)
tools::pskill(pid = chrome_pid)





# Get installed stable Google Chrome version ...
if (xfun::is_unix()) {
      
      chrome_driver_version <-
            system2(command = ifelse(xfun::is_macos(),
                                     "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
                                     "google-chrome-stable"),
                    args = "--version",
                    stdout = TRUE,
                    stderr = TRUE) %>%
            stringr::str_extract(pattern = "(?<=Chrome )(\\d+\\.){3}")
      
      ## on Windows a plattform-specific bug prevents us from calling the Google Chrome binary directly to get its version number
      ## cf. https://bugs.chromium.org/p/chromium/issues/detail?id=158372
} else if (xfun::is_windows()) {
      
      chrome_driver_version <-
            system2(command = "wmic",
                    args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
                    stdout = TRUE,
                    stderr = TRUE) %>%
            stringr::str_extract(pattern = "(?<=Version=)(\\d+\\.){3}")
      
} else rlang::abort(message = "Your OS couldn't be determined (Linux, macOS, Windows) or is not supported.")

# ... and determine most recent ChromeDriver version matching it
chrome_driver_version %<>%
      magrittr::extract(!is.na(.)) %>%
      stringr::str_replace_all(pattern = "\\.",
                               replacement = "\\\\.") %>%
      paste0("^",  .) %>%
      stringr::str_subset(string =
                                binman::list_versions(appname = "chromedriver") %>%
                                dplyr::last()) %>%
      as.numeric_version() %>%
      max() %>%
      as.character()


driver <- rsDriver(browser = c("chrome"), chromever = chrome_driver_version)

Sys.sleep(10)

# browser
chrome <- driver$client
# currently this isn't needed to shutdown selenium server
#server <- driver$server

url <- "https://www.opentable.com/state-of-industry"
# go to website
chrome$navigate(url = url)
Sys.sleep(10)

# css selector for the data download button
# "Seated diners from online, phone, and walk-in reservations" (top section of the webpage)
dl_button <- chrome$findElement(using = "css",
                                value = "#mainContent > main > section:nth-child(2) > div:nth-child(4) > div._3ZR5BNaRxlZSImxhkkEzrb > button")
Sys.sleep(5)

# makes the element flash in the browser so you can confirm you have the right thing
# dl_button$highlightElement()

dl_button$clickElement()
# give it a few secs to d/l
Sys.sleep(5)

new_filename <- "YoY_Seated_Diner_Data.csv"
filename <- "2020-2021vs2019_Seated_Diner_Data.csv"
download_location <- file.path(Sys.getenv("USERPROFILE"), "Downloads")
# moves file from download folder to data folder in my project directory
file.rename(file.path(download_location, filename), glue("{rprojroot::find_rstudio_root_file()}/data/{new_filename}"))

# close browser
chrome$close()

# currently this doesn't shutdown the server
# server$stop()

# kill the server manually
# installr::kill_process(process = "java.exe")
# installr::kill_process(process = "chromedriver.exe")

windows_tasks <- installr::get_tasklist()
java_pid <- windows_tasks %>% 
      filter(stringr::str_detect(`Image Name`, "java.exe")) %>% 
      pull(PID)

chrome_pid <- windows_tasks %>% 
      filter(stringr::str_detect(`Image Name`, "chromedriver.exe")) %>% 
      pull(PID)

tools::pskill(pid = java_pid)
tools::pskill(pid = chrome_pid)

