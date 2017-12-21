library(sp)

counties <- read.csv("../data/counties.csv",
  colClasses = c(rep("character", 2), rep("numeric", 5))                     
)

route <- read.csv("routes/data/optimal.csv", 
  colClasses = c(rep("character", 2), rep("numeric", 5))                     
)

miles_per_kilometer = 0.621371;
square_miles_per_square_meters = 1 / 2589988.11;

route$area <- route$area * square_miles_per_square_meters

coords.df <- data.frame(long=counties$long, lat=counties$lat)
coords.mx <- as.matrix(coords.df)
dist.mx <- spDists(coords.mx, longlat=TRUE)

distances = list(c(0))

# calculate distances in each route
for (i in 2:NROW(route)) {
  A = which(counties$fips==route[i-1, "fips"])
  B = which(counties$fips==route[i, "fips"])
  d = dist.mx[A, B]
  distances = rbind(distances, d)
}

distances <- as.numeric(distances)

route["distance"] <- distances

# sp docs specify that spDist spits out kms when lat/lng is used
route["distance"] <- route["distance"] * miles_per_kilometer

#FACT-CHECKING

print(prettyNum(sum(distances), big.mark=","))
#142,651, which matches the output from the previous script

print(prettyNum(sum(route$area), big.mark=","))
#2,955,009 looks right. Wikipedia says 3,119,885, but we're not counting water

print(paste("total children", prettyNum(sum(route$children / 0.9), big.mark=",")))
# The Census reports 40,138,328, but they're counting AK, HI and PR

# We're ready to port over to the JavaScript viz!
write.csv(route[,c("fips", "name", "long", "lat", "tz", "area", "children", "distance")], "../data/optimal_route.csv", row.names = F)
