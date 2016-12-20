# join a Census table to the coordinates data

combine_coordinates_with_census <- function(counties, filepath) {
  census_data <- read.csv(filepath,
    colClasses=c(rep("character", 2), rep("numeric", 5))
  )
  
  # Join these datasets and make sure the merge correctly matches counties
  # (FIPS values can change, like in Oglala Lakota County, SD, so have to be careful)
  data <- merge(counties, census_data, by="fips", all.x=TRUE)
  names_dont_match <- subset(data, paste(data$name, ", ", data$state, sep="") != data$county_name)
  # looks like just one mismatch thanks to a character that the Census miscoded  
  data$name[data$fips == "35013"] <- "Doña Ana County"
  data <- subset(data, select=-county_name)

  return(data);  
}


# condense the distance matrix into a flat table and analyze the 
# relationship between the counties as a function of nearness 

get_county_pairs <- function(county_distances, county_names, county_fips) {
  county_pairs <- as.data.frame(county_distances, county_names)
  colnames(county_pairs) <- county_names
  print("Converting matrix of distances to a data frame.")
  county_pairs <- cbind(stack(county_pairs), county_names)
  colnames(county_pairs) <- c("county_distance", "countyA", "countyB")

  # remove dups
  county_pairs <- subset(county_pairs, county_pairs$countyA != county_pairs$countyB)
  
  # add state columns to the counties
  print("Adding state columns to the county file")
  county_pairs$stateA <- sub("^(.*), ", "", county_pairs$countyA)
  county_pairs$stateB <- sub("^(.*), ", "", county_pairs$countyB)
  
  county_pairs$stateA <- as.character(county_pairs$stateA)
  county_pairs$stateB <- as.character(county_pairs$stateB)
  
  #county_pairs$adjacent     <- NA
  #county_pairs$same_state   <- NA
  
  # we'll upgrade same-state to adjacency where relevant. Downloaded and filled in from here
  # http://www2.census.gov/geo/docs/reference/county_adjacency.txt
  county_adjacency    <- read.csv("data/county_adjacency.csv", colClasses=rep("character", 4))
  county_adjacency$countyA[county_adjacency$fipsA=="35013"] <- "Doña Ana County, NM";
  county_adjacency$countyB[county_adjacency$fipsB=="35013"] <- "Doña Ana County, NM";
  # remove adjacencies with self
  county_adjacency <- subset(county_adjacency, county_adjacency$fipsA != county_adjacency$fipsB)
  county_adjacency$adjacent <- "adjacent"
    
  # Confirmed all names match
  #fips_names <- as.vector(unique(c(county_adjacency$countyA, county_adjacency$countyB)))
  #setdiff(fips_names, county_names)  

  print("Matching adjacencies")
  county_pairs <- merge(county_pairs, county_adjacency, by.x=c("countyA", "countyB"), by.y=c("countyA", "countyB"), all.x=TRUE)
  #county_pairs <- merge(county_pairs, county_adjacency, by.x=c("countyA", "countyB"), by.y=c("countyB", "countyA"), all.x=TRUE)
  #(You're welcome to write `county_pairs` to a CSV, but it will be about 500 MB!)

  county_pairs$same_state <- NA
  county_pairs$same_state[county_pairs$stateA == county_pairs$stateB] <- "same state"

  county_pairs$proximity <- county_pairs$adjacent
  county_pairs$proximity[is.na(county_pairs$adjacent) & !is.na(county_pairs$same_state)] <- "same-state"
  county_pairs$proximity[is.na(county_pairs$adjacent) & is.na(county_pairs$same_state)]  <- "neither"

  values <- c(
    "adjacent" = median(county_pairs$county_distance[county_pairs$proximity=="adjacent"]),
    "same-state" = median(county_pairs$county_distance[county_pairs$proximity=="same-state"]),
    "neither" = median(county_pairs$county_distance[county_pairs$proximity=="neither"])
  )
  
  barplot(values, main="Median Distance By Proximity Type")    
  
  return(county_pairs);
}

# draw counties
plot_coords <- function(coords) {
  locations <- data.frame(coords)
  names(locations) = c("x", "y")
  pl = ggplot(data = locations, aes_string(x = "x", y = "y"))
  pl = pl + geom_point(colour = "tomato", alpha=0.6)
  print(pl)
  #return(pl)    
}

