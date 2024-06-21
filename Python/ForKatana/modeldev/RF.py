#30/5/24 For the implementaion of RF Prediction in Python for Toxicity Prediction

import pandas as pd
import numpy as np
#Data import
targetdata = pd.read_csv('/home/z5363347/Honours/Rstudio/Datasets/dtargetautoencdata.csv')
#Creating test/train splits
from sklearn.model_selection import train_test_split

trainset, testset = train_test_split(targetdata, test_size=0.2, random_state=82)
#Converts Toxicity Values to a list
temp = trainset['Toxicity_Value']#.to_list
ytrain = []
for val in temp:
    ytrain.append(val)
ytest = []
temp = testset['Toxicity_Value']#.to_list
for val in temp:
    ytest.append(val)
#Converts encoded drug target values to an array
xtrain = trainset.iloc[:, 1:]
xtest = testset.iloc[:, 1:]


