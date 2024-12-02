#16/5/24 checks if empty cells are present in a csv
#Outputs the model and a text file

import pandas as pd
import numpy as np
#Data import
#targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Drug_Targets/DrugTargets.csv')
targetdata = pd.read_csv('/srv/scratch/z5363347/processedonehotdata.csv')

nantest = targetdata.isnull().values.any()

print(nantest)