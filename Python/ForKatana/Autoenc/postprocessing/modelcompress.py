#20/5/24 Compresses a keras model using tensorflowlite
#Does not work due to size restraints
#Outputs the model and a text file

import pandas as pd
import numpy as np
#Data import

import tensorflow as tf
from tensorflow import keras
import os

autoencoder = keras.models.load_model('/srv/scratch/z5363347/models/AE-4.model')

#Post Training Quantization
converter = tf.lite.TFLiteConverter.from_keras_model(autoencoder)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
quant_model = converter.convert()

with open(str(f"/srv/scratch/z5363347/models/compressed/AE-4.model"), 'wb') as f:
    f.write(quant_model)