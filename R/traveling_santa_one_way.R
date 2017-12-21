# https://cran.r-project.org/web/packages/TSP/vignettes/TSP.pdf

#install.packages("sp")
#install.packages("TSP")

library(sp)
library(TSP)

source("lib/map_route.R")

counties <- read.csv("../data/counties.csv", 
  colClasses = c(rep("character", 2), rep("numeric", 5))                     
)

coords.df <- data.frame(long=counties$long, lat=counties$lat)
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)
labels <- counties$name
tsp <- TSP(dist.mx, labels = labels)

#TSP Time!

tsp_methods <- c(
  "nn",
  "nearest_insertion",
  "farthest_insertion",
  "cheapest_insertion"
)

distances <- as.data.frame(list(id="default", distance=Inf), stringsAsFactors = F)

for (method in tsp_methods) {
  id = method;
  print(id);
  tour <- solve_TSP(tsp, method = method)
  performance <- list(id=id, distance=tour_length(tour))
  distances <- rbind(distances, performance)
}

# Looks like "farthest insertion" is the best method. Let's run it a few times.
# We need to make this a one-way route. See page 14 in the following paper:
# https://cran.r-project.org/web/packages/TSP/vignettes/TSP.pdf
# Go get coffee. This will take awhile. Make it a Venti

m <- as.matrix(tsp)
start <- which(labels == "Aroostook, ME")
end   <- which(labels == "San Diego, CA")
atsp <- ATSP(m[-c(start,end), -c(start,end)])
atsp <- insert_dummy(atsp, label = "end_start")
end_start <- which(labels(atsp) == "end_start")
atsp[end_start, ] <- c(m[-c(start,end), start], 0)
atsp[, end_start] <- c(m[end, -c(start,end)], 0)

distances <- as.data.frame(list(id="default", distance=Inf), stringsAsFactors = F)
tours = list()

# we ran this hundreds of times in a cluster, but keeping to three here
# so as not to frag your processor

for (i in 1:3) {
  id = paste("farthest_insertion", i, sep="_");
  print(id);
  tour <- solve_TSP(atsp, method = "farthest_insertion", two_opt=TRUE, rep=3)
  performance <- list(id=id, distance=tour_length(tour))
  distances <- rbind(distances, performance)
  path_labels <- c("Aroostook, ME", labels(cut_tour(tour, end_start)), "San Diego, CA")
  path_ids <- match(path_labels, labels)
  tours[[id]] = path_ids
}

#map and save all three routes
for (i in 1:3) {
  id = paste("farthest_insertion", i, sep="_");
  map = plot_county_tour(counties, tours[id], id, print_map=T)
  route <- get_county_route(counties, tours[id])
  write.csv(route, paste("routes/data/", id, ".csv", sep=""), row.names = F)
  jpeg(paste('routes/maps/', id, '.jpg', sep=""))
  print(map)
  dev.off()
}

shortest <- distances[which.min(distances$distance),"id"]

map = plot_county_tour(counties, tours[shortest], print_map=T)
route <- get_county_route(counties, tours[shortest])

write.csv(route, paste("routes/data/optimal.csv", sep=""), row.names = F)
jpeg(paste('routes/maps/optimal.jpg', sep=""))
print(map)
dev.off()