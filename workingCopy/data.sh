for file in *.json; do
  sed -i '1i <data>' "$file" && #adds data tag to the beginning of JSON file
  echo '</data>' >> "$file" && ## echos data tag at end of JSON file 
  ls "$file" >> data_tag_only.txt 
done ##creates a log of all files written to then closes