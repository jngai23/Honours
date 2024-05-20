#16/5/24 Implementation of UMAP for Dimensionality Reduction in Katana

import pandas as pd
import numpy as np
import umap
import matplotlib.pyplot as plt
import seaborn as sns

#Data import
targetdata = pd.read_csv('/srv/scratch/z5363347/processedonehotdata.csv')
#targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Drug_Targets/DrugTargets.csv')

toxvals = targetdata['Toxicity_Values'].to_list
smiles = targetdata['SMILES'].to_list
data = targetdata.iloc[:, 2:].values

#Supervised UMAP
embedding = umap.UMAP(random_state=81, 
                      n_neighbors=63,
                      min_dist=0.58,
                      n_components=2).fit_transform(data, y=targetdata.Toxicity_Values)
plt.scatter(
    embedding[:, 0],
    embedding[:, 1],
    c=[sns.color_palette()[x] for x in targetdata.Toxicity_Values.map({0:0, 1:1})])
plt.gca().set_aspect('equal', 'datalim')
plt.title('Supervised UMAP, neigh=63, mindist=.58, n_comp=2')
plt.savefig('OneHotUMAP.pdf')

#Export to file
dimred = pd.DataFrame(embedding)
concatdata = pd.concat([targetdata.SMILES, targetdata.Toxicity_Values, dimred], axis=1, ignore_index=True, sort=False)
concatdata = pd.DataFrame(concatdata)

concatdata.drop(concatdata.columns[0], axis=1)
labels = ['SMILES', 'Toxicity_Value', '1', '2']
concatdata.columns = labels
concatdata

concatdata.to_csv("OneHotUMAPdata.csv")