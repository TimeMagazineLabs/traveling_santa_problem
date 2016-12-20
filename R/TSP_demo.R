# There's a wonderful wrapper for TSP called tspmeta, with some extra features
# We're just using TSP directly to better understand the mechanics behind its algorithms

library("sp")
library("maps")
library("maptools")
library("TSP")


# COORDINATES 

# Let's use continental U.S. states and DC as our coordinates. We generated these ourselves
# as described in the main README

states <- read.csv("../geography/data/state_centroids.csv",
  colClasses=c(rep("character", 3), rep("numeric", 3))
)

# we'll give each one an explicit index since this is how tours are expressed
states$index <- seq(1:NROW(states))
labels <- states$name

# We need the coordinates as a two-column matrix of lng and lat
coords <- as.matrix(data.frame(long=states$lng, lat=states$lat))


# DISTANCES BETWEEN STATES

miles_per_kilometer = 100000 / 2.54 / 12 / 5280

# Compute distance matrix. More on this in distance_spotcheck.R
dists <- spDists(coords, longlat = TRUE) * miles_per_kilometer

# dists is a 49 x 49 matrix--one row and column for each place--so the diagonals are zero since
# they represent the distance from, say, AL to AL. Setting to infinity helps TSP ignore them
diag(dists) = Inf
if (any(dists == 0)) {
  warning("Zero entry detected in TSP dist matrix!")
}

#dists[dists > 500] <- Inf

# THE SALESMAN TRAVELS

# initialize the TSP object. The library also has classes for Euclidean and assymetic varieties
tsp <- TSP(dists, labels)

# TSP has a few methods for checking the specs, though we don't really need them
n_of_cities(tsp)
labels(tsp)



tour <- solve_TSP(tsp, method = "nearest_insertion", start=start)



## calculate a tour
tour <- solve_TSP(USCA312, "nn")
tour
## load map tools

## plot map
plot(USCA312_coords, axes=TRUE)
plot(USCA312_basemap, add=TRUE, col = "gray")
## plot tour and add cities
tour_line <- SpatialLines(list(Lines(list(
  Line(USCA312_coords[c(tour, tour[1]),])), ID="1")))
plot(tour_line, add=TRUE, col = "red")
points(USCA312_coords, pch=3, cex=0.4, col="black")