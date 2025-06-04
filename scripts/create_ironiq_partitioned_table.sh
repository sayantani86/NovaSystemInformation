# !/bin/bash

FILES_DIR="$HOME/data/PatchIQ"

old_IFS=IFS

IFS=','

SQL_FILE="TAB_NAME.sql"

rm $SQL_FILE
rm "dtype_repl.sh"

echo -e "DROP TABLE TAB_NAME;\n" > $SQL_FILE

echo "CREATE TABLE TAB_NAME (" >> $SQL_FILE

header=$(cat $FILES_DIR/$(ls "$FILES_DIR" | sort | head -n 1) | awk -F',' 'NR==1 { print }')

printf "\t%b varchar,\n" $header >> $SQL_FILE 

echo -e ') PARTITION BY RANGE (COL_NAME);\n' >> $SQL_FILE

#printf "\n" >> "quorum_production_data.sql"

echo -e 'CREATE INDEX ON TAB_NAME (COL_NAME);\n\n' >> $SQL_FILE

lastColumn=$(awk -F',' 'NR==1 { print }' $FILES_DIR/$(ls $FILES_DIR | sort | head -n 1) | tr ',' '\n'| tail -n 1)

line=$(grep -n $lastColumn TAB_NAME.sql)

lineno=$(echo $line | tr ':' '\n' | head -n 1)
search_string=$(echo $line | tr ':' '\n' | tail -n 1)

sed -i "${lineno}s/\,//g" $SQL_FILE

#printf "\n" >> "quorum_production_data.sql"

#lastColumn=$(grep -n `awk -F',' 'NR==1 { print }' data/PatchIQ/$(ls "data/PatchIQ" | sort | head -n 1) | tr ',' '\n' | tail -n 1` "TAB_NAME.sql")

# Replace delimiter from last field in SQL

#lineno=$(echo $lastColumn | tr ':' '\n' | head -n 1)

#search_string=$(echo $lastColumn | tr ':' '\n' | tail -n 1)

#new_string=$(echo $search_string | sed 's/\,//g')

#echo "sed -i 's/${search_string}/${new_string}/g' TAB_NAME.sql" >> "dtype_repl.sh"

chmod +x $SQL_FILE
