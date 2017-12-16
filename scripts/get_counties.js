var fs = require("fs");
var d3 = require("d3");

// ACS data
var children = {};

var ACS = d3.csvParse(fs.readFileSync("../sources/ACS_16_5YR_S0101/ACS_16_5YR_S0101_with_ann.csv", "utf8"));

ACS.forEach(d => {
	children[d['GEO.id2']] = {
		total_population: +d.HC01_EST_VC01,
		under_five: +d.HC01_EST_VC03,
		five_to_nine: +d.HC01_EST_VC04
	};
});

// data
var fips_lookup = require("../sources/fips.json");
var counties = [];

var geojson = require("../data/counties.geo.json");

var path = d3.geoPath(null);

geojson.features.forEach(county => {
	var info = fips_lookup[county.properties.GEOID];
	var population = children[county.properties.GEOID];

	if (!info) {
		console.error("Couldn't match", county.properties.GEOID);
	}
	var centroid = path.centroid(county);
	counties.push({
		fips:  county.properties.GEOID,
		name:  info.name + ", " + info.st,
		// st:    info.st,
		state: info.state,
		long:   centroid[0],
		lat:   centroid[1],
		area:  county.properties.ALAND,
		population: population.total_population,
		children: Math.round(population.total_population * population.under_five / 100 + population.total_population * population.five_to_nine / 100)
	});
});

// things got a bit out of order
counties.sort(function(a, b) {
	return a.fips < b.fips ? -1 : 1;
});

fs.writeFileSync("../data/counties.csv", d3.csvFormat(counties));
fs.writeFileSync("../data/counties.json", JSON.stringify(counties, null, 2));	