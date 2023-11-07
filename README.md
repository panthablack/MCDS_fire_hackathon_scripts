# MCDS fire-related hackathon scripts
---
Scripts to support a collaborative data-analytic event, focussing on
fire in Australia. 

## Files

The most important files for this activity are:
 - `hackathon_notebook.ipynb`: a Python Jupyter notebook that
   illustrates how you can loads up the datasets and make basic plots
   (based on `load_datasets.py`, below).
 - `dataset_inventory.csv`: Description of each of the datasets
   involved, their source, and some metadata about them
   
Some participants will need to or want to set up their own Python
virtual environment. This can be facilitated with the following
scripts:
 - `environment.yml`: A conda environment file for building the
   collection of conda packages used by `load_datasets.py`
 - `setup_conda_env.sh`: A shell script that sets up the conda
   environment defined by `environment.yml`
 - `rebuild_conda_env.sh`: A shell script that rebuilds the conda
   environment, if there are changes to `environment.yml`
   
If you are a more experienced Python coder, you may prefer to get
started with a "plain Python" script, which was the basis for the
`hackathon_notebook.ipynb`:
 - `load_datasets.py`: A Python script that illustrates how you can
   loads up the datasets and make basic plots
   
If you are interested in how these datasets were prepared, you can
look at:
 - `steps.sh`: A shell script with the steps used to access (some of)
   the datasets provided here. This only covers those that were
   accessible via `wget` (command-line downloader) or an API. Note
   that some of the scripts were not accessible in this way. This is
   not meant to be run on the VMs.

## Datasets

The data should be available on the UoM Virtual machines set up for
this activity, under: `/mnt/mediaflux_fires_dataset/MCDS_fire_datasets/`

For non-UoM participants, we will provide download links to access
each of the datasets. The size of these datasets is listed below:
```
186M	ALUM/
29M	boundaries/
499K	climate_classification/
1.8G	DEM/
255M	e4ftl01.cr.usgs.gov/
4.0G	FC/
1.7G	fire_history/
752M	hotspot/
33G	LUC/
226M	phenology/
16M	population_grid/
172M	roads/
434G	weather/
```
See the `dataset_inventory.csv` file for for more information about
each of the datasets.
