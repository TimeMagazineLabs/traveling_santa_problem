var fs = require("fs");
var d3 = require("d3");

// COUNTIES
var counties = [];

var counties = require("../data/county_coordinates.json");

var children = {};

var ACS = d3.csvParse(fs.readFileSync("../sources/ACS_16_5YR_S0101/ACS_16_5YR_S0101_with_ann.csv", "utf8"));

console.log(ACS[0]);

ACS.forEach(d => {
	children[d['GEO.id2']] = {
		total_population: +d.HC01_EST_VC01,
		under_five: +d.HC01_EST_VC03,
		five_to_nine: +d.HC01_EST_VC04
	};
});

counties.forEach(county => {
	var population = children[county.fips];
	if (!population) {
		console.log("No data for", county.fips);
		return;
	}
	county.population = population.total_population;
	county.children = Math.round(population.total_population * population.under_five / 100 + population.total_population * population.five_to_nine / 100);
});

fs.writeFileSync("../data/county_population.csv", d3.csvFormat(counties));
fs.writeFileSync("../data/county_population.json", JSON.stringify(counties, null, 2));	