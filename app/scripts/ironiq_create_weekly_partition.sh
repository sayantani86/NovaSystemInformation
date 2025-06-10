
chmod +x $SCRIPTS_DIR/create_ironiq_partitioned_table.sh

source $SCRIPTS_DIR/create_ironiq_partitioned_table.sh

source $SCRIPTS_DIR/update_data_types.sh "ironiq_datatypes.csv"

source "dtype_repl.sh"

PGPASSWORD=$1 psql -U $2 -d $3 -f "TAB_NAME.sql"

PGPASSWORD=$1 psql -U $2 -d $3 --file="$SCRIPTS_DIR/ironiq_lookup_weekly.sql" 

PGPASSWORD=$1 psql -U $2 -d $3 -c "\COPY ironiq_lookup_weekly(file_size, part_file_name) FROM '$SCRIPTS_DIR/ironiq_part_names.csv' WITH DELIMITER ' ' CSV;"

PGPASSWORD=$1 psql -U $2 -d $3 -c "UPDATE ironiq_lookup_weekly SET start_date=(regexp_match((regexp_split_to_array(regexp_replace(regexp_replace(part_file_name, '.csv', ''), '-00-00_000', ''), '_to_'))[1], '\d\d\d\d-\d\d-\d+'))[1]::date, end_date=(regexp_match((regexp_split_to_array(regexp_replace(regexp_replace(part_file_name, '.csv', ''), '-00-00_000', ''), '_to_'))[2], '\d\d\d\d-\d\d-\d+'))[1]::date WHERE start_date IS NULL;"

PGPASSWORD=$1 psql -U $2 -d $3 --file="$SCRIPTS_DIR/ironiq_insert_partitions.sql" 

PGPASSWORD=$1 psql -U $2 -d $3 --file="$SCRIPTS_DIR/IRONIQ_PARTS.sql"

