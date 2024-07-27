#Adds commas to spepatterns to make it viable as a .csv file and removes spaces
sed 's/$/,/' 'spepatterns' > 'temp'
sed  's/ //g' temp > spepatterns