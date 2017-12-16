

As always, Mike Bostock has a [cogent rundown on all the contemporary methods](https://medium.com/@mbostock/command-line-cartography-part-1-897aa8f8ca2c#.8icwko3uz) for converting SHP files to lightweight, browser-ready TopoJSON. Since our goal here is to extra information from the files, not to make them production ready, we can skip a few steps. 

If we were just interested in making a map to render in the browser, for example, we would probably take this opportunity to choose a map projection and convert the raw longitude and latitude values to the x and y coordinates we need to display geography on the screen. There are a multitude of [projections](https://github.com/d3/d3-geo-projection#projections) available from Bostock's [d3-geo-projection](https://github.com/d3/d3-geo-projection) module. (Otherwise, one has to run those trig-heavy calculations on the client each time someone loads the map.) In this case, however, we are going to need to calculate the distance between each county as accurately as possible in order to optimize Santa's route. The safest way to do this is to calculate the "great-circle distance" between two lat/long pairs--that is, the distance between two points that accounts for the fact that the earth is [(almost)](https://en.wikipedia.org/wiki/Earth_ellipsoid) round. The algorithm to compute this distance comes in a few main flavors, the most popular of which is probably the [Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula). Almost every robust programming language has a library to handle this instead of forcing you to revisit arctangents.


Okay, now we have the files in the [geography/data](geography/data) directory -- `county_coordinates.csv` and `state_coordinates.csv`--to take a first pass at the Travelling Santa Problem. We'll mostly be dealing with counties, but it's nice to have states for sanity checks.




## Getting the data
TK

# Computing Santa's Route

Okay, either you generated all the files you needed to start crunching routes or you skipped straight here. Let's get started. This portion of our program is conducted entirely in R. While it can be run from the command line, we highly recommend you use [RStudio](https://www.rstudio.com/) to examine the code and read the rather verbose comments.

## The Travelling Salesman Problem

This is such a famous problem in mathematics that there are any number of papers and tutorials out there that offer solutions in a variety of methods. Since we're dealing with 3,108 counties, we have to compute the distance between all 4,828,278 combination of any two counties. And for what it's worth, the [number of possible solutions](http://math.stackexchange.com/questions/725396/how-many-routes-possible-in-the-traveling-salesman-problem-with-n-cities-and) is `(n-1)!/2`, which, according to Mathematica--the only program that seems willing to entertain the idea of taking a factorial of 3,108--is 1.568*10^9503. We're probably not going to try all of them.

We're going to take advantage of existing libraries that implement these algorithms. For R, the most authoritative appears to be [TSP](https://cran.r-project.org/web/packages/TSP/index.html), which offers nine different approaches to solving routes, or "tours" as they're often called:

+ `"identity"`: "A tour representing the order in the data (identity order)." Sounds skippable. 

+ `"random"`: "A tour representing the order in ... a random order." Also skipping.

+ `"nearest_insertion"`: "The nearest insertion algorithm chooses city k in each step as the city which is nearest to a city on the tour." Sounds promising.

+ `"farthest_insertion", "cheapest_insertion", "arbitrary_insertion"`: Like the above but using a different criteria for where to place the next city.

+`"nn"` ("Nearest neighbor"): "The algorithm starts with a tour containing a random city. Then the algorithm always adds to the last city on the tour the nearest not yet visited city." Seems sensible.

+`"repetitive_nn"`: "Repetitive nearest neighbor constructs a nearest neighbor tour for each city as the starting point and returns the shortest tour found." We will probably skip this one since Santa will be coming from the north and is unlikely to randomly start in Tulsa.

+ `"two_opt"`: "This is a tour refinement procedure which systematically exchanges two edges in the graph represented by the distance matrix till no improvements are possible." Sure.

(The TSP library also includes two methods that require use of [Concorde](https://en.wikipedia.org/wiki/Concorde_TSP_Solver), an advanced program that is free for academics. It produced the most reliably concise tours when distance is the chief concern, instead of presents, but even with permission, using Concorde involve interfacing with eternal software that cannot be documented or tweaking during development.)



