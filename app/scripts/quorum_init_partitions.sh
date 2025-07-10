# !/bin/bash

chmod +x "$SCRIPTS_DIR/create_quorum_partitioned_table.sh"

source "$SCRIPTS_DIR/create_quorum_partitioned_table.sh"

source "$SCRIPTS_DIR/update_data_types.sh" "$HOME/datatype_templates/quorum_datatypes.csv"

source "dtype_repl.sh"

PGPASSWORD=$1 psql -U $2 -d $3 --file="TAB_NAME.sql"

PGPASSWORD=$1 psql -U $2 -d $3 --file="$SCRIPTS_DIR/quorum_create_partitions.sql"

PGPASSWORD=$1 psql -U $2 -d $3 --file="$HOME/20250708_3pressure_fillin.sql"
