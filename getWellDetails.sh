#WELLNAME=$(echo $3 | sed s'/\s\+//g' | sed s'/#//g' | sed s'/-//g' )

WELLNAME="w_"$(echo $3 | sed 's/.01/01/g')

PGPASSWORD="avon123" psql -U $1 -d $2 -c "DROP TABLE maps.$WELLNAME" -c "CREATE TABLE maps.$WELLNAME AS (SELECT * FROM getWellDetails('$3'));"

PGPASSWORD="avon123" psql -U $1 -d $2 -c "\copy maps.$WELLNAME TO '$DATA_DIR/assets/wells/results.csv' WITH DELIMITER ',' CSV HEADER;"

