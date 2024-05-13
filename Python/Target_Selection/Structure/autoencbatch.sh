#!/bin/bash

#PBS -M z5363347@ad.unsw.edu.au
#PBS -m ae
#PBS -l select=1:ncpus=1:mem=8gb
#PBS -l walltime=1:00:00

cd /home/z5363347/Python/autoencoding
pip install pandas
./onehotpreprocess.py