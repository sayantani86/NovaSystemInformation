WELLNAME=$3

WELLNAME=$(echo $WELLNAME | sed s'/\s\+//g' | sed s'/#//g' | sed s'/-//g' )

source "$SCRIPTS_DIR/searchWellInQuorum.sh" $1 $2 $WELLNAME

status=$?

if [ $status -eq 0 ]; then
        if ! [ -f "$SCRIPTS_DIR/Quorum/$WELLNAME.sh" ]; then
                source "$SCRIPTS_DIR/quorum_getWhatIfInputs.sh" $WELLNAME
        fi
fi

# $1 -> database user
# $2 -> database
# $4 -> start_date
# $5 -> end_date
#
source "$SCRIPTS_DIR/Quorum/$WELLNAME.sh" $1 $2 $4 $5
