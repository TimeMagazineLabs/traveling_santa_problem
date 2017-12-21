#  The Rules

We're eager to see if anyone can produce a more efficient route for Santa to visit each county in the continental U.S. than ours, which takes *2 hours and 3 minutes*. If you think you can beat that, please email a link to your code to Chris Wilson at [chris.wilson@time.com](mailto:chris.wilson@time.com).

+ Submissions must be open-source. You may either fork this repo or create your own.
+ You should use the same coordinates for each county as we did, which is available in the [data](../data) directory as `counties.csv` or `counties.json`
+ Santa must travel at 0.005 * c, or 930 miles per second
+ Santa must begin in Aroostook County, ME and end in San Diego, CA, visiting each county once
+ Santa only delivers to children age nine and under, serving 90% of that population in each county based on [polling data](http://www.pewresearch.org/fact-tank/2015/12/21/5-facts-about-christmas-in-america/). The `counties` file includes the number of children. You may either use our figures or compute your own using more granular methods, but if you do, **don't forget to multiply by 0.9.** Figures from other sources, like Census tract data, should be reasonably close to ours on a county level.
+ You may use any language or method to compute the route, such as a [Hamiltonian path](https://en.wikipedia.org/wiki/Hamiltonian_path). But all code needs to be reproducible by other users, so please stay away from proprietary software. Sorry, Mathematica users!
+ Submissions should include a CSV file called `optimal_route.csv` in the same general format as [ours](../data/optimal_route.csv)--a file with one line for each county in the order that Santa visits them.
+ Right now, Santa's travel time is calculated as the [distance in a matrix](https://math.stackexchange.com/questions/2573350/estimating-distance-to-travel-to-each-household-in-a-county) of all the children in 50% of the county's land mass--`sqrt(children * area)`. You may either use this formula or propose a better one.
+ Please include a brief writeup of your approach in the README and a calculation of the total time it takes Santa to visit each child, including a link to the [TIME article](http://time.com/5072619/santa-tracker-christmas-eve/) in anything you post. The time to beat is 2 hours and 3 minutes. Good luck!

To analyze your route, you can load it into the R file [R/analyze_route.R](../R/analyze_route.R) or calculate the result yourself: The sum of the distance of the total route and the distance traveled in each county, divided by velocity.
