#!/bin/bash

# Takes as inputs a folder and creates 1) Create sql script 2)Reads the datatype from a template and updates the script 3)Create table 4)Copy the contents of the file into the table
PARENT_DIR=""

while read -r f
do
	line=$(grep "$f" "datatype_templates/flags_lags.csv" | tr ',' '|' | awk -F'|' '{ print $2 }')

	echo "TAB_NAME,$line" > "datatype_templates/flags_lags/$f"
	echo "Entry_Date varchar,Entry_Date date" >> "datatype_templates/flags_lags/$f"
	echo "RefID varchar,RefID numeric" >> "datatype_templates/flags_lags/$f"
	echo "Choke varchar,Choke float" >> "datatype_templates/flags_lags/$f"
	echo "FlowingTubingPressure varchar,FlowingTubingPressure numeric(8, 2)" >> "datatype_templates/flags_lags/$f"
	echo "CasingPressure varchar,CasingPressure numeric(8, 2)" >> "datatype_templates/flags_lags/$f"
	echo "LinePressure varchar,LinePressure numeric(8, 2)" >> "datatype_templates/flags_lags/$f"
	echo "AllocatedGasInjectionVolume varchar,AllocatedGasInjectionVolume numeric(8, 2)" >> "datatype_templates/flags_lags/$f"

	source "$SCRIPTS_DIR/create_basic_table.sh" "$PARENT_DIR/$f"

	sed -i 's/\r//g' TAB_NAME.sql

	source "$SCRIPTS_DIR/update_data_types.sh" "$HOME/datatype_templates/flags_lags/$f"

	source "dtype_repl.sh"

	#cp TAB_NAME.sql "$SCRIPTS_DIR/flags_lags/$tab_name.sql"

	#while read -r col1 col2
	#do
        #  sed -i 's/${col1}/${col2}/g' "$SCRIPTS_DIR/flags_lags/$tab_name.sql"
	#done < <(awk -F',' '{ print }' "$HOME/datatype_templates/flags_lags/$f")
	
	tab_name=$(grep "$f" "datatype_templates/flags_lags.csv" | tr ',' '|' | awk -F'|' '{ print $2 }')

	PGPASSWORD=avon123 psql -U $1 -d $2 --file="TAB_NAME.sql"
	
	PGPASSWORD=avon123 psql -U $1 -d $2 -c "\copy $tab_name FROM '$PARENT_DIR/$f' WITH DELIMITER ',' CSV HEADER;"

	WELL_NAME=$(echo $f | sed 's/ _Selected_Flags_Lags.csv//g')

	PGPASSWORD=avon123 psql -U $1 -d $2 -c "SELECT * FROM createUpdatedLPTab('$tab_name', '$WELL_NAME');"

	savedTabName=$(echo $tab_name | sed 's/lp_joined_1\.//g')

	echo "linepressure.$savedTabName"
	
#	PGPASSWORD=avon123 psql -U $1 -d $2 -c "\copy linepressure.$savedTabName TO '$DATA_DIR/line_pressure_results/$f' WITH DELIMITER ',' CSV HEADER;"
	
	rm "dtype_repl.sh"

done < <(ls $PARENT_DIR)

