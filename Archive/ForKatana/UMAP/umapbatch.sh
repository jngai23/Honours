#!/bin/bash

#PBS -M z5363347@ad.unsw.edu.au
#PBS -m ae
#PBS -l select=1:ncpus=1:mem=32gb
#PBS -l walltime=6:00:00

cd /home/z5363347/Python/UMAP
source /home/z5363347/.venvs/newvenv/bin/activate
chmod +x UMAP.py
python3 UMAP.py