#!/usr/bin/python
import re
import subprocess


command = "curl \'https://www.ebi.ac.uk/chembl/target-predictions\' -H \'Content-Type: application/json\' --data-raw \'{\"smiles\":\"C[S+](C)[O-]\"}\' > temp.txt"
print(command)
subprocess.Popen(command, shell=True)

with open('temp.txt', 'r') as input:
    contents = input.read()

datalist = re.findall(r'\{([^}]*)\}', contents)
print(len(datalist))
#valid_targets = []

#for items in datalist:
exit()