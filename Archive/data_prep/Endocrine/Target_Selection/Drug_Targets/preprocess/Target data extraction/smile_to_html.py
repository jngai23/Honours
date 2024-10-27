#!/usr/bin/python
import pandas as pd
import numpy as np
#Data import
dataset = pd.read_csv('/Users/james/Documents/Honours/Data/processed_endo_data.csv')
smiles = dataset['Canonical SMILES'].tolist()
toxvals = dataset['Toxicity Value'].tolist()
loops = 0
for items in smiles:
    smiles[loops] = smiles[loops].replace('=', '%3d')
    smiles[loops] = smiles[loops].replace('$', '%24')
    smiles[loops] = smiles[loops].replace('+', '%2b')
    smiles[loops] = smiles[loops].replace(',', '%2c')
    smiles[loops] = smiles[loops].replace('/', '%2f')
    smiles[loops] = smiles[loops].replace(':', '%3a')
    smiles[loops] = smiles[loops].replace(';', '%3b')
    smiles[loops] = smiles[loops].replace('?', '%3f')
    smiles[loops] = smiles[loops].replace('@', '%40')
    loops = loops + 1

dflist =  list(zip(smiles, toxvals))
df = pd.DataFrame(dflist, columns = ['SMILES', 'Toxicity_Values'])

half = (len(df) // 2)
firsthalf = df.iloc[:half]
secondhalf = df.iloc[half:]

firsthalf.to_csv('datahalf1.csv', index=False)
secondhalf.to_csv('datahalf2.csv', index=False)
