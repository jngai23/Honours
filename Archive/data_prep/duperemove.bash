#!/bin/bash
#Removes duplicates within Toxric data
cd ..
cd Toxric_Endocrine_Data
rm "fieldremoved.csv"
rm "tester.csv"
sed 's/,,/, . ,/' "dupe_removed.csv" > "tester.csv"
cut -d "," -f 3,4 "tester.csv" > "fieldremoved.csv" 
#4,5,7
