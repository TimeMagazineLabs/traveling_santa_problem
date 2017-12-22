# Setting Up Shop

## Getting the coordinates and area for counties

To regenerate the geography data that lives in the `data` directory, you just need a few Node dependencies. And [Node](https://nodejs.org/en/) itself, of course.

	npm install 			# D3 and a few other libraries we need to compute centroids
	npm install -g mapshaper 	# neatly converts SHP files to GeoJSON or TopoJSON formats from the command line

You'll also need `wget`, which you may already have. If not, Homebrew to the rescue:
	
	brew install wget

The county map comes from the Census Bureau's [Cartographic Boundary Shapefiles](https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html), which we didn't add to the repository to avoid extra baggage. To follow our steps, use the following commands to download the most up-to-date county SHP file.

	cd sources
	wget https://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_county_20m.zip
	unzip "cb_2016*" -d counties

This will unzip a bunch of files into the `counties` subdirectory since [Esri's Shapefile](https://en.wikipedia.org/wiki/Shapefile) format is divided into several parts. If you want to view what the raw maps look like, [QGIS](http://www.qgis.org/en/site/forusers/download.html) is a free program that can open and display the `.shp` file. But you don't have to, because we're only using code that is executable from the command line. This ensures that the process can be fully documented and adheres to the spirit of [Bostock's Law](https://bost.ocks.org/mike/make/). It's files all the way down.

First, we're going to use `mapshaper` to modify these Shapefiles to exclude Alaska, Hawaii and U.S. territories--not because we believe their children to be poorly behaved, but because the Traveling Salesman Problem is most relevant here to the contiguous 48 states and Washington, D.C. (While we could just ignore these regions, striking them from the map makes it display better.) Fortunately, `mapshaper` accepts a JavaScript string as an argument, which we can use to filter the locations down to those with a [state FIPS code](https://www.census.gov/geo/reference/ansi_statetables.html) between "01" and "56", which run from Alabama to Wyoming and include D.C. but no other non-states. We just have to skip "02" (Alaska) and "15" (Hawaii). We're also going to filter the fields down to the FIPS id and each county's land area.

	mapshaper counties/cb_2016_us_county_20m.shp -filter 'parseInt(STATEFP) <= 56 && STATEFP != "02" && STATEFP != "15"' -filter-fields GEOID,ALAND -o format=shapefile counties/counties.shp
	# Output should say "[filter] Retained 3,108 of 3,220 features"

While we're at it, let's generate the topoJSON file of the counties for the visualization:

	mapshaper counties/cb_2016_us_county_20m.shp name=counties -filter 'parseInt(STATEFP) <= 56 && STATEFP != "02" && STATEFP != "15"' -filter-fields GEOID -o format=topojson ../data/counties.topo.json

## Centroids and Population

The next step is to convert the SHP files we just made into JSON and CSV documents that contain each county's geographic coordinates, land area data, the geographic center of each location, and the number of children. The `mapshaper` tool conveniently includes the metadata from the original Shapefile for each state.

	mapshaper counties/counties.shp -o format=geojson ../data/counties.geo.json

### County Data

The Node script that will generate our output will match the FIPS codes from the GeoJSON file to the Census Bureau's [most recent definitions](https://www.census.gov/geo/reference/codes/cou.html), included here in [sources/fips.json](sources/fips.json) directory, so that we have detailed information for each county. (To wit: Even though that data is mostly baked into the Shapefiles, one can never be too careful in checking that the erstwhile Shannon County, SD has been correctly rebranded as [Oglala Lakota](https://en.wikipedia.org/wiki/Oglala_Lakota_County,_South_Dakota).)

### Centroids

We need to compute the central point of each county in order to draw a route between them. Our script uses D3's [d3.geoPath](https://github.com/d3/d3/blob/master/API.md#geographies-d3-geo) function to do so.

### Children

To get the number of children in each county by age, we need table "S0101: AGE AND SEX" from the American Community Survey, using the five-year 2012-2016 dataset. This table is included in [/sources](/sources) since it can't be programatically downloaded, but you can view it [here](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/16_5YR/S0101/0100000US.05000.003).

These files can be tedious to work with since you have to manually check that you're using the right fields, but the script will take care of that. Remember, we're going to reduce the total number of children to 90% based on [estimates of how many celebrate Christmas](http://www.pewresearch.org/fact-tank/2015/12/21/5-facts-about-christmas-in-america/).

### Time Zones
We'd like to know the local time that Santa visits each county, so we'll use [`tz-lookup`](https://www.npmjs.com/package/tz-lookup) and [`moment-timezone`](https://www.npmjs.com/package/moment-timezone) to code each county.

## Generating the data

Mosey on over to the `scripts` directory and run the Node script that does all of the above:

	cd ../scripts
	node get_counties.js

This spits out two new files, `counties.json` and `counties.csv`. These files are spot-checked against manual calculations from the Census table for the population figures. It also produces a file called `timezone_offsets.json` that maps timezone ids to the 20 time zone names in the continental U.S.

## All set
We now have the central coordinates and number of children age nine and under in every county in the contiguous United States. Now comes the fun part. Let's head over to [TSP.md](TSP.md);