# MCDS fire-related hackathon scripts
---
Scripts to support a collaborative data-analytic event, focussing on
fire in Australia. 

## Scripts
 - `dataset_inventory.csv`: Description of each of the datasets
   involved, their source, and some metadata about them
 - `environment.yml`: A conda environment file for building the
   collection of conda packages used by `load_datasets.py`
 - `load_datasets.py`: A Python script that illustrates how you can
   loads up the datasets and make basic plots
 - `setup_conda_env.sh`: A shell script that sets up the conda
   environment defined by `environment.yml`
 - `rebuild_conda_env.sh`: A shell script that rebuilds the conda
   environment, if there are changes to `environment.yml`
 - `steps.sh`: A shell script with the steps used to access (some of)
   the datasets provided here. This only covers those that were
   accessible via `wget` (command-line downloader) or an API. Note
   that some of the scripts were not accessible in this way. See 
   notes in `data_sources.txt` for a description of such access 
   processes.





