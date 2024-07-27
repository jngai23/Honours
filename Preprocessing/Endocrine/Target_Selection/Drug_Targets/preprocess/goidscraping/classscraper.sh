#!/usr/bin/env bash
#Input = List of SMILES
#Output = Drug Targets
#Scrapes Drugbank API to find all the targets of a list of SMILES



curl 'https://www.ebi.ac.uk/chembl/api/data/protein_classification/CHEMBL4876' > temp.txt

