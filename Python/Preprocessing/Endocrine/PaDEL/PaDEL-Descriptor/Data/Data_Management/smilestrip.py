#!/usr/bin/python3
#Formats SMILE data for usage with PaDEL-Descriptor software
#Input is a csv file containing SMILES along with other misc data
#Outputs a folder containing a .smi file of each SMILE in the original .csv 
#Names each file based on InChIKey
import os
import pandas

filename = "deepSMILEdata.csv"
data = pandas.read_csv(filename)

for index, row in data.iterrows():
    filename = str(row['InChIKey'])
    filename = filename.replace(' ', '')[:-2].upper()
    
    with open('./folder/' + str(f"{row['InChIKey']}_{row['Toxicity Value']}.smi"), 'w') as fp:
       fp.write(row['Canonical SMILES'])
