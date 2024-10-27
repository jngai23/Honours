#16/5/24 Replaces all empty cells in a csv with 0s
#Outputs the model and a text file

import pandas as pd

#Data import
#targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Drug_Targets/DrugTargets.csv')
#chunksize = 3000
#targetdata = pd.read_csv('/srv/scratch/z5363347/processedonehotdata.csv', chunksize=chunksize)
#df = pd.DataFrame
#for chunk in targetdata:
    #newchunk = chunk.fillna(0)
    #df = pd.concat([df, newchunk], ignore_index=True)
targetdata = pd.read_csv('/srv/scratch/z5363347/processedonehotdata.csv')
targetdata = targetdata.fillna(0)
targetdata.to_csv('/srv/scratch/z5363347/nadrop1hotdata.csv')