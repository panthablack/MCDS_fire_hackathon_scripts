required_packages <- c('ncdf4', 'fields`')
installed_packages <- rownames(installed.packages())
packages_to_install <- setdiff(required_packages, installed_packages)
if(length(packages_to_install) > 0){
    install.packages(packages_to_install)
}

for(pkg in required_packages){
    library(pkg, character.only = TRUE, quietly = TRUE)
}

just_roi = TRUE
if(just_roi){
    ## box around Victoria (found using https://boundingbox.klokantech.com/) ## 140.53,-39.2,150.03,-33.73
    roi_lon_bounds = c(140.53, 150.03)
    roi_lat_bounds = c(-39.20, -33.73)
} else {
    ## box around Australia: 106.3,-44.2,160.8,-8.9
    roi_lon_bounds = c(106.3, 160.8)
    roi_lat_bounds = c(-44.2,  -8.9)
}

study_period_bounds = c(as.POSIXct('2020-01-01 00:00:00',tz = 'UTC'), 
                        as.POSIXct('2020-02-01 00:00:00',tz = 'UTC'))

#################### ALUM land-use data

#################### DEM

dem_dataset = nc_open('data/DEM/dem-9s.nc')
dem_lon = dem_dataset$dim$lon$vals
dem_lat = dem_dataset$dim$lat$vals

roi_ixlim = cut(roi_lon_bounds, dem_lon, labels = FALSE)
roi_iylim = cut(roi_lat_bounds, dem_lat, labels = FALSE)
dem_lon_subset = dem_lon[roi_ixlim[1]:roi_ixlim[2]]
dem_lat_subset = dem_lat[roi_iylim[1]:roi_iylim[2]]

dem_roi_arr = ncvar_get(dem_dataset,'Band1',
                        start = c(roi_ixlim[1], roi_iylim[1]), 
                        count = c(diff(roi_ixlim), diff(roi_iylim)))
res <- nc_close(dem_dataset)

png("dem_roi_landsea.png")
image.plot(dem_lon_subset, dem_lat_subset, dem_roi_arr,
           xlab = 'longitude', ylab = 'latitude')
dev.off()

#################### hotspots

#################### MODIS MCD12C1 land-use classification

#################### ERA5 hourly weather data

#################### AGCD daily weather data

#################### BARRA hourly weather data


