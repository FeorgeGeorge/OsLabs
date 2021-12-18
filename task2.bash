#!/bin/bash

TRASH=.trash

while read -u 10 line
do
	IFS=' ' read -r id filePath <<< "$line" # does not support spaces in filePath
	
	#IFS='/' arr=($filePath)
	#echo "$filePath"
	
	fileName=$(basename "$filePath") #${arr[-1]}
	[ -f "$TRASH/$id" ] || { echo "This file is not present in the trashcan"; continue; }
	if [ $fileName = "$1" ]
	then
	       	echo "Would you like to recover $1? [y/n]"
		read answer
		if [[ "$answer" == y || "$answer" == Y ]]
		then
			if [ -d "$(dirname "$filePath")"] 
			then
				filePath=.
				echo "Directory has been lost. Redirecting to home directory (PWD)"
			fi

			{ ln "./$TRASH/$id" "$filePath" && rm -f "./$TRASH/$id"; } || {
				echo "File with this name already exists. Would you like to rename the recovered file [y/n]?"
				read ans
				if [ "$ans" = y ]
				then	
					echo "Enter the new name"
					read name
					ln "./$TRASH/$id" "./$name" && rm -f "./$TRASH/$id"
				fi
			} || echo "Could not recover file. Probably, it is absent in the trashcan."	
		fi	
	fi
done 10<trash.log;	
