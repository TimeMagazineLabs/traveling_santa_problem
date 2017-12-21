var fs = require("fs");
var d3 = require("d3");
var moment = require('moment-timezone');
var tzlookup = require('tz-lookup');

var timezone_key = 1;
var timezones = {};

var square_miles_per_square_meters = 1 / 2589988.11;

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

	var timezone = tzlookup(centroid[1], centroid[0]);
	if (!timezones[timezone]) {
		timezones[timezone] = timezone_key;
		timezone_key += 1;
	}

	counties.push({
		fips:  county.properties.GEOID,
		name:  info.name + ", " + info.st,
		long:   centroid[0],
		lat:   centroid[1],
		tz: timezones[timezone],
		area:  county.properties.ALAND * square_miles_per_square_meters,
		children: Math.round((population.total_population * population.under_five / 100 + population.total_population * population.five_to_nine / 100) * 0.9)
	});
});

// things got a bit out of order
counties.sort(function(a, b) {
	return a.fips < b.fips ? -1 : 1;
});

fs.writeFileSync("../data/counties.csv", d3.csvFormat(counties));
fs.writeFileSync("../data/counties.json", JSON.stringify(counties, null, 2));

var tzs = {};

d3.entries(timezones).forEach(d => {
	var date = "2017-12-25T00:00:00.0";
	var m = moment.tz(date, d.key);
	var t = m.format();
	var name = m.format("z");
	var offset = t.slice(-6);
	tzs[d.value] = {
		hours: offset,
		offset: parseInt(offset),
		abbr: name,
		name: d.key
	}
});

fs.writeFileSync("../data/timezone_offsets.json", JSON.stringify(tzs, null, 2));