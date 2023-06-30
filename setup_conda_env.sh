#!/bin/bash

module purge
module load miniconda3/4.9.2

PROJECT=$(groups)

mkdir -p /data/cephfs/$PROJECT/$USER/conda/environments /data/cephfs/$PROJECT/$USER/conda/packages

conda config --append envs_dirs /data/cephfs/$PROJECT/$USER/conda/environments
conda config --add pkgs_dirs /data/cephfs/$PROJECT/$USER/conda/packages

conda env create -f environment.yml

conda activate analysis3


