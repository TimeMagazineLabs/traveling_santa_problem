# Welcome! This short introduction will just give a short overview of the R scripts
# In this directory and which libraries you'll need to make them work.

# There are TK libraries in use across the three scripts, some of which are meant only
# For spotchecking and proofs of concept. You can either manually install them through the
# R or RStudio menus or just run the follow commands

roster = rownames(installed.packages())

# A common graphics library for charts and maps. You may already of it.
# https://cran.r-project.org/web/packages/ggplot2/index.html
install.packages("ggplot2")

# Aka "spatial data." Used to calculate the distance between geographic (lat/lng) coordinates
# Docs: https://cran.r-project.org/web/packages/sp/sp.pdf
install.packages("sp")

# Draw maps with the help if ggplot2
# Docs: https://cran.r-project.org/web/packages/maps/maps.pdf
install.packages("maps")
#install.packages("maptools")






# The bulk of the work is done in 