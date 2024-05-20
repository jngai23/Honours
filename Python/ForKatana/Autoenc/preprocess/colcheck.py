

import pandas as pd
import numpy as np
#Data import

#targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Drug_Targets/DrugTargets.csv')
targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Structure/processedonehotdata.csv')
x = targetdata.iloc[:, 2:].values
print(x.num_columns)

