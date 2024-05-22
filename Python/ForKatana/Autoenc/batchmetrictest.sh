#!/bin/bash

#PBS -M z5363347@ad.unsw.edu.au
#PBS -m ae
#PBS -l select=1:ncpus=1:mem=90gb
#PBS -l walltime=12:00:00

cd /home/z5363347/Python/autoencoding/metrictesting
source /home/z5363347/.venvs/newvenv/bin/activate
chmod +x metrictest.py
python3 metrictest.py -> metriclogs2.txt