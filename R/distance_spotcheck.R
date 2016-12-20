# Our purpose here is just to test the coordinate distance functions in the "sp"
# Library to make sure we're getting sensible results, since that's the crux of this
# whole enterprise

# with grateful thanks to this demo:
# https://operatiology.wordpress.com/2014/05/31/tsp-with-latitudelongitude-coordinate-input-in-r/
# Note that we're using TSP, the primary R library for travelling salesman problems,
# as opposed to tspmeta, as seen in the link above, which is largely a wrapper around TSP 

library(sp)
library(TSP)

miles_per_kilometer = 100000 / 2.54 / 12 / 5280

# TSP comes packaged with a variety of geographic datasets. We'll use the one with
# 312 US and Canadian cities and reduce it to 235 like in the example linked above
data("USCA312_map")
cities <- subset(USCA312_coords, lat < 44 & lat > 25)
coords <- as.matrix(data.frame(long=cities$long, lat=cities$lat))
names <- as.character(cities$name)

# spDistsN1 compares one location to a list of locations, so we'll start with Abilene, TX
# which happens to be the first one in the list. According to the sp docs, setting longlat 
# to TRUE calculates "Great Circle (WGS84 ellipsoid) distance," which we need since we're
# calculating the distance between points in longitude and latitude, not two-dimensional space
distances_abilene <- spDistsN1(coords, coords[1,], longlat=TRUE)

spotcheck <- data.frame(
  cityA = rep(names[1], length(names)), # for now, Abilene is always the first location
  cityB = names,
  distance = distances_abilene * miles_per_kilometer,
  stringsAsFactors=FALSE
)

# Here are the top-10 closest cities to Abilene (including itself). Looks like a lot of Texas!
print(spotcheck[order(spotcheck$distance),][1:10,])

# I've never been to Abilene (though I'm sure it's lovely), so let's check a few against
# this implementation of the Google Map API's geodesic ("as the crow flies") service

# Baltimore to Abilene: 1375.467 (us) vs. 1374.96 (Google)
# https://www.mapdevelopers.com/distance_from_to.php?&from=Abilene%2C%20TX&to=Baltimore%2C%20MD
print(paste(spotcheck[15,]))

# Evansville, IN to Abilene: 785.94 (us) vs. 785.41 (Google)
# https://www.mapdevelopers.com/distance_from_to.php?&from=Abilene%2C%20TX&to=Baltimore%2C%20MD
print(paste(spotcheck[70,]))

# Dallas to Abilene: 172.416 (us) vs. 172.57 (Google)
# https://www.mapdevelopers.com/distance_from_to.php?&from=Abilene%2C%20TX&to=Baltimore%2C%20MD
print(paste(spotcheck[55,]))

# I'm satisified. Tiny differences can result either because we have slightly different
# centroid points or because different coordinate-to-coordinate algorithms use marginally
# different values for the earth's slightly uneven radius

# Now I just want to match the complete distance matrix to the locations
# This will produce a 235 x 235 matrix
distances <- as.data.frame(spDists(coords, longlat=TRUE))
colnames(distances) <- names

# Flatten that matrix into a list of city pairs
pairs <- cbind(stack(distances), names)
colnames(pairs) <- c("distance", "cityA", "cityB")
pairs <- subset(pairs, pairs$cityA != pairs$cityB) # remove duplicates. 
# At game time, we'll set these 0 values--the matrix's diagonal--to infinity
# so as not to confuse the TSP algorithms
pairs$distance <- pairs$distance * miles_per_kilometer
pairs <- pairs[order(pairs$distance),]

# I checked a dozen of these and they look good. Let's get serious. The real
# Christmas miracle happens in santa_tsp.R

