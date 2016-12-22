var fs = require("fs");
var d3 = require("d3");
var readline = require("readline");

// COUNTIES
var fips_lookup = require("../sources/fips.json");

var instream = fs.createReadStream('../sources/2016_Gaz_tracts_national.txt');
var writeStream = fs.createWriteStream('../data/tracts_geography.csv');

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

	var tract = {
		state_fips: data[1].slice(0,2),
		state_abbr: data[0],
		state_name: "",
		county_fips: data[1].slice(0,5),
		county_name: "",
		tract_fips: data[1],
		tract_land_sq_m: +data[2],
		tract_water_sq_m: +data[3],
		tract_area_sq_m: +data[2] + +data[3],
		tract_land_sq_mi: +data[4],
		tract_water_sq_mi: +data[5],
		tract_area_sq_mi: +data[4] + +data[5],
		tract_lat: +data[6],
		tract_lng: +data[7]
	}

	if (count == 2) {
		writeStream.write(Object.keys(tract).join(",").replace("0,1,2,3,4,5,6,7,8,9,10,11,12,13", ""));
	}

	if (parseInt(tract.state_fips) > 56 || tract.state_fips == "02" || tract.state_fips == "15") {
		return;
	}

	console.log(count, tract.tract_fips);

	var info = fips_lookup[tract.county_fips];
	if (info) {
		tract.state_name = info.state;
		tract.county_name = info.name;		
	}

	writeStream.write(d3.csvFormat([d3.values(tract)]).replace("0,1,2,3,4,5,6,7,8,9,10,11,12,13", ""));
});


rl.on("close", function() {
	writeStream.end();
});