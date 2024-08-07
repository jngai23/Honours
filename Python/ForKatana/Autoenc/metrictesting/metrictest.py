#16/5/24 For the creation of an Autoencoder for Feature Extraction on Katana
#Outputs the model and a text file

import pandas as pd
import numpy as np
#Data import
#targetdata = pd.read_csv('/Users/james/Documents/Honours/Python/Target_Selection/Drug_Targets/DrugTargets.csv')
targetdata = pd.read_csv('/srv/scratch/z5363347/nadrop1hotdata.csv')

#Creating test/train splits
from sklearn.model_selection import train_test_split

trainset, testset = train_test_split(targetdata, test_size=0.2, random_state=81)
#Converts Toxicity Values to a list
ytest = testset['Toxicity_Values'].to_list
#Converts encoded drug target values to an array
xtest = testset.iloc[:, 2:].values

import tensorflow as tf
from tensorflow import keras
autoencoder = keras.models.load_model('/srv/scratch/z5363347/models/8.model')

colcount = len(xtest[0])
ae_out = autoencoder.predict([ xtest.reshape(-1, colcount, 1) ])
predictions = ae_out.reshape(2649,colcount)

correctcount = 0
fpcount = 0
tpcount = 0
tncount = 0
fncount = 0
testpos = 0
testneg = 0

iterations = 0
for samples in predictions:
    loops = 0
    for value in predictions[iterations]:
        testscore = xtest[iterations][loops]
        if value > 0.3:
            if testscore != 0:
                testpos = testpos + 1
                correctcount = correctcount + 1
                tpcount = tpcount + 1
            else:
                fpcount = fpcount + 1
                testneg = testneg + 1
        else:
            if testscore != 0:
                testpos = testpos + 1
                fncount = fncount + 1
            else:
                testneg = testneg + 1
                correctcount = correctcount + 1
                tncount = tncount + 1
                
        loops = loops + 1

print('model = 8.model')

print('positives in data', testpos)
print('negatives in data', testneg)

print('fn count =', fncount)
print('tn count =', tncount)

print('tp count =', tpcount)
print('fp count =', fpcount)

netfn = fncount / (fncount + tncount)
nettn = tncount / (fncount + tncount)
netacc = correctcount / (fpcount + fncount + tpcount + tncount)
posacc = tpcount / testpos
negacc = tncount / testneg
netfp = fpcount / (fpcount + tpcount)
nettp = tpcount / (tpcount + fpcount)

print('fn rate =', netfn)
print('tn rate =', nettn)

print('net accuracy =', netacc)
print('positive accuracy =', posacc)
print('negative accuracy =', negacc)

print('fp rate =', netfp)
print('tp rate =', nettp)
