install.packages("sp")
library("ggplot2")
install.packages("TSP")

library(sp)
library(TSP)

counties <- read.csv("../data/counties.csv", 
  colClasses = c(rep("character", 3), rep("numeric", 5))                     
)

coords.df <- data.frame(long=counties$long, lat=counties$lat)
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)
labels <- counties$name

tsp <- TSP(dist.mx, labels=labels)

# 1145 is the index of Aroostook County, Maine
tour <- solve_TSP(tsp, method = "nn", start = 1145)

# h/t https://uchicagoconsulting.wordpress.com/2011/04/18/how-to-draw-good-looking-maps-in-r/
plot_county_tour <- function(df, tour_order, title) {
  # We need the coordinates for the centroids in a data frame. While we could easily convert
  # `coords`, let's just use the original file from which it was derived. This has the same order 
  # as coords, which by default is just the locations sorted by FIPS value
  coordinates <- df
  
  # The result of `solve_TSP` is a list of integers listing the index of the locations in the 
  # order they are to be visited.
  
  tour_coordinates = coordinates[as.numeric(tour_order), ]
  
  # let's check out our first 10 stops
  # print(tour_coordinates$name[1:10])
  
  # and number the locations in order of their place in the tour
  tour_coordinates$tour_order <- seq(1:NROW(tour_coordinates))
  
  # MAP
  # Start with state borders
  all_counties <- map_data("county") # Thanks for including this, ggplot2
  p <- ggplot()
  if (!missing(title)) {
    p <- p + labs(title = title) + theme(plot.title=element_text(hjust=0.5))
  }
  p <- p + geom_polygon( data=all_counties, aes(x=long, y=lat, group = group), colour="black", fill="white")
  
  # Plot the centroids. Order doesn't matter, so we can use tour_coordinates
  # p <- p + geom_point( data=tour_coordinates, aes(x=long, y=lat), color="red", size=0.2)
  
  # Plot the path in one fell swoop. Let's color it according to its progress from start to end, red to green
  p <- p + geom_path(data = tour_coordinates, aes(x= long, y = lat, color=tour_order), size=1) +
    scale_colour_gradientn( colours = c( "darkblue", "purple", "red"),
                            breaks  = c( 0, NROW(tour_coordinates) / 2, NROW(tour_coordinates)),
                            limits  = c( 0, NROW(tour_coordinates)))
  p <- p + theme(legend.position="none")
  
  print(p)
  return(p)
}