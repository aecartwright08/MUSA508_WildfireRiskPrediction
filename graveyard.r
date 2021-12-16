################################################################################
#     a place to bury the code that isn't in the markdown, but may come back   #
################################################################################

#### CALVEG Landcover

#  The Butte Fire District exists at the intersection of three ecological zones, which are the North Interior, North Sierra, and Central Valley.

# Classified landcover polygons within the three different layers must be joined to the fishnet, such that the most predominant landcover in any given fishnet cell is the landcover assigned to that cell.

#r chop vegetation data, include = TRUE, warning = FALSE, message = FALSE
NorthInterior_raw <- st_read("shapes/EVMid_R05_NorthInterior.shp") %>%
  dplyr::select(COVERTYPE) %>%
  st_transform('ESRI:102642')
NorthSierra_raw <- st_read("shapes/EVMid_R05_NorthSierra.shp") %>%
  dplyr::select(COVERTYPE) %>%
  st_transform('ESRI:102642')
CentralValley_raw <- st_read("shapes/EVMid_R05_CentralValley.shp") %>%
  dplyr::select(COVERTYPE) %>%
  st_transform('ESRI:102642')
# bind the three ecological regions together and write out shapefile
LC_vector <- rbind(NorthInterior_raw, NorthSierra_raw, CentralValley_raw)
# st_write(LC_vector, "shapes/butte_full_LC.shp", delete_dsn = T)
# intersect with butte district
butte_lc <- st_intersection(LC_vector, butte)
rm(LC_vector)
rm(NorthInterior_raw)
rm(NorthSierra_raw)
rm(CentralValley_raw)
gc()

#### Vegetation data

# r clean vegetation raster data
veg_temp <- raster('data/landCover/fveg_edit_1.tif')
veg <- veg_temp %>% crop(y = butte %>% st_transform(crs(veg_temp)))
rm(veg_temp)
veg <- setMinMax(veg)
veg <- projectRaster(veg, crs = 'ESRI:102642')

### Land Cover Data (vector LC data)

# The land cover data is bound to the fishnet by intersecting the fishnet with the land cover polygons and assigning a land cover designation to each fishnet cell based on the land cover that occupies the most area within the given cell.

```{r aggregate land cover, include = TRUE, warning = FALSE, message = FALSE}
LC_net <- st_intersection(fishnet, butte_lc)
LC_net$land_area <- st_area(LC_net$geometry)
LC_net$land_area <- as.numeric(LC_net$land_area)
LC_net <- LC_net %>%
  dplyr::select(uniqueID, COVERTYPE, land_area)

LC_agg <- aggregate(LC_net$land_area, by = list(uniqueID = LC_net$uniqueID), FUN = c("max"), na.rm = TRUE) %>%
  rename(land_area = x)

LC_final <- left_join(LC_agg, LC_net, by = c("uniqueID" = "uniqueID", "land_area" = "land_area")) %>%
  dplyr::select(uniqueID, COVERTYPE)

fishnet <- fishnet %>% left_join(., LC_final, by = c("uniqueID" = "uniqueID"))

rm(LC_agg)
rm(LC_agg2)
rm(LC_final)
rm(LC_net)
gc()