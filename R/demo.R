library(sp)
library(TSP)

source("lib/map_route.R")

#we have to dictate the content types or R will think FIPS codes are numeric
counties <- read.csv("../data/counties.csv", 
  colClasses = c(rep("character", 2), rep("numeric", 5))                     
)

coords.df <- data.frame(long=counties$long, lat=counties$lat)
#TSP prefers a matrix
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)
labels <- counties$name

#initialize the tsp object. This does not compute the route, it just loads the data needed to do so
tsp <- TSP(dist.mx, labels=labels)

start_index = which(labels == "Aroostook, ME")

tour <- solve_TSP(tsp, method = "nn", start = start_index)

plot_county_tour(counties, tour, print_map=T)
