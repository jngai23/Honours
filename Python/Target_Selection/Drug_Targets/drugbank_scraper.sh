#!/usr/bin/env bash
#Input = List of SMILES
#Output = Drug Targets
#Scrapes Drugbank API to find all the targets of a list of SMILES

curl 'https://www.ebi.ac.uk/chembl/target-predictions' -H 'Content-Type: application/json' --data-raw '{"smiles":"CS(C)=O"}' > temp.txt

#python3 'targetextractor.py'