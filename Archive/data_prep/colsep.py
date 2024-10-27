#!/usr/bin/python3
#Trims a Toxric .csv file to keep only SMILES, CiD and toxicity values
import pandas

data = pandas.read_csv("processed_endo_data.csv")


removal = ["TAID","Name","IUPAC Name","PubChem_CID","InChIKey"]

data = data.drop(columns=removal)

data.to_csv("rdkit_data.csv", index=False)
