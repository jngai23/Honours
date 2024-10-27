#!/usr/bin/python3

import pandas
#Removes all rows without a PubChem CID
data = pandas.read_csv("processed_endo_data.csv")

df = data[data['PubChem CID'].notna()]


df.to_csv("rowremoved.csv", index=False)
