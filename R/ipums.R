# The microdata from IPUMS--drawn here from the 1-year American Community Survey--allows
# us to drill down into which types of houses the Santa-eligible crowd is most likely to
# live in. While IPUMS does not report counties for all respondents, and because a one-year
# survey is not sufficient for all counties even if they dide, our goal is just to get a 
# sense for the national dynamics, which we can use to inform our county-by-county estimate.

# The file is too large for the repo, so go to the root `sources` directory and download it:
# wget http://time-static-shared.s3-website-us-east-1.amazonaws.com/interactives/travelling_santa_problem/files/ipums_ACS_2015.sav.gz
# gzip -d ipums_ACS_2015.sav.gz

# Need "foreign" since we're importing IPUMS data from an SPSS format
library('foreign') 
source("lib/utils.R")

# Lets first load a Census table we can use to spot-check our top-line calculations.
# We'll use table S1101, "HOUSEHOLDS AND FAMILIES," from the same ACS 2015 1-yr sample
# It's include in the repo's "sources" directory. First we choose the fields we want
housing_fields <- data.frame(
  code=character(), key=character(), stringsAsFactors=FALSE
)

housing_fields[1,] <- list(code="HC01_EST_VC02", key="state_households")
housing_fields[2,] <- list(code="HC01_EST_VC17", key="state_households_under_18")
housing_fields[3,] <- list(code="HC01_EST_VC27", key="state_households_one_unit")
housing_fields[4,] <- list(code="HC01_EST_VC28", key="state_households_two_plus_units")
housing_fields[5,] <- list(code="HC01_EST_VC29", key="state_households_mobile")

census <- load_census("../sources/ACS_15_1YR_S1101/ACS_15_1YR_S1101_with_ann.csv", housing_fields)

# IPUMS
ipums <- read.spss('../sources/ipums_ACS_2015.sav', to.data.frame=TRUE)

# convert factors
ipums$YEAR     <- as.numeric(as.character(ipums$YEAR))
columns        <- colnames(ipums)
types          <- lapply(ipums, class)

for (i in 1:length(columns)) {
  column = columns[i]
  if (types[i] == "factor") {
    ipums[[column]] <- as.character(ipums[[column]])
  }
}

ipums$AGE_N <- ipums$YEAR - ipums$BIRTHYR

# IPUMS docs say these three vars uniquely ID a household:
# https://usa.ipums.org/usa-action/variables/SERIAL#description_section
ipums$HH_ID <- paste(ipums$YEAR, ipums$DATANUM, ipums$SERIAL, sep='_')

# We'll keep `ipums` unmodified in case we make a mistake and don't want to wait again
population <- ipums

# Let's do some immediate spot-checking. The total population perfectly matches Census
print(paste("Total population is", prettyNum(sum(population$PERWT), big.mark=","))) 

table(population$GQTYPE)

# reduce the population to those with the expected group quarter status
household_population <- subset(population, population$GQTYPE == "NA (non-group quarters households)")
print(paste("Total population in households is", prettyNum(sum(household_population$PERWT), big.mark=","))) 


households <- population[!duplicated(population$HH_ID),]
households <- subset(households, households$GQ == "Households under 1970 definition")
print(paste("Total households", prettyNum(sum(households$HHWT), big.mark=",")))

states <- unique(households$STATEFIP)

children <- subset(population, population$AGE_N < 18)
households_with_children  <- children[!duplicated(children$HH_ID), ] 
print(paste("Under 18 population:", prettyNum(sum(children$PERWT), big.mark=",")))
# Census table B09001 (ACS 2015 1yr) sats 73,683,825 total, 73,468,986 in households

# We're just looking at the continental US
children <- subset(children, children$STATEFIP!="Alaska" & children$STATEFIP!="Hawaii")

print(paste("Households with those under 18:", sum(households_with_children$HHWT), "vs.", census[1,]$state_households * census[1,]$state_households_under_18 / 100))

households_with_children  <- children[!duplicated(children$HH_ID), ] 

# 92 percent celebrate Christmas: http://www.pewresearch.org/fact-tank/2015/12/21/5-facts-about-christmas-in-america/
# Let's randomly remove 8 percent of the records
children$i_celebrate <- (sample(1:100, NROW(children), replace=T) <= 92)
table(children$i_celebrate) / NROW(children)

santas_children <- subset(children, children$i_celebrate == T)
print(paste(NROW(children) * 0.92, NROW(santas_children)))

total_under_18 <- sum(santas_children$PERWT)

print(paste("Total_present_recipients:", prettyNum(total_under_18, big.mark=",")))

#reduce to HHID
santa_households <- santas_children[!duplicated(santas_children$HH_ID),] 
total_santa_households  <- sum(santa_households$PERWT)

#run these if you want to double check , should return 'character(0)'
unique_test <- unique(santas_children$HH_ID)
setdiff(unique_test, unique_households$HH_ID)

states <- unique(santas_children$STATEFIP)

by_state <- data.frame(state_name=character(),state_total = numeric(),state_santa_households = numeric(),state_households = numeric(),state_santa_pct = numeric(),stringsAsFactors = FALSE)

santas_children_households  <- santas_children[!duplicated(santas_children$HH_ID),] 

national_everyone   <- data
national_everyone_household_total <- sum(national_everyone[!duplicated(national_everyone$HH_ID),]$HHWT)
national_households_with_celebrating_children <- 100 * sum(national_children_households$HHWT) / national_everyone_household_total

for (state in states) {
  state_children   <- subset(children, children$STATEFIP==state)
  state_children_households <- state_children[!duplicated(state_children$HH_ID),] 
  
  state_everyone   <- subset(data, data$STATEFIP==state)
  state_everyone_household_total <- sum(state_everyone[!duplicated(state_everyone$HH_ID),]$HHWT)
  state_households_with_celebrating_children <- 100 * sum(state_children_households$HHWT) / state_everyone_household_total
  
  by_state[NROW(by_state)+1,] <- list(
    state_name = state,
    state_total = sum(state_children[["PERWT"]]),
    state_santa_households = sum(state_children_households[["HHWT"]]),
    state_households = state_everyone_household_total,
    state_santa_pct = state_households_with_celebrating_children
  ) 
}

write.csv(by_state, file = "../data/state_households.csv", row.names=FALSE)


# As long as we're here, let's write the state figures

housing_fields <- data.frame(
  code=character(), key=character(), stringsAsFactors=FALSE
)

housing_fields[1,] <- list(code="HC01_EST_VC02", key="county_total")
housing_fields[2,] <- list(code="HC01_EST_VC17", key="county_under_18")
housing_fields[3,] <- list(code="HC01_EST_VC27", key="county_one_unit")
housing_fields[4,] <- list(code="HC01_EST_VC28", key="county_two_plus_units")
housing_fields[5,] <- list(code="HC01_EST_VC29", key="county_mobile")

counties <- load_census("../sources/ACS_15_5YR_S1101/ACS_15_5YR_S1101_with_ann.csv", housing_fields)

counties$name[counties$fip=="35013"] <- "Dona Ana County, New Mexico";

counties$state_fips <- substr(counties$fips, 0, 2)
counties$county_fips <- counties$fips

counties <- subset(counties, counties$state_fips != "02" & counties$state_fips != "15")

sum(counties$county_total)
sum(by_state$state_households)

counties$state_name <- " "
counties$county_name <- " "

for (i in 1:NROW(counties)) {
  s <- strsplit(counties[i,]$name, ", ")
  
  counties[i,]$county_name <- s[[1]][[1]]
  counties[i,]$state_name <- s[[1]][[2]]
}


counties <- counties[, c("state_fips", "county_fips", "state_name", "county_name", "county_total", "county_under_18", "county_one_unit", "county_two_plus_units", "county_mobile")]

counties <- merge(counties, by_state[,c("state_name", "state_santa_pct")], by="state_name", all.x=TRUE)

counties$county_santa_households <- round(counties$county_total * counties$state_santa_pct / 100)

sum(counties$county_santa_households)
sum(by_state$state_santa_households)

write.csv(by_state, file = "../data/county_households.csv", row.names=FALSE)