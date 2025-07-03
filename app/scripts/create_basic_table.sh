# !/bin/bash

# Takes a regular file path and create a SQL DDL script
#
IFS=';'

FILE_NAME="$1"

SQL_FILE="TAB_NAME.sql"

rm $SQL_FILE "dtype_repl.sh"

echo -e "DROP TABLE TAB_NAME;\n" > $SQL_FILE

echo "CREATE TABLE TAB_NAME (" >> $SQL_FILE

header=$(awk -F, 'NR==1 { print tolower($0) }' $FILE_NAME)

echo "$header" | tr ',' '\n' | sed 's/\://g' | sed 's/ /_/g'|while IFS=',' read -r f;do printf "%s varchar;\n" $f>>$SQL_FILE;done

echo -e ');' >> $SQL_FILE

sed -i 's/\(.*\)varchar;/\t\1varchar,/g' $SQL_FILE

lastColumn=$(awk -F',' 'NR==1 { print }' $FILE_NAME | tr ',' '\n'| tail -n 1 | sed 's/\://g' | sed 's/ /_/g')

lastColumn=$(echo $lastColumn | tr '[:upper:]' '[:lower:]')

line=$(grep -n $lastColumn TAB_NAME.sql)

lineno=$(echo $line | tr ':' '\n' | head -n 1)

search_string=$(echo $line | tr ':' '\n' | tail -n 1)

sed -i "${lineno}s/\,//g" $SQL_FILE

sed -i 's/\r//g' TAB_NAME.sql

chmod +x "TAB_NAME.sql"
