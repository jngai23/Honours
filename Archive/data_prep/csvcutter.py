#!/usr/bin/python3
#Removes duplicates from a given csv file
import csv
import sys

file = open("bing.csv", "w")
writer = csv.writer(file)
for row in csv.reader(open("dupe_removed.csv")):
    writer.writerow(row[3:5])


