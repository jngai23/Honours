#!/usr/bin/python3
#31/3/24 
#Script to translate SMILE Pair Encoding output into useable data for ML algos
#Produces a dataframe where units are pattern counts per character per molecule
import os
import pandas
import csv
data_filename = "deepSMILEdata.csv"
data = pandas.read_csv(data_filename)
pattern_filename = "dspepatterns"
patterns = pandas.read_csv(pattern_filename, header=None)

patternlist = patterns.iloc[:, 0].tolist()

loops = 0

for items in patternlist:
    #Counts occurences of each SPE in data
    data_column_name = 'DeepSMILE'
    smilelist = data[data_column_name].tolist()
    countlist = [smile.count(items) for smile in smilelist]
    data[items] = countlist

    #String Size Normalisation (number of occurences of a pattern per character)
    patternlen = len(items)
    smileslenlist = [len(smile) for smile in smilelist]
    normsizelist = [patternlen/smilelen for smilelen in smileslenlist]

    loops = 0
    normlist = []
    for counts in countlist:
        normlist.append(counts*normsizelist[loops])
        loops = loops + 1
    
    data[items] = normlist

output = 'deepspedata.csv'
data.to_csv(output, index=False)