#!/usr/bin/python3
#Adds a 'Toxicity_Value' column to a given file
import os
import pandas
import csv

data = pandas.read_csv("padel_out.csv")

data['Toxicity_Value'] = data.iloc[:, 0].str[-1:]
data.to_csv('padel_out_tox.csv', index=False)
