#!/bin/bash

flagsCount() {
	ans=0
	args=($1)
	for i in ${args[@]:1}
	do
		if [[ $i == --* ]]; then let ans++; fi 
	done
	echo "$ans"
}

max=0
ans=""
while IFS= read -r line;  
do 
	count=$(flagsCount "$line")
	#echo $count
	if (( "$max" < "$count" )); 
	then 
		max=$count
		ans=$line
	fi
done <<< $(ps -eo cmd)

echo "$ans" "$max"


