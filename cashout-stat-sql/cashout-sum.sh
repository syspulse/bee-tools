TMP=/tmp/SUM.tmp
sum="0.0"
grep -v "^$" | awk -F'|' '{v="0x" substr($6,76,64); print v}' | xargs -I@ printf "%s %d\\n" @ @ | while read line 
do
    value=`echo $line| awk '{print "scale=7;",$2, "/ 10000000000000000.0" }' | bc`
    sum="$sum + $value"
    #echo -en "${line}: $value: $sum\n"
    >&2 echo -en "${line}: $value\n"
    if (( "${#sum}" > 1024 )); then
        sum=`echo "scale=7; $sum" | bc`
    fi
    echo "$sum" >$TMP
done
sum=`cat $TMP`
#echo "Last: $sum"
sum=`echo "scale=7; $sum" | bc`
echo $sum