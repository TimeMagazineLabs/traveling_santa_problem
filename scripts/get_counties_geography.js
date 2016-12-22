var fs = require("fs");
var d3 = require("d3");
var readline = require("readline");

// COUNTIES
var fips_lookup = require("../sources/fips.json");

var instream = fs.createReadStream('../sources/2016_Gaz_counties_national.txt');
var writeStream = fs.createWriteStream('../data/counties_geography.csv');

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

	data = line.split(/\t/g);

	var county = {
		state_fips: data[1].slice(0,2),
		state_abbr: data[0],
		state_name: " ",
		county_fips: data[1],
		county_name: data[3],
		county_land_sq_m: +data[4],
		county_water_sq_m: +data[5],
		county_area_sq_m: +data[4] + +data[5],
		county_land_sq_mi: +data[6],
		county_water_sq_mi: +data[7],
		county_area_sq_mi: +data[6] + +data[7],
		county_lat: +data[8],
		county_lng: +data[9]
	}

	if (count == 2) {
		writeStream.write(Object.keys(county).join(",").replace("0,1,2,3,4,5,6,7,8,9,10,11,12", ""));
	}

	if (parseInt(county.state_fips) > 56 || county.state_fips == "02" || county.state_fips == "15") {
		return;
	}

	console.log(count, county.county_fips);

	var info = fips_lookup[county.county_fips];
	if (info) {
		county.state_name = info.state;
	}

	writeStream.write(d3.csvFormat([d3.values(county)]).replace("0,1,2,3,4,5,6,7,8,9,10,11,12", ""));
});


rl.on("close", function() {
	writeStream.end();
});
