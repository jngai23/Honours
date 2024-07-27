#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May  9 14:36:45 2024

@author: james
"""

import pandas as pd
#Data import
dataset = pd.read_csv('/Users/james/Documents/Honours/Data/processed_endo_data.csv')
smiles = dataset['Canonical SMILES'].tolist()
toxvals = dataset['Toxicity Value'].tolist()
dflist =  list(zip(smiles, toxvals))
df = pd.DataFrame(dflist, columns = ['SMILES', 'Toxicity_Values'])

onehotdata = pd.read_csv('storage/onehotdata.csv')
num_labels = range(1, len(onehotdata.columns) + 1)
column_labels = [num for num in num_labels]

onehotdata.columns = column_labels

onehotdata = pd.concat([df, onehotdata], axis=1)

onehotdata.to_csv('processedonehotdata.csv', index=False)
