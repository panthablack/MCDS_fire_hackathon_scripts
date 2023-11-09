import sys
sys.path.append('~/packages')
import os
sys.path.append('./src')
# help('modules') # uncomment for debugging modules

import utilities
# from utilities import sayHello
import geo
from geo import getBoundingCoords

# import constants
import constants
from constants import PLOT_FIGS_HERE

#run startup scripst
import boot
from boot import jupyterEnvFixes
jupyterEnvFixes()

# # Importing libraries for visualization
import matplotlib
from matplotlib import pyplot as plt

# Importing libraries for data manipulation and analysis
import numpy as np
import pandas as pd
import xarray
import dask
import glob
import gzip
import cftime
import time
import io

# Importing libraries for geospatial data
import geopandas as gpd
import rasterio as rio
from shapely.geometry import Point

# Importing libraries for visualization
from matplotlib import pyplot as plt

# Importing library for working with netCDF files
import netCDF4 as nc

boundingCoords = getBoundingCoords(True)
roi_lon_bounds = boundingCoords[0]
roi_lat_bounds = boundingCoords[1]

# Define the study period
study_period_bounds = [
    pd.Timestamp('2020-01-01T00:00:00', tz='UTC'), 
    pd.Timestamp('2020-02-01T00:00:00', tz='UTC')
]

# Load DEM data from NetCDF file
dem_dataset = nc.Dataset('data/DEM/dem-9s.nc')
dem_lon = dem_dataset.variables['lon'][:].data
dem_lat = dem_dataset.variables['lat'][:].data

# Find the DEM indices corresponding to the ROI
roi_ixlim = np.searchsorted(dem_lon, roi_lon_bounds)
roi_iylim = np.searchsorted(dem_lat, roi_lat_bounds)

# Extract DEM data for ROI
dem_roi_arr = dem_dataset.variables['Band1'][roi_iylim[0]:roi_iylim[1], roi_ixlim[0]:roi_ixlim[1]][:].data
dem_dataset.close()

# Flip the vertical orientation for plotting
dem_roi_arr = dem_roi_arr[::-1, :]

# Plot and save the DEM ROI including land and sea
res = plt.imshow(dem_roi_arr, interpolation='nearest')
plt.title('Terrain height for the region of interest (with oceans masked)')
if not PLOT_FIGS_HERE:
    plt.savefig("images/dem_roi_landsea.png")
    plt.close()

# Replace ocean points (negative values) with zero for better visualization
dem_roi_arr[dem_roi_arr < -100] = 0.0

# Plot and save the modified DEM ROI
res = plt.imshow(dem_roi_arr, interpolation='nearest')
plt.title('Terrain height for the region of interest')
if not PLOT_FIGS_HERE:
    plt.savefig("images/dem_roi.png")
    plt.close()

print('finished')