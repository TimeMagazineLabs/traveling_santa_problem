var fs = require("fs");
var d3 = require("d3");
var readline = require("readline");
var stream = require('stream');

// COUNTIES
var instream = fs.createReadStream('../shp/tracts.json');
var writeStream = fs.createWriteStream('../data/tracts_demographics.csv');

var rl = readline.createInterface({
    input: instream,
    terminal: false
});

count = 0;

rl.on('line', function(line) {	
	count += 1;

	if (count == 1) {
		return;
	}
	
	var tract = JSON.parse(line).properties;

	var data = {};
	data.state_fips = tract.GEOID10.slice(0,2);

	//we're not making Santa go to Alaska and Hawaii or the territories, though he surely will on his way elsewhere
	if (parseInt(data.state_fips) > 56 || data.state_fips == "02" || data.state_fips == "15") {
		return;
	}

	data.county_fips = tract.GEOID10.slice(0,5);
	data.tract_fips = tract.GEOID10;
	//data.name = tract.NAMELSAD10;
	data.tract_population = +tract.DP0010001;
	data.tract_population_under_16 = +tract.DP0010001 - +tract.DP0030001;
	data.tract_population_under_18 = +tract.DP0010001 - +tract.DP0040001;
	data.tract_households = +tract.DP0130001;
	data.tract_households_under_18 = +tract.DP0140001;
	data.tract_housing_units = +tract.DP0180001;
	data.tract_household_size = +tract.DP0160001;
	data.tract_land_sqm = +tract.ALAND10;
	data.tract_water_sqm = +tract.AWATER10;
	data.tract_area_sqm = +tract.ALAND10; + +tract.WATER10;

	console.log(count, data.tract_fips);

	if (count == 2) {
		writeStream.write(Object.keys(data).join(",").replace("0,1,2,3,4,5,6,7,8,9,10,11,12", ""));
	}

	writeStream.write(d3.csvFormat([d3.values(data)]).replace("0,1,2,3,4,5,6,7,8,9,10,11,12", ""));
});

rl.on("close", function() {
	writeStream.end();
});