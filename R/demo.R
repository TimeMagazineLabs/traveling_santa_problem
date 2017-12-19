library(sp)
library(TSP)

source("lib/map_route.R")

#we have to dictate the content types or R will think FIPS codes are numeric
counties <- read.csv("../data/counties.csv", 
  colClasses = c(rep("character", 3), rep("numeric", 5))                     
)

coords.df <- data.frame(long=counties$long, lat=counties$lat)
#TSP prefers a matrix
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)
labels <- counties$name

#initialize the tsp object. This does not compute the route, it just loads the data needed to do so
tsp <- TSP(dist.mx, labels=labels)

#1145 is the index of Aroostook County, Maine
tour <- solve_TSP(tsp, method = "nn", start = 1145)

plot_county_tour(counties, tour, print_map=T)
