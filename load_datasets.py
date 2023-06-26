import netCDF4 as nc
import numpy as np
from osgeo import ogr
from osgeo import gdal
import pandas as pd
from osgeo import osr
from matplotlib import pyplot as plt
import geopandas as gpd
import rasterio as rio
import gzip
from shapely.geometry import Point
import cftime

####################

just_roi = True
if just_roi:
    ## box around Victoria (found using https://boundingbox.klokantech.com/) ## 140.53,-39.2,150.03,-33.73
    roi_lon_bounds = [140.53, 150.03]
    roi_lat_bounds = [-39.20, -33.73]
else:
    ## box around Australia: 106.3,-44.2,160.8,-8.9
    roi_lon_bounds = [106.3, 160.8]
    roi_lat_bounds = [-44.2,  -8.9]

study_period_bounds = [pd.Timestamp('2020-01-01T00:00:00',tz = 'UTC'), 
                       pd.Timestamp('2020-02-01T00:00:00',tz = 'UTC')]

alum_metadata = pd.read_csv('data/ALUM/NLUM_ALUMV8_250m_2015_16_alb/NLUM_ALUMV8_250m_2015_16_alb.csv')

alum_dataset = gdal.Open('data/ALUM/NLUM_ALUMV8_250m_2015_16_alb/NLUM_ALUMV8_250m_2015_16_alb.tif', gdal.GA_ReadOnly)

alum_band = alum_dataset.GetRasterBand(1)

## following the example from https://gis.stackexchange.com/a/201320 to read the metadata
alum_ulx, alum_xres, alum_xskew, alum_uly, alum_yskew, alum_yres  = alum_dataset.GetGeoTransform()
alum_nx = alum_dataset.RasterXSize
alum_ny = alum_dataset.RasterYSize
alum_lrx = alum_ulx + (alum_nx * alum_xres)
alum_lry = alum_uly + (alum_ny * alum_yres)
alum_proj = alum_dataset.GetProjection()

# Setup the source projection - you can also import from epsg, proj4...
source = osr.SpatialReference()
source.ImportFromWkt(alum_dataset.GetProjection())

# The target projection
target = osr.SpatialReference()
target.ImportFromEPSG(4326)

# Create the transform - (x,y) to (lat,lon)
transform = osr.CoordinateTransformation(source, target)
# generate the inverse transform
invtransform = osr.CoordinateTransformation(target, source)

# Transform a corner point (for testing purposes)
alum_ulx_lat, alum_ulx_lon, _ = transform.TransformPoint(alum_ulx, alum_uly)

alum_xrow = alum_ulx + np.arange(alum_nx, dtype = np.float) * alum_xres
alum_ycol = alum_uly + np.arange(alum_ny, dtype = np.float) * alum_yres

roi_xy_points = []
for ix in range(0,2):
    for iy in range(0,2):
        px, py, _ = invtransform.TransformPoint(roi_lat_bounds[ix], roi_lon_bounds[iy])
        roi_xy_points.append([px,py])

roi_xy_points_np = np.array(roi_xy_points)
roi_xlim = np.array([ roi_xy_points_np[:,0].min(), roi_xy_points_np[:,0].max() ])
roi_ylim = np.array([ roi_xy_points_np[:,1].min(), roi_xy_points_np[:,1].max() ])
roi_ixlim = np.searchsorted(alum_xrow, roi_xlim)
roi_iylim = alum_ny - np.searchsorted(alum_ycol[::-1], roi_ylim)[::-1]

alum_roi_nx = int(roi_ixlim[1] - roi_ixlim[0])
alum_roi_ny = int(roi_iylim[1] - roi_iylim[0])
alum_roi_arr = alum_band.ReadAsArray(int(roi_ixlim[0]), 
                                     int(roi_iylim[0]), 
                                     alum_roi_nx, 
                                     alum_roi_ny)

res = plt.imshow(alum_roi_arr, interpolation='nearest')
plt.savefig("alum_classes_roi.png")
plt.close()

alum_roi_xrow = alum_xrow[roi_ixlim[0]] + np.arange(alum_roi_nx, dtype = np.float) * alum_xres
alum_roi_ycol = alum_ycol[roi_iylim[0]] + np.arange(alum_roi_ny, dtype = np.float) * alum_yres

alum_roi_x = np.tile(alum_roi_xrow.reshape((alum_roi_nx,1)),alum_roi_ny)
alum_roi_y = np.tile(alum_roi_ycol.reshape((alum_roi_ny,1)),alum_roi_nx).transpose()

## Despite the vectorization, this is rather slow, even for small regions such as Victoria
## There is probably a faster way of doing this, but this is not yet set up.
f = lambda x, y: transform.TransformPoint(x, y)
vf = np.vectorize(f)
alum_roi_lat, alum_roi_lon, _  = vf(alum_roi_x, alum_roi_y)

## Below is output from from `gdalinfo data/ALUM/NLUM_ALUMV8_250m_2015_16_alb/NLUM_ALUMV8_250m_2015_16_alb.tif`
## it matches with the results from alum_ulx_lat, alum_ulx_lon (above)
# Upper Left  (-2189542.251,-1047686.305) (112d43'41.14"E,  8d27' 4.39"S)
# Lower Left  (-2189542.251,-4964936.305) (105d42'16.70"E, 43d21'50.83"S)
# Upper Right ( 2468707.749,-1047686.305) (153d41' 5.00"E,  8d 2' 0.76"S)
# Lower Right ( 2468707.749,-4964936.305) (161d32'10.18"E, 42d48' 5.51"S)
# Center      (  139582.749,-3006311.305) (133d25'57.89"E, 27d42' 5.78"S)

#################### DEM

dem_dataset = nc.Dataset('data/DEM/dem-9s.nc')
dem_lon = dem_dataset.variables['lon'][:].data
dem_lat = dem_dataset.variables['lat'][:].data

roi_ixlim = np.searchsorted(dem_lon, roi_lon_bounds)
roi_iylim = np.searchsorted(dem_lat, roi_lat_bounds)

dem_roi_arr = dem_dataset.variables['Band1'][roi_iylim[0]:roi_iylim[1],roi_ixlim[0]:roi_ixlim[1]][:].data
dem_dataset.close()
## need to flip the vertical orientation for plotting
dem_roi_arr = dem_roi_arr[::-1,:]

res = plt.imshow(dem_roi_arr, interpolation='nearest')
plt.savefig("dem_roi_landsea.png")
plt.close()

## negative values (-9999.0) are used for ocean points. Set these to zero.
dem_roi_arr[ dem_roi_arr < -100 ] = 0.0

res = plt.imshow(dem_roi_arr, interpolation='nearest')
plt.savefig("dem_roi.png")
plt.close()

#################### hotspots

dtypes = {
    'id':np.int64,
    'satellite':np.dtype('O'),
    'sensor':np.dtype('O'),
    'latitude':np.float32, ## 13
    'longitude':np.float32, ## 14
    'temp_kelvin':np.float32, ## 15
    'power':np.float32, ## 16
    'confidence':np.float32, ## 17
    ## 'datetime':'datetime64',
    'age_hours':np.int32,
    'australian_state':np.dtype('O')}

## "import rasterio as "
nrow_total = 31855161 ## 31.855e6 rows
n_per_chunk = 1000000
n_chunks = int(nrow_total / n_per_chunk) + 1
ichunk = 0
f = gzip.open('data/hotspot/all-data.csv.gz', mode = 'rt')
header = f.readline().strip().split(',')

hotspot_colnames = [ 'id', 'satellite', 'sensor', 'latitude',
                     'longitude', 'temp_kelvin', 'power', 'confidence', 'datetime',
                     'age_hours', 'australian_state' ]

known_satellites = ['AQUA', 'HIMAWARI-8', 'HIMAWARI-9', 'NOAA17', 'NOAA18', 'NOAA19', 'NOAA 19', 'NOAA 20', 'SUOMI NPP', 'TERRA']

## either use all sensors
used_satellites = 'all'
## OR just a subset of sensors
used_satellites = ['SUOMI NPP', 'AQUA', 'TERRA', 'HIMAWARI-8','HIMAWARI-9']

all_satellites = False
if type(used_satellites) == str:
    if used_satellites == 'all':
        all_satellites = True
    else:
        if used_satellites in known_satellites:
            used_satellites = [used_satellites]
        else:
            raise RuntimeError(f"Satellite {used_satellites} not in known types...")
else:
    assert type(used_satellites) == list, "used_satellites object should be of 'list' or 'str' type"
    ## get the unique satellites
    used_satellites = list(set(used_satellites))
    assert all([ s in known_satellites for s in used_satellites ]), "Some values in the 'used_satellites' list are not in the 'known_satellites' list"
    ## the used_satellites list is now unique - if the length matches
    ## that of known_satellites, then we are requesting all satellites
    if len(used_satellites) == len(known_satellites):
        all_satellites = True
    


valid_chunks = []
ichunk = 0
n_chars_per_row = 280
## if True:
## range(5): ## 
istart = 0
lines_read = 0
## for ichunk in range(n_chunks):
for ichunk in range(100):
    n_to_skip = ichunk*n_per_chunk
    print(ichunk)
    # if ichunk == n_chunks - 1:
    #     nrows_this_chunk = (nrow_total % n_per_chunk)
    # else:
    #     nrows_this_chunk = n_per_chunk
    nrows_this_chunk = n_per_chunk
    t0 = time.time()
    hotspot_lines = f.readlines(nrows_this_chunk * n_chars_per_row)
    if len(hotspot_lines) == 0:
        print('at the end of the file!')
        break
    ##
    t1 = time.time()
    lines_read += len(hotspot_lines)
    print(f'\tThat took {round(t1-t0,4)} seconds, lines read = {lines_read}')
    ##
    hotspot_rows = pd.read_csv(io.StringIO(''.join(hotspot_lines)),
                                names = hotspot_colnames,
                                header = None,
                                usecols = [0,1,4,13,14,15,16,17,18,19,20], ## use a subset of columns
                                parse_dates = ['datetime'], ## treat the 'datetime' column as datetimes
                                ## parse_dates = [8], ## treat the 'datetime' column as datetimes
                                dtype = dtypes) ## , ## more efficient if the dtype is specified per column
    ## skiprows = n_to_skip,
    ## nrows = nrows_this_chunk)
    print(hotspot_rows.shape)
    t1 = time.time()
    print(f'\tThat took {round(t1-t0,4)} seconds')

    ## Subset based on the study period
    satisfies_time_criteria = (hotspot_rows.datetime > study_period_bounds[0]) & (hotspot_rows.datetime < study_period_bounds[1])
    n_times_ok = satisfies_time_criteria.sum()
    print(f'\tNumber satisfying the time criteria = {n_times_ok}')
    if n_times_ok == 0:
        print(f'\t\tSkipping...')
        continue
    ##
    valid_subset = hotspot_rows[satisfies_time_criteria]

    ## Subset based on the region-of-interest
    satisfies_roi_criteria = (valid_subset.longitude > roi_lon_bounds[0]) & (valid_subset.longitude < roi_lon_bounds[1]) & (valid_subset.latitude > roi_lat_bounds[0]) & (valid_subset.latitude < roi_lat_bounds[1])
    n_locs_ok = satisfies_roi_criteria.sum()
    print(f'\tNumber satisfying the time criteria = {n_locs_ok}')
    if n_locs_ok == 0:
        print(f'\t\tSkipping...')
        continue
    ## do the subsetting
    valid_subset = valid_subset[satisfies_roi_criteria]

    ## Subset based on which satellite sensors are selected for use (don't bother if we use all sensors)
    if not all_satellites:
        satisfies_satellite_criteria = valid_subset.satellite.isin(used_satellites)
        n_satcrit_ok = satisfies_satellite_criteria.sum()
        print(f'\tNumber satisfying the satellite criteria = {n_locs_ok}')
        if n_satcrit_ok == 0:
            print(f'\t\tSkipping...')
            continue

        valid_subset = valid_subset[satisfies_satellite_criteria]
        
    valid_chunks.append(valid_subset)

## close the connection to the .csv.gz file
f.close()
## combine the subsets with valid data
valid_hotspots = pd.concat(valid_chunks)

## loading a sample of the dataset
## hotspots_df = pd.read_csv('data/hotspot/all-data.csv.gz',usecols = [0,1,4,13,14,15,16,17,18,19,20],parse_dates = ['datetime'],dtype = dtypes, nrows = 1000)


## sort based on satellite, then time
valid_hotspots = valid_hotspots.sort_values(by = ['satellite','datetime'])
## sort based on time only
valid_hotspots = valid_hotspots.sort_values(by = ['datetime'])

uniq_sats = valid_hotspots.satellite.unique()
for s in uniq_sats:
    print(s,'count =',(valid_hotspots.satellite == s).sum() )

## 
geometry = [Point(xy) for xy in zip(valid_hotspots['longitude'], valid_hotspots['latitude'])]
gdf = gpd.GeoDataFrame(valid_hotspots, geometry=geometry)   

#this is a simple map that goes with geopandas
world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres'))

australia = world.loc[world['name'] == 'Australia'] # get Australia row
boundaries = australia['geometry'] # get the geometry for Australia

gdf.plot(ax=australia.plot(figsize=(10, 6)), marker='o', color='red', markersize=15);
## save the resulting figure as a map
plt.savefig('hotspots_mapped.jpg')
## 

#################### MODIS MCD12C1 land-use classification

luc_mcd12c1_dataset = nc.Dataset('data/LUC/MCD12C1/MCD12C1.061.nc')
luc_mcd12c1_lon = luc_mcd12c1_dataset.variables['Longitude'][:].data
luc_mcd12c1_lat = luc_mcd12c1_dataset.variables['Latitude'][:].data
luc_mcd12c1_date = nc.num2date(luc_mcd12c1_dataset.variables['time'][:].data, luc_mcd12c1_dataset.variables['time'].units)

## select a date (one index per year)
target_luc_mcd12c1_date = cftime.real_datetime(2021,1,1,0,0,0)
idate_luc_mcd12c1 = [ d._to_real_datetime() for d in luc_mcd12c1_date ].index(target_luc_mcd12c1_date)

## select the ROI
roi_ixlim = np.searchsorted(luc_mcd12c1_lon, roi_lon_bounds)
roi_iylim = len(luc_mcd12c1_lat) - np.searchsorted(luc_mcd12c1_lat[::-1], roi_lat_bounds)

## extract the data
luc_mcd12c1_roi_arr = luc_mcd12c1_dataset.variables['Majority_Land_Cover_Type_1'][idate_luc_mcd12c1,roi_iylim[1]:roi_iylim[0],roi_ixlim[0]:roi_ixlim[1]].data
luc_mcd12c1_dataset.close()

## plot the land use classification for the ROI
res = plt.imshow(luc_mcd12c1_roi_arr, interpolation='nearest')
plt.savefig("luc_mcd12c1_roi_landsea.png")
plt.close()




