var fs = require("fs");
var d3 = require("d3");

// COUNTIES
var fips_lookup = require("../sources/fips.json");
var counties = [];

var geojson = require("../data/counties.json");

var path = d3.geoPath(null);

geojson.features.forEach(county => {
	var info = fips_lookup[county.properties.GEOID];
	if (!info) {
		console.error("Couldn't match", county.properties.GEOID);
	}
	var centroid = path.centroid(county);
	counties.push({
		fips:  county.properties.GEOID,
		name:  info.name,
		st:    info.st,
		state: info.state,
		long:   centroid[0],
		lat:   centroid[1],
		area:  county.properties.ALAND
	});
});

// things got a bit out of order
counties.sort(function(a, b) {
	return a.fips < b.fips ? -1 : 1;
});


fs.writeFileSync("../data/county_coordinates.csv", d3.csvFormat(counties));
fs.writeFileSync("../data/county_coordinates.json", JSON.stringify(counties, null, 2));	