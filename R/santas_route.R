library(devtools)
library(sp)
library(ggplot2)
#library(TSP)
library(maps)

load_all("lib/TSP") 

source("lib/utils.R")

# The sp library returns km for distance between coordinates
miles_per_kilometer = 100000 / 2.54 / 12 / 5280
# For land area, which is reported in sq meters. Google confirms 0.000386102
# https://www.census.gov/geo/reference/state-area.html
square_miles_per_square_meters = (miles_per_kilometer / 1000) ^ 2 * 1000 

counties <- read.csv("../geography/data/county_coordinates.csv",
  colClasses=c(rep("character", 4), rep("numeric", 3))
)

# we also need some household data for each county so we can assess how long it will
# take Mr. Clause at each stop. This is from Census table S1101 (2015 5-yr ACS figures)
# and hand-edited to sanity while we estimate better figures
counties <- combine_coordinates_with_census(counties, "../data/households.csv")
counties$index <- seq(1:NROW(counties))

start <- counties$index[counties$name == "Aroostook County"]

# We need the coordinates as a two-column matrix of lng and lat
coords        <- as.matrix(data.frame(long=counties$long, lat=counties$lat))

# Compute distance matrix
dists <- spDists(coords, longlat = TRUE) * miles_per_kilometer

diag(dists) = Inf
if (any(dists == 0)) {
  warning("Zero entry detected in TSP dist matrix!")
}

county_labels <- counties$name

# simple interface to the core TSP function, `solve_TSP`, which returns a "tour"--the 
# proposed route through the counties, which we'll also call routes--according to
# the heuristic method that you specify. 
# `id`` is just the number that gets appended to the filename. It then both writes the 
# route to a CSV file and maps it, saving that map as a JPG before returning the tour

solve_route <- function(method, id, start) {
  slug <- paste(method, "_", id, sep="")
  if (!missing(start)) {
    tour <- solve_TSP(tsp, method = method, start=start)
  } else {
    tour <- solve_TSP(tsp, method = method)
  }
  p <- plot_county_tour(counties, tour, slug)
  
  write.csv(tour, paste("route_data/", slug, ".csv", sep=""), row.names=FALSE)
  ggsave(filename=paste("route_maps/", slug, ".jpg", sep=""), device="jpg", width=4, height=3, unit="in")
  
  return(tour)
}

# this is the important part: How do we measure the effectiveness of a route given that
# not all counties that the same out of time to cover? Because we've already attached
# Census info to the main counties data frame, we can use that.

score_route <- function(tour) {
  county_route <- county_route[as.numeric(tour), ]
}

# we're going to emphasize some of these more than others,
# but let's at least try them all a few times
tsp_methods <- c(
  "nearest_insertion",
  "farthest_insertion",
  "cheapest_insertion",
  "arbitrary_insertion",
  "nn",
  "repetitive_nn",
  "two_opt"
)

# the main TSP object
tsp <- TSP(dists, county_labels)

# two data frames to store our computed tours
# each has a slug like "nearest_insertion-3", the method and a sequential number
# --track the actual tour itself as a 3,108-length column with the slug as the column name
routes.tours  <- data.frame()      
# --track stats on each tour we calculate, like the distance and time
routes.roster <- data.frame(SLUG=character(), TOTAL_DISTANCE=numeric(), AVG_DISTANCE=numeric(), TOTAL_TIME()=numeric(), AVG_TIME=numeric(), stringsAsFactors = F)

# load a csv file of coordinates and convert them to TSP flavor TOUR
load_tour <- function(filename, method, tsp) {
  points <- read.csv(paste("route_data/", filename, ".csv", sep=""))
  points <- as.vector(points$x)
    
  
  
  
  
  tour <- TOUR(points, method=method, tsp=tsp)
}

ex <- c("nn-1", "farthest_insertion-1", "farthest_insertion-2", "cheapest_insertion-1", "nearest_insertion-1", "nearest_insertion-2", "nearest_insertion-3")

#routes.roster[7,] <- list("slug"="nearest_insertion_3", "distance"=NA) 
#routes.roster <- routes.roster[order("slug"),]

tours   <- list()
labels  <- c()

for (i in 2:2) {
  for (c in 1:1) {
    slug <- paste(methods_to_try[c], "_", i, sep="")
    t <- solve_route(methods_to_try[c], i, start)
    
    routes.tours[[slug]] <- t
  }
}



plot_county_tour(counties, tour, slug)
tour <- load_tour("cheapest_insertion_1", methods_to_try[3])

