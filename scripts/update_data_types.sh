OLD_IFS=IFS
IFS=','

while read -r col1 col2
do
	echo "sed -i 's/${col1}/${col2}/g' TAB_NAME.sql" >> "dtype_repl.sh"
done < <(awk -F',' '{ print }' "$1")

chmod a+x "dtype_repl.sh"
