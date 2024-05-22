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
latent_space = colcount/81
keras.utils.set_random_seed(81)
tf.config.experimental.enable_op_determinism()

# Encoder Creation
enc_in = keras.Input(shape=(colcount, 1))
x = keras.layers.Flatten()(enc_in)

# Additional encoder layers
x = keras.layers.Dense(colcount/3, activation="relu")(x)
x = keras.layers.Dense(colcount/9, activation="relu")(x)
x = keras.layers.Dense(colcount/27, activation="relu")(x)

enc_out = keras.layers.Dense(latent_space, activation="relu")(x)
encoder = keras.Model(enc_in, enc_out, name='encoder')

# Decoder Creation
decoder_in = keras.layers.Dense(latent_space, activation='relu')(enc_out)

# Additional decoder layers
x = keras.layers.Dense(colcount/27, activation='relu')(decoder_in)
x = keras.layers.Dense(colcount/9, activation='relu')(x)
x = keras.layers.Dense(colcount/3, activation='relu')(x)

x = keras.layers.Dense(colcount, activation='relu')(x)
decoder_out = keras.layers.Reshape((colcount,1))(x)

# Optimiser
optimise = tf.keras.optimizers.Adam()

# Model Creation
autoencoder = keras.Model(enc_in, decoder_out, name='autoencoder')

autoencoder.compile(optimise, loss='binary_crossentropy')
autoencoder.summary()

#Runs and creates the autoencoder and outputs parameters to a specs file
epochs = 8
batchsize = 128
for epoch in range(epochs):
    logs = autoencoder.fit(
    xtrain,
    xtrain,
    epochs=1,
    batch_size=batchsize, validation_split=0.2)
    
    if epoch > 5:
        autoencoder.save(str(f"/srv/scratch/z5363347/models/{epoch+1}.model"))