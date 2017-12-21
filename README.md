# The Travelling Santa Problem

How many children in the continental United States does Santa need to visit on Christmas, and what's the optimal route for him and his reindeer to hit each one as quickly as possible?

# Overview
There are 3,108 counties in the continental United States, and Santa has to visit each one of them. That divides this problem into three parts:

1. What is the optimal route through those 3,108 counties so that Santa wastes as little time as possible in transit? This is known as the ["Travelling Salesman Problem"](https://en.wikipedia.org/wiki/Travelling_salesman_problem) and has occupied mathematicians, computer scientists and other researchers since 1930. A variety of solutions exist with varying levels of accuracy, complexity and abuse to your poor computer's processor.

2. Assuming Santa delivers to children age 9 and under, which is around when belief in Santa drops off, how many children does he have to visit in each county to make sure everyone gets their presents? Using a combination of Census data and polling data on how many families celebrate Christmas, we produced an estimate for each county.

3. **And finally:** What's the minimal amount of time in which Santa can visit each child, based on the data above? We assume he travels at 930 miles per second, which is 0.5% the speed of light.

Here's how we went about figuring that out: The code in this repository is divided between Node.js for producing the data files and R for the statistical heavy lifting. The documentation is divided into several parts:
+ [Setting up shop](docs/data.md): Complete documentation on how the source data was collected. You're welcome to browse through this, but the resulting files are included in the repo. All code using Node.js and the command line.
+ [Traveling Santa](docs/TSP.md): The R code for calculating the optimal route for Santa.

# Assumptions
+ Santa visits children up to age nine, [when belief in Santa drops off significantly](https://www.theatlantic.com/health/archive/2014/12/when-do-kids-stop-believing-in-santa/383958/).
+ Since [90 percent of Americans](http://www.pewresearch.org/fact-tank/2015/12/21/5-facts-about-christmas-in-america/) celebrate Christmas, Santa will visit that percentage of 0-to-9-year-olds in each county.
+ It takes Santa a longer to canvas large or high-population counties, putting aside the fact that children are not evenly distributed across the region.
+ Santa begins in Aroostook County, Maine, the northeastern-most county in the continental U.S., and ends up in San Diego, the southwestern-most county.

# Contest: Beat Our Time!
We're challenging anyone who wants to come up with a more efficient route between counties and a better way to calculate the distance Santa has to travel within each county. [Here are the guidelines](docs/rules.md) for anyone who wishes to try and do better!