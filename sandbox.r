################################################################################
#                          A place to try out ideas                            #
################################################################################

library(tidyverse)
library(sf)
library(gridExtra)
library(viridis)
library(caret)
library(pscl)
library(plotROC)
library(pROC)
library(knitr)
library(kableExtra)

ggplot() +
  geom_sf(data = butte, fill = "grey") +
  geom_sf(data = fishnet, aes(fill = burned)) +
  scale_fill_manual(values = c(paste0(palette2))) +
  mapTheme()

ggplot() +
  geom_sf(data = fishnet, aes(fill = precip)) +
  scale_fill_viridis() +
  mapTheme()

ggplot() +
  geom_sf(data = fishnet, aes(fill = hazard)) +
  scale_fill_viridis(option = 'magma') +
  mapTheme()

ggplot() +
  geom_sf(data = netBorder, fill = 'grey') +
  mapTheme()

r <- raster('/vsicurl/https://ftp.cpc.ncep.noaa.gov/GIS/USDM_Products/precip/total/monthly/p.full.202110.tif')
r <- setMinMax(r)
plot(r, zlim=c(0,389))


