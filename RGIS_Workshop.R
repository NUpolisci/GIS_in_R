# *****************************************************************
# OVERVIEW ####
# *****************************************************************
# RGIS_Workshop.R
# Participant Code for R GIS Workshop
# For use with RGIS Workshop held as part of PS 490 in Spring 2022
# Data sources vary for workshop -- see code comments
# for more details
# NAME:
# Created On:


# *****************************************************************
# PACKAGES AND FUNCTIONS ####
# *****************************************************************

# We need a lot of packages
packages <- c(
  "sf", "tigris", "dplyr", 
  "ggplot2", "purrr", "geosphere",
  "tidycensus", "tidygeocoder", "here")

# This code helps you download the latest versions.
# If this fails, use install.packages and do each by hand
for(i in seq.int(length(packages))){
  if(packages[i] %in% rownames(installed.packages()) == FALSE){
    install.packages(packages[i])
  }
}

library(here)         # For here()
library(tigris)       # For Shape files
library(sf)           # For read_sf(), geom_sf()
library(dplyr)        # For %>% , filter(), select()
library(purrr)        # For map()
library(ggplot2)      # For ggplot()
library(geosphere)    # For distHaversine()
library(tidycensus)   # For FIPS Code Data
library(tidygeocoder) # For geocode()

# *****************************************************************
# SHAPEFILES ####
# *****************************************************************

## Get Shapefiles by Hand ####

# Data come from US Census TigerLINE database
url <- "https://www2.census.gov/geo/tiger/"
extension <- "TIGER2021/TRACT/"
file <- "tl_2021_11_tract.zip"
shp_url <- paste0(url, extension, file)

if (! dir.exists(here::here("data/DC_Tract/"))) {
  dir.create(here::here("data/"))
  download.file(
    shp_url, 
    dest = here::here("data/DC_Tract.zip")
  )
  unzip(here::here("data/DC_Tract.zip"), 
        exdir = here::here("data/DC_Tract"))
}

# If the above fails, uncomment this and run
#browseURL(shp_url)

## Canned Command using tigris ####

# Use the tigris R package
DC_County <- counties("11", year = 2020)
DC_Tract <- tracts("11", year = 2020)

st_crs(DC_County)

# Here is the basic plot
ggplot(DC_Tract)+
  geom_sf(fill = "white")+
  theme_void()

# *****************************************************************
# POINTS OF INTEREST ####
# *****************************************************************

# DC Points of Interest from DC Government
url <- "https://opendata.arcgis.com/api/v3/datasets/"
extension <- "f323f677b3f34fe08956b8fcce3ace44_3/downloads/"
file <- "data?format=shp&spatialRefId=4326"
data_url <- paste0(url, extension, file)

if (! dir.exists(here::here("data/DC_POI/"))) {
  download.file(
    data_url, 
    dest = here::here("data/DC_POI.zip")
  )
  unzip(here::here("data/DC_POI.zip"), 
        exdir = here::here("data/DC_POI"))
}

# Again, if that does not work:
#browseURL(data_url)

# Read in the DC POI Shape File
DC_POI <- read_sf(
  here::here("data/DC_POI/Points_of_Interest.shp")
) %>% 
  mutate(
    long = unlist(map(geometry,1)),
    lat = unlist(map(geometry,2))
  ) 

st_crs(DC_POI)

# Read in Select Places file
Select_Places <- readLines("DC.places")

DC_Destinations <- DC_POI %>% 
  filter(ALIASNAME %in% Select_Places) %>% 
  st_transform(crs = 4269)

# Pick locations
vacation <- c(
  "THOMAS JEFFERSON MEMORIAL",
  "UNITED STATES HOLOCAUST MEMORIAL MUSEUM",
  "US DEPARTMENT OF THE TREASURY",
  "US NAVY MUSEUM",
  "NATIONAL ZOO",
  "US CAPITOL",
  "DUPONT CIRCLE"
)

chosen_places <- DC_Destinations %>% 
  filter(ALIASNAME %in% vacation) %>% 
  select(ALIASNAME, long, lat)

# *****************************************************************
# DISTANCE CALCULATIONS ####
# *****************************************************************

# Prepare data and do calculations
chosen_places <- cbind(
  slice(chosen_places, 1:n()),
  slice(chosen_places, 2:n(), 1)
) %>% 
  rename(
    from       = ALIASNAME,
    start_long = long,
    start_lat  = lat,
    to         = ALIASNAME.1,
    end_long   = long.1,
    end_lat    = lat.1
  ) %>% 
  select(-contains("geometry")) %>% 
  # Calculates distance
  mutate(
    distance = distHaversine(
      p1 = cbind(start_long, start_lat),
      p2 = cbind(end_long, end_lat))
  ) %>% 
  group_by(from) %>% 
  slice(which.min(distance)) %>% 
  # Converts distance to miles and kilometers
  mutate(
    miles = distance/1609.344,
    km    = distance/1000
  )

ggplot(chosen_places, aes(x = start_long, y = start_lat))+
  geom_point(size = 3, color = "red")+
  geom_text(aes(label = from), vjust = -1.5)+
  geom_segment(
    aes(
      x = start_long,
      y = start_lat,
      xend = end_long,
      yend = end_lat
    ),
    arrow = arrow(length = unit(0.3, "inches")),
    size = 1,
    lineend = "round",
    linejoin = "round"
  )+
  theme_bw()

# *****************************************************************
# FULL MAP ####
# *****************************************************************

ggplot(DC_County)+
  geom_sf(fill = "white", color = "black")+
  geom_point(
    chosen_places, 
    mapping = aes(x = start_long, y = start_lat), 
    size = 3, color = "red")+
  geom_text(
    chosen_places, 
    mapping = aes(
      x = start_long, y = start_lat,
      label = from), 
    vjust = -1.25)+
  geom_segment(
    chosen_places, 
    mapping = aes(
      x = start_long,
      y = start_lat,
      xend = end_long,
      yend = end_lat
    ),
    arrow = arrow(length = unit(0.1, "inches")),
    size = 0.5,
    lineend = "round",
    linejoin = "round"
  )+
  theme_void()+
  theme(
    plot.title         = element_text(
      hjust = 0.5, size = 20, colour="black", face = "bold"),
    plot.subtitle      = element_text(
      hjust = 0.5, size = 16, colour="black", face = "bold"),
    legend.title       = element_text(
      hjust = 0.5, size = 14, colour="black", face = "bold"),
    plot.caption       = element_text(
      size = 10, colour="black"),
  )

