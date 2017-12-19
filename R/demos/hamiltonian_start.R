library(TSP)
library("maps")
library("sp")
library("maptools")

data("USCA312")
data("USCA312_map")

atsp <- as.ATSP(USCA312)
ny <- which(labels(USCA312) == "New York, NY")
atsp[, ny] <- 0
initial_tour <- solve_TSP(atsp, method="nn")
tour <- solve_TSP(atsp, method ="two_opt", control = list(tour = initial_tour))
path <- cut_tour(tour, ny, exclude_cut = FALSE)

plot_path(path)


plot_path <- function(path) {
  plot(as(USCA312_coords, "Spatial"), axes = TRUE)
  plot(USCA312_basemap, add = TRUE, col = "gray")
  points(USCA312_coords, pch = 3, cex = 0.4, col = "red")
  
  path_line <- SpatialLines(list(Lines(list(Line(USCA312_coords[path,])), ID="1")))
  plot(path_line, add=TRUE, col = "black")
  points(USCA312_coords[c(head(path,1), tail(path,1)),], pch = 19, col = "black")
}

plot_path(path)
