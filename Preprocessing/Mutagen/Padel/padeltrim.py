#!/usr/bin/python3
#Cuts empty columns from padel output file

import pandas as pd
import numpy as np

df = pd.read_csv('/Users/james/Documents/Honours/Data/structdata/Mutagen/Padel/padeloutmut.csv')    
df_cleaned = df.dropna(axis=1, how='all')
get_last_character = lambda x: x[-1]
df_cleaned['Name'] = df_cleaned['Name'].apply(get_last_character)
df_cleaned.to_csv('/Users/james/Documents/Honours/Data/structdata/Mutagen/Padel/mutagen_padel.csv', index=False)