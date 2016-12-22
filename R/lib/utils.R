# load specific fields from a CSV from American Factfinder
load_census <- function(filepath, fields) {
  census <- read.csv(filepath, header=TRUE, stringsAsFactors=FALSE)
  census <- census[2:NROW(census),]

  columns <- c(c("GEO.id2", "GEO.display.label"), fields$code)
  headers <- c(c("fips", "name"), fields$key)
  census  <- census[,columns]
  colnames(census) <- headers
  census[,3:length(headers)] <- lapply(census[,3:length(headers)], as.numeric)
  
  return(census)
}


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