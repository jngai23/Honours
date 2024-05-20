#!/bin/bash

#PBS -M z5363347@ad.unsw.edu.au
#PBS -m ae
#PBS -l select=1:ncpus=1:mem=128gb
#PBS -l walltime=12:00:00

cd /home/z5363347/Python/autoencoding
source /home/z5363347/.venvs/newvenv/bin/activate
chmod +x sizecheck.py
python3 sizecheck.py -> nantestlogs.txt