#!/usr/bin/env bash
#Input = List of SMILES
#Output = Drug Targets
#Scrapes Drugbank API to find all the targets of a list of SMILES

curl 'https://www.ebi.ac.uk/chembl/target-predictions' -H 'Content-Type: application/json' --data-raw '{"smiles":"Cc1ccc(Nc2nccc(N(C)c3ccc4c(C)n(C)nc4c3)n2)cc1S(N)(=O)=O"}' > temp.txt

