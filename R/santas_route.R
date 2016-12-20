

#install.packages("devtools")
#install.packages("maps")

library(devtools)
library(sp)
library(ggplot2)
#library(TSP)

#library(maps)
#library(animation)
load_all("lib/TSP")

source("lib/utils.R")

# The sp library returns km for distance between coordinates
miles_per_kilometer = 100000 / 2.54 / 12 / 5280
# For land area, which is reported in sq meters. Google confirms 0.000386102
# https://www.census.gov/geo/reference/state-area.html
square_miles_per_1000_square_meters = (miles_per_kilometer / 1000) ^ 2 * 1000 

counties <- read.csv("geography/data/county_centroids.csv",
  colClasses=c(rep("character", 4), rep("numeric", 3))
)

# we also need some household data for each county so we can assess how long it will
# take Mr. Clause at each stop. This is from Census table S1101 (2015 5-yr ACS figures)
# and hand-edited to sanity while we estimate better figures
counties <- combine_coordinates_with_census(counties, "data/households.csv")
counties$index <- seq(1:NROW(counties))

start <- counties$index[counties$name == "Aroostook County"]

# We need the coordinates as a two-column matrix of lng and lat
coords        <- as.matrix(data.frame(long=counties$lng, lat=counties$lat))

# Compute distance matrix
dists <- spDists(coords, longlat = TRUE) * miles_per_kilometer

tours <- list()

# OPTIONAL: This will examine each county pairing as a sanity check to make sure
# Adjacent ones have shorter distances. But this will create a data frame of 
# 3108^2 (9,659,664) rows, so feel free to take my word for it 
# You can see the output in the file median_by_proximity.png
county_labels   <- paste(counties$name, ", ", counties$st, sep="")
county_fips   <- counties[c("name", "st", "fips")]
county_pairs  <- get_county_pairs(dists, county_labels, county_fips)

# TSP Solutions

diag(dists) = Inf
if (any(dists == 0)) {
  warning("Zero entry detected in TSP dist matrix!")
}

#dists[dists > 500] <- Inf

tsp <- TSP(dists, county_labels)

n_of_cities(tsp)
labels(tsp)



tour <- solve_TSP(tsp, method = "nearest_insertion", start=start)

tours <- c(tours, "nearest_insertion_1"=tour)
write.csv(tour, "routes/nearest_insertion_1.csv")

map_route <- function(coords, tour) {
  coordinates <- data.frame(coords)
  opt_tour = as.numeric(tour)
  opt_tour_coords = coordinates[opt_tour, ]
  opt_tour_coords$order <- seq(1:NROW(opt_tour_coords))
  
  opt_tour_coords$alpha <- 0
  #opt_tour_coords$alpha[opt_tour_coords$order < 200] <- 1
  
  pl = ggplot(data = opt_tour_coords, aes_string(x = "long", y = "lat", alpha = 1))
  pl <- pl + geom_point(colour = "tomato", aes(alpha = alpha))
  #pl
  pl + geom_path(data = opt_tour_coords, aes(x= long, y = lat, color=order)) +
      scale_colour_gradientn( colours = c( "darkred", "yellow", "darkgreen"),
                          breaks  = c( 0, NROW(coordinates) / 2, NROW(coordinates)),
                          limits  = c( 0, NROW(coordinates)))
}

map_route(coords, tour)

states <- map_data("state")

plot(coords, axes=TRUE)
plot(USCA312_basemap, add=TRUE, col = "gray")
## plot tour and add cities
tour_line <- SpatialLines(list(Lines(list(
  Line(USCA312_coords[c(tour, tour[1]),])), ID="1")))
plot(tour_line, add=TRUE, col = "red")
points(USCA312_coords, pch=3, cex=0.4, col="black")






#Plot
coords$alpha[coords$sequence < 100] <- 1
coords$alpha[coords$sequence >= 100] <- 0

# draw route and animate cities
#plot_route = function(locations, path) {
  locations <- as.data.frame(coords)
  locations$sequence <- tour
  pl = ggplot(data = locations, aes_string(x = "long", y = "lat", sequence="sequence"))

  # draw optimal tour
  path = as.numeric(tour)
  path_coords = locations[path, ]
  path_coords <- path_coords[order(path_coords$sequence),]
  
  pl = pl + geom_path(data = path_coords, colour = "blue")
  pl = pl + geom_point(colour = "tomato")
  print(pl)
  #return(pl)
#}

#map <- plot_route(coords, tour)
#print(map)
#map + geom_point(aes(alpha = alpha))



#tours <- sapply(methods, FUN = function(m) { print(m); run_solver(tsp.ins, method = m) }, simplify = FALSE)
