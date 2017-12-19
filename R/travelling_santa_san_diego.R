# https://cran.r-project.org/web/packages/TSP/vignettes/TSP.pdf

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
tsp <- TSP(dist.mx, labels = labels)

m <- as.matrix(tsp)
start <- which(labels == "Aroostook County, ME")
end   <- which(labels == "San Diego County, CA")
atsp <- ATSP(m[-c(start,end), -c(start,end)])
atsp <- insert_dummy(atsp, label = "end_start")
end_start <- which(labels(atsp) == "end_start")
atsp[end_start, ] <- c(m[-c(start,end), start], 0)
atsp[, end_start] <- c(m[end, -c(start,end)], 0)

#TSP Time!

tsp_methods <- c(
  "nn",
  "nearest_insertion",
  "farthest_insertion",
  "cheapest_insertion"
)

distances <- as.data.frame(list(id="default", distance=Inf), stringsAsFactors = F)
tours = list()

for (method in tsp_methods) {
  id = method;
  print(id);
  tour <- solve_TSP(atsp, method = method)
  performance <- list(id=id, distance=tour_length(tour))
  distances <- rbind(distances, performance)
  path_labels <- c("Aroostook County, ME", labels(cut_tour(tour, end_start)), "San Diego County, CA")
  path_ids <- match(path_labels, labels(tsp))
  tours[[id]] = path_ids
}

plot_county_tour(counties, tours[["nn"]], "nn", print_map=T)
plot_county_tour(counties, tours[["nearest_insertion"]], "nearest_insertion", print_map=T)
plot_county_tour(counties, tours[["farthest_insertion"]], "farthest_insertion", print_map=T)
plot_county_tour(counties, tours[["cheapest_insertion"]], "cheapest_insertion", print_map=T)

# Looks like "farthest insertion" is the best method. Let's run it a few times. Go get coffee.

distances <- as.data.frame(list(id="default", distance=Inf), stringsAsFactors = F)
tours = list()

for (i in 1:2) {
  id = paste("farthest_insertion", i, sep="_");
  print(id);
  tour <- solve_TSP(atsp, method = "farthest_insertion", two_opt=TRUE, rep=3)
  performance <- list(id=id, distance=tour_length(tour))
  distances <- rbind(distances, performance)
  path_labels <- c("Aroostook County, ME", labels(cut_tour(tour, end_start)), "San Diego County, CA")
  path_ids <- match(path_labels, labels(tsp))
  tours[[id]] = path_ids
}

shortest <- distances[which.min(distances$distance),"id"]

map = plot_county_tour(counties, tours["farthest_insertion_2"], print_map=T)
route <- get_county_route(counties, tours["farthest_insertion_2"])

write.csv(route[,c()], "routes/data/fi2.csv", row.names = F)
jpeg('routes/maps/fi2.jpg')
print(map)
dev.off()
