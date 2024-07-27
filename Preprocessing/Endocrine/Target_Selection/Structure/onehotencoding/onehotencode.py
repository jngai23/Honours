#7/5/24 For the creation of an Autoencoder for Feature Extraction
#when given a dataset this script one hot encodes it and turns it into a csv file

import pandas as pd
import numpy as np
#Data import
dataset = pd.read_csv('/Users/james/Documents/Honours/Data/processed_endo_data.csv')
smiles = dataset['Canonical SMILES'].tolist()
toxvals = dataset['Toxicity Value'].tolist()
dflist =  list(zip(smiles, toxvals))
df = pd.DataFrame(dflist, columns = ['SMILES', 'Toxicity_Values'])

from smiles_encoder import SmilesEncoder
smiles = [string.replace(" ", "") for string in smiles]
encoder = SmilesEncoder(smiles)
encoded_smiles = encoder.encode_many(smiles)

onehot = pd.DataFrame(encoded_smiles)
concalist = []
loops = 0
for smile in smiles:
    templist = []
    for lists in onehot.iloc[loops]:
        if isinstance(lists, list):
            templist = templist + lists
    concalist.append(templist)
    loops = loops + 1
    
onehotframe = pd.DataFrame(concalist)
onehotframe.to_csv('onehotdata.csv', index=False)