line_start=$(grep -n "f1" $1 | tr ":" "\n" | head -n 1)

total_lines=$(grep -nw "rows" $1 | tr ":" "\n" | tail -n 1 | grep -E -o "[0-9]+")

line_end=`echo $((line_start + total_lines + 1))`

sed -n "$((line_start + 2)),${line_end}p" $1

#rm results.csv

#sed -n "$line_start,${line_end}p" "results.txt" > results.csv

