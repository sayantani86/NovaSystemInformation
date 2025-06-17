# !/bin/bash

WELLNAME=$1

cat <<EOF > "$SCRIPTS_DIR/Quorum/$2.sh"

PGPASSWORD=avon123 psql -h 172.30.2.104 -U \$1 -d \$2 -c "SELECT * FROM getRangedDataFromQuorumByWell('$WELLNAME', $2, '\$3', '\$4');"

PGPASSWORD=avon123 psql -h 172.30.2.104  -U \$1 -d \$2 -c "\copy quorum_whatif.w_$2 TO '$DATA_DIR/assets/quorum_whatif/results.csv' WITH DELIMITER ',' CSV HEADER;" -c "DROP TABLE IF EXISTS quorum_whatif.w_$2;"

EOF
chmod +x "$SCRIPTS_DIR/Quorum/$2.sh"
