# The Travelling Santa Problem

How many households in the continental United States does Santa need to visit on Christmas, and what's the optimal route for him and his reindeer to hit each one as quickly as possible?

# Overview
There are 3,108 counties in the continental United States, and Santa has to visit each one of them. That divides this problem into three parts:

1. Assuming Santa chiefly delivers to children age 15 and under, how many households--houses, apartments and other residences--does he have to visit in each county to make sure everyone gets their presents? Using a combination of Census tables, granular Census tract data, and reams of microdata from [IPUMS](https://www.ipums.org/), we produced a detailed estimate.

2. What is the optimal route through those 3,108 counties so that Santa wastes as little time as possible in transit? This is known as the ["Travelling Salesman Problem"](https://en.wikipedia.org/wiki/Travelling_salesman_problem) and has occupied mathematicians, computer scientists and other researchers for decades. A variety of solutions exist with varying levels of accuracy, complexity and abuse to your poor Macbook's processor.

3. **And finally:** How does the answer to 1) affect the answer to 2) if Santa wants to optimize delivery time? Should he prioritize high-population counties? If so, how far out of his way should he go?

Here's how we went about figuring that out: The code in this repository is divided between Node.js for processing files and R for the statistical heavy lifting. While we will document every step taken to produce the data, many of the results of the early steps are including in the repo so that you can skip straight to calculating the route. So all the steps under "Setting Up Shop" are optional. You're welcome to rerun the code to check our work or just log a little practice, but it isn't necessary.

# Assumptions
+ Santa visits children up to age nine, [when belief in Santa drops off significantly](https://www.theatlantic.com/health/archive/2014/12/when-do-kids-stop-believing-in-santa/383958/).
+ Since [92 percent of Americans](http://www.pewresearch.org/fact-tank/2015/12/21/5-facts-about-christmas-in-america/) celebrate Christmas, Santa will visit that percentage of 0-9-year-olds in each county.
+ It takes Santa a little longer to canvas large counties, putting aside the fact that children are not evenly distributed across the region.
+ Santa begins in Aroostook County, Maine, the northeastern-most county in the continental U.S., and ends up in San Diego, the southwestern-most county.

The documentation is divided into several parts:
+ [Setting up Shop](docs/data.md): Complete documentation on how the source data was collected. You're welcome to browse through this, but the resulting files are included in the repo. All code using Node.js and the command line.
+ [Travelling Santa](docs/TSP.md): The R code for calculating the optimal route for Santa.


