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
ytrain = trainset['Toxicity_Values'].to_list
ytest = testset['Toxicity_Values'].to_list
#Converts encoded drug target values to an array
xtrain = trainset.iloc[:, 2:].values
xtest = testset.iloc[:, 2:].values

import tensorflow as tf
from tensorflow import keras

# Determines layer size and input/output
# Here it turns the 334 one hot encoded features to 42
colcount = len(xtrain[0])
latent_space = colcount/64
keras.utils.set_random_seed(81)
tf.config.experimental.enable_op_determinism()

# Encoder Creation
enc_in = keras.Input(shape=(colcount, 1))
x = keras.layers.Flatten()(enc_in)

# Additional encoder layers
x = keras.layers.Dense(colcount/4, activation="relu")(x)
x = keras.layers.Dense(colcount/16, activation="relu")(x)

enc_out = keras.layers.Dense(latent_space, activation="relu")(x)
encoder = keras.Model(enc_in, enc_out, name='encoder')

# Decoder Creation
decoder_in = keras.layers.Dense(latent_space, activation='relu')(enc_out)

# Additional decoder layers
x = keras.layers.Dense(colcount/16, activation='relu')(decoder_in)
x = keras.layers.Dense(colcount/4, activation='relu')(x)

x = keras.layers.Dense(colcount, activation='relu')(x)
decoder_out = keras.layers.Reshape((colcount,1))(x)

# Optimiser
optimise = tf.keras.optimizers.Adam()

# Model Creation
autoencoder = keras.Model(enc_in, decoder_out, name='autoencoder')

autoencoder.compile(optimise, loss='binary_crossentropy')
autoencoder.summary()

#Runs and creates the autoencoder and outputs parameters to a specs file
epochs = 4
batchsize = 128
for epoch in range(epochs):
    
    logs = autoencoder.fit(
    xtrain,
    xtrain,
    epochs=1,
    batch_size=batchsize, validation_split=0.2)
    

    if epoch > 2:
        autoencoder.save(str(f"/srv/scratch/z5363347/models/AE-{epoch+1}.model"))

#Gathers the accuracy, fp and tp rate of the autoencoder on a test set
ae_out = autoencoder.predict([ xtest.reshape(-1, colcount, 1) ])
test = ae_out.reshape(2649,colcount)

ids = 0
acc = []
fplist = []
tplist = []

for things in test:
    guesses = []
    testset = []
    
    loops = 0
    for items in xtest[ids]:
        if items != 0:
            testset.append(loops)
        loops = loops + 1
    
    loops = 0
    for items in test[ids]:
        if items > 0.5:
            guesses.append(loops)
        loops = loops + 1
        
    correct = 0
    loops = 0
    tp = 0
    fp = 0
    for items in guesses:
        if items in testset:
            correct = correct + 1
            tp = tp + 1
        else:
            fp = fp + 1
        loops = loops + 1
    
    accuracy = correct / loops
    tprate = tp / len(guesses)
    fprate = fp / len(guesses)
    
    acc.append(accuracy)
    tplist.append(tprate)
    fplist.append(fprate)
    
    ids = ids + 1

totalacc = 0
totaltp = 0
totalfp = 0

loops = 0
for items in acc:
    totalacc = totalacc + items
    loops = loops + 1
netacc = totalacc/loops

loops = 0
for items in tplist:
    totaltp = totaltp + items
    loops = loops + 1
nettp = totaltp/loops

loops = 0
for items in fplist:
    totalfp = totalfp + items
    loops = loops + 1
netfp = totalfp/loops
    
netacc = totalacc/loops
nettp = totaltp/loops
netfp = totalfp/loops

#Calculates fn and tn rate

ids = 0
tnlist = []
fnlist = []

for things in test:
    guesses = []
    testset = []
    
    loops = 0
    for items in xtest[ids]:
        if items != 1:
            testset.append(loops)
        loops = loops + 1
    
    loops = 0
    for items in test[ids]:
        if items < 0.5:
            guesses.append(loops)
        loops = loops + 1
        
    correct = 0
    loops = 0
    tn = 0
    fn = 0
    for items in guesses:
        if items in testset:
            correct = correct + 1
            tn = tn + 1
        else:
            fn = fn + 1
        loops = loops + 1
    
    tnrate = tn / len(guesses)
    fnrate = fn / len(guesses)
    
    tnlist.append(tprate)
    fnlist.append(fprate)
    
    ids = ids + 1

totaltn = 0
totalfn = 0

loops = 0
for items in tnlist:
    totaltn = totaltn + items
    loops = loops + 1
nettn = totaltn/loops

loops = 0
for items in fnlist:
    totalfn = totalfn + items
    loops = loops + 1
netfn = totalfn/loops
    
nettn = totaltn/loops
netfn = totalfn/loops

print('fn rate =', netfn)
print('tn rate =', nettn)
print('net accuracy =', netacc)
print('fp rate =', netfp)
print('tp rate =', nettp)
print("epochs =", epochs)
print('batchsize =', batchsize)  
print('latent_space size =', latent_space)