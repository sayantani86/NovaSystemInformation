# !/bin/bash

WELLNAME=$1

cat <<EOF > "$SCRIPTS_DIR/PatchIQ/WELL_FILES_WEEKLY/$WELLNAME.sh"

PGPASSWORD=avon123 psql -U \$1 -d \$2 -c "DROP TABLE ironiq_whatif.$WELLNAME;" -c "CREATE TABLE ironiq_whatif.$WELLNAME AS (SELECT t.*, iq.point_name, iq.equipment, iq.parent_equipment_name, iq.equipment_type FROM getRangedDataFromIronIQByWell('$WELLNAME', '\$3', '\$4') t LEFT OUTER JOIN iqranger_equipment_lookup iq ON t.id::int=iq.item_id::int);"

PGPASSWORD=avon123 psql -U \$1 -d \$2 -c "\copy ironiq_whatif.$WELLNAME TO '$DATA_DIR/ironiq_whatif_inputs/results1.csv' WITH DELIMITER ',' CSV HEADER;"

#PGPASSWORD=avon123 psql -U \$1 -d \$2  -c "SELECT * FROM getRangedDataFromIronIQByWell('$WELLNAME', '\$3', '\$4') t"
EOF
chmod +x "$SCRIPTS_DIR/PatchIQ/WELL_FILES_WEEKLY/$WELLNAME.sh"
