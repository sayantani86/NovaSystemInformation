# !/bin/bash

WELLNAME=$1

cat <<EOF > "$SCRIPTS_DIR/Quorum/$WELLNAME.sh"

PGPASSWORD=avon123 psql -U \$1 -d \$2 -c "CREATE TABLE quorum_whatif.$WELLNAME AS (SELECT * FROM getRangedDataFromQuorumByWell('$WELLNAME', '\$3', '\$4'));"

PGPASSWORD=avon123 psql -U \$1 -d \$2 -c "\copy quorum_whatif.$WELLNAME TO '$DATA_DIR/assets/quorum_whatif/results.csv' WITH DELIMITER ',' CSV HEADER;" -c "DROP TABLE IF EXISTS quorum_whatif.$WELLNAME;"

EOF
chmod +x "$SCRIPTS_DIR/Quorum/$WELLNAME.sh"
