#install.packages("sp")
#install.packages("TSP")

library(sp)
library(TSP)

source("lib/map_route.R")

counties <- read.csv("../data/counties.csv", 
  colClasses = c(rep("character", 3), rep("numeric", 5))                     
)

coords.df <- data.frame(long=counties$long, lat=counties$lat)
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)
labels <- counties$name
attr(dist.mx, "Labels") <- labels

# 1145 is the index of Aroostook County, Maine
START_INDEX = as.integer(1145)

tsp <- TSP(as.dist(dist.mx))

tsp_methods <- c(
  "nn",
  "nearest_insertion",
  "farthest_insertion",
  "cheapest_insertion"
)

# number of times to try each method
NUM_TRIALS = 1

distances <- as.data.frame(list(id="default", distance=Inf), stringsAsFactors = F)
tours = list()

for (method in tsp_methods) {
  for (i in 1:NUM_TRIALS) {
    id = paste(method, i, sep="_");
    print(id);
    tour <- solve_TSP(tsp, method = method, start = START_INDEX)
    performance <- list(id=id, distance=tour_length(tour))
    distances <- rbind(distances, performance)
    tours[[id]] = as.numeric(tour)
  }
}

plot_county_tour(counties, tours[["nn_1"]], "nn_1", print_map=T)
plot_county_tour(counties, tours[["nearest_insertion_1"]], "nearest_insertion_1", print_map=T)
plot_county_tour(counties, tours[["farthest_insertion_1"]], "farthest_insertion_1", print_map=T)
plot_county_tour(counties, tours[["cheapest_insertion_1"]], "cheapest_insertion_1", print_map=T)
plot_county_tour(counties, tours[["arbitrary_insertion_1"]], "arbitrary_insertion_1", print_map=T)
