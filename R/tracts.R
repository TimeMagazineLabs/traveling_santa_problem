# Okay, let's figure out how to prioritize the counties so that Santa prioritizes them.
# Even with a fast sleigh, he will be most efficient in a place with high population density.
# So we're using Census tracts, which are subdivisions of counties, to estimate how much of 
# population is in close proximity. The mechanics for gathering the data are described in the
# README.

# We're going to map the weights we generate out of curiosity.

library(choroplethr)
library(choroplethrMaps)

tracts_demographics <- read.csv("../data/tracts_demographics.csv",
  colClasses=c(rep("character", 3), rep("numeric", 10) )
)

tracts_geography <- read.csv("../data/tracts_geography.csv",
  colClasses=c(rep("character", 6), rep("numeric", 8) )
)

tracts <- merge(tracts_geography, tracts_demographics, by=c("tract_fips", "county_fips", "state_fips"))

# Oglala County changed its fits
tracts$county_fips[tracts$county_fips=="46113"] <- "46102";
# And Bedford City cut bait
tracts <- subset(tracts, tracts$county_fips != "51515" & tracts$tract_population > 0);

# Let's the population density for each tract
# Average land area for the continental U.S. is 3,119,884.69 sq ml
# https://en.wikipedia.org/wiki/Contiguous_United_States

total_sq_mi <- sum(tracts$tract_area_sq_mi)
print(total_sq_mi) #close!

total_population_density <- sum(tracts$tract_population) / total_sq_mi
total_household_density <- sum(tracts$tract_households) / total_sq_mi
total_child_household_density <- sum(tracts$tract_households_under_18) / total_sq_mi

sum(tracts$tract_households_under_18)

tracts$tract_population_density <- tracts$tract_population / tracts$tract_area_sq_mi 
tracts$tract_household_density <- tracts$tract_households / tracts$tract_area_sq_mi 
tracts$total_child_household_density <- tracts$tract_households_under_18 / tracts$tract_area_sq_mi 

counties_by_tract <- aggregate(tracts[,c(7:27)], by=list(tracts$county_fips), FUN=sum)

tracts_with_children <- subset(tracts, tracts$tract_households_under_18 > 0)

cols <- colnames(counties_by_tract)
cols[1] <- "county_fips"
colnames(counties_by_tract) <- cols

sum(tracts$tract_households_under_18)

for (c in 1:NROW(counties_by_tract)) {
  county <- counties_by_tract[c,]
  county_id <- county$county_fips
  print(county_id)
  group <- subset(tracts, tracts$county_fips == county_id)
  county_area <- sum(group$tract_area_sq_mi)
  for (i in 1:NROW(group)) {
    tract <- group[i,]
    tract$household_share <- tract$tract_households_under_18 / sum(group$tract_households_under_18)
    tract$land_share <- tract$tract_area_sq_mi / sum(group$tract_area_sq_mi)
    county$child_density <- sum(group$total_child_household_density * group$tract_household_share)    
  }
}  

backup <- counties_by_tract

counties <- counties_by_tract[,c("county_fips", "tract_land_sq_mi", "tract_water_sq_mi", "tract_area_sq_mi", "tract_population", "tract_population_under_18", "tract_households", "tract_households_under_18", "tract_population_density", "tract_household_density", "total_child_household_density")]

county_households <- read.csv("../data/county_households.csv",
  colClasses=c(rep("character", 1), rep("numeric", 4) )
)

county_geography <- read.csv("../data/county_geography.csv",
  colClasses=c(rep("character", 5), rep("numeric", 8))
)

counties_plus <- merge(counties, county_geography[,c("state_fips", "state_abbr", "state_name", "county_fips", "county_name", "county_lat", "county_lng")], by=c("county_fips"))

counties_plus <- counties_plus[, c( "county_fips", "state_fips", "state_abbr", "state_name", "county_name", "tract_land_sq_mi", "tract_water_sq_mi", "tract_area_sq_mi", "tract_population", "tract_population_under_18", "tract_households", "tract_households_under_18", "tract_population_density", "tract_household_density", "total_child_household_density", "county_lat", "county_lng" )]

counties_plus <- merge(counties_plus, county_households, by="state_name")

counties_plus$santa_stops <- counties_plus$tract_households_under_18 * counties_plus$state_santa_pct / 100

sum(counties_plus$tract_households_under_18)




county_data <- merge(counties_by_tract, counties, by="fips")
colnames(county_data) <- c("fips", "tract_total_population", "tract_total_population_16", "tract_total_households", "tract_total_area", "tract_total_sq_mi", "state_total", "state_child_households", "state_total_households", "state_pct_houses", "total_santa_stops", "name", "st", "state", "long", "lat", "county_area")
county_data <- county_data[, c("fips", "st", "name", "total_santa_stops", "tract_total_population", "tract_total_population_16", "tract_total_households", "tract_total_area", "tract_total_sq_mi", "county_area")]

tracts_plus <- merge(x=tracts, y=county_data, by=c("fips"), all.x=T)

tracts_plus$santa_stop_pct <- tracts_plus$santa_stops / tracts_plus$total_santa_stops
#tracts_plus$tract_avg_sq_ml <- tracts_plus$tract_total_sq_mi / tracts_plus$count
tracts_plus$area_time <- tracts_plus$santa_stop_pct * tracts_plus$tract_sq_ml
tracts_plus$count <- 1

by_county <- aggregate(tracts_plus[,c(6:10,15,25:27)], by=list(tracts$fips), FUN=sum)
cols <- colnames(by_county);
cols = c("fips", "population", "population_16", "households", "area", "sq_ml", "santa_stops", "santa_stop_pct", "area_time", "count")
colnames(by_county) <- cols;
by_county$avg_area_time <- by_county$sq_ml /  by_county$count
by_county$county_score <- by_county$area_time / by_county$avg_area_time
by_county$check <- by_county$area / by_county$count

named_by_county <- merge(by_county, counties, by="fips")



#csv <- by_county[,c("fips","population","population_16","households","sq_miles","santa_stops","santas_time","weight","county_score")]

write.csv(by_county, "../data/weights.csv", row.names=F)

# look at the relationship

plot(by_county$population, by_county$county_score)

# MAP the weight
library(choroplethr)
library(choroplethrMaps)

data(df_pop_county)

by_county$region <- as.numeric(as.character(by_county$fips))

merged <- merge(df_pop_county, by_county[,c("region", "county_score")], by="region")
merged$value <- merged$county_score
county_choropleth(merged)

