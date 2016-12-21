var fs = require("fs");
var d3 = require("d3");

var path = d3.geoPath(null);

// COUNTIES
var geojson = require("../geography/data/counties.json");
var fips_lookup = require("../data/fips.json");
var centroids = [];

geojson.features.forEach(county => {
	// we're not making Santa go to Alaska and Hawaii or the territories
	if (parseInt(county.properties.STATEFP) > 56 || county.properties.STATEFP == "02" || county.properties.STATEFP == "15") {
		return;
	}
	var info = fips_lookup[county.properties.GEOID];
	if (!info) {
		console.error("Couldn't match", county.properties.GEOID);
	}
	var centroid = path.centroid(county);
	centroids.push({
		fips:  county.properties.GEOID,
		name:  info.name,
		st:    info.st,
		state: info.state,
		long:   centroid[0],
		lat:   centroid[1],
		area:  county.properties.ALAND
	});
});

centroids = centroids.sort(function(a, b) {
	return parseInt(a.fips) - parseInt(b.fips);
});

fs.writeFileSync("../geography/data/county_coordinates.csv", d3.csvFormat(centroids));
fs.writeFileSync("../geography/data/county_coordinates.json", JSON.stringify(centroids, null, 2));	

// STATES
var geojson = require("../geography/data/states.json");
var centroids = [];

geojson.features.forEach(state => {
	// we're not making Santa go to Alaska and Hawaii or the territories
	if (parseInt(state.properties.GEOID) > 56 || state.properties.GEOID == "02" || state.properties.GEOID == "15") {
		return;
	}
	var info = fips_lookup[state.properties.STUSPS];
	if (!info) {
		console.error("Couldn't match", state.properties.STUSPS);
	}
	var centroid = path.centroid(state);
	centroids.push({
		fips:  state.properties.GEOID,
		name:  info.name,
		st:    info.abbr_two_letter,
		long:   centroid[0],
		lat:   centroid[1],
		area:  state.properties.ALAND
	});
});

centroids = centroids.sort(function(a, b) {
	return parseInt(a.fips) - parseInt(b.fips);
});

fs.writeFileSync("../geography/data/state_coordinates.csv", d3.csvFormat(centroids));
fs.writeFileSync("../geography/data/state_coordinates.json", JSON.stringify(centroids, null, 2));	
