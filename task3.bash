#!/bin/bash

backupsPath=$PWD 			# path to all the backups	
backupRep="$backupsPath/backup-report"	# 
sourcePath="./source" 			# path to all sacred files 

datediff() {
	d1=$(date -d "$1" +%s)
   	d2=$(date -d "$2" +%s)
   	echo $(( (d1 - d2) / 86400 ))
}

inOldActive() {
#  Takes as input 
#+   $1 -- active backup directory 
#+   $2 -- the date

	activeBackDir="$1"
	theDate="$2"
	
	#* oldFilesMod --- a file to store names of old and modified files
	> oldFilesMod
	
	#* newFiles --- a file to store names of new files added to an active dir
	> newFiles
	
	for filePath in $sourcePath/* 
	do
		[ -f "$filePath" ] || continue
		fileName=$(basename "$filePath") #  $(echo "$filePath" | sed 's/.*\///')
		
		if [ -f "$activeBackDir/$fileName" ] 
			## file already exists in active dir
		then 
			if [ $(stat "$activeBackDir/$fileName" --format=%s) -ne $(stat "$filePath" --format=%s) ] 
			then
				cp "$filePath" "$activeBackDir/$fileName"
				cp "$filePath" "$activeBackDir/$fileName.$theDate" && echo -e "$file $fileName.$theDate" >> oldFilesMod;	
			fi		
		else	
		       	## file is NOT present in active dir
			cp "$filePath" "$activeBackDir/$fileName" && echo "$fileName" >> newFiles
		fi
	done	

	date > $backupRep
	cat newFiles >> "$backupRep"
       	cat oldFilesMod >> "$backupRep"	
}


newActive() {
# Takes as arguments 
#+  $1 -- new active backup directory
	activeDir="$1"
	mkdir "$activeDir"
	echo "$1"
	date > "$backupRep"
	for filePath in $sourcePath/* 
	do
		[ -f $filePath ] || continue
		fileName=$(basename "$filePath") #$(echo "$filePath" | sed 's/.*\///')
		echo $fileName
		cp "$filePath" "$activeDir/$fileName"
		echo "$fileName" >> "$backupRep"
	done
}

shopt -s nullglob
for dirPath in $backupsPath/BACKUP-* 
do
	dirName=$(basename "$dirpath")  #$(echo "$dirPath" | sed 's/.*\///')
	theDate=$(echo "$dirName" | sed 's/BACKUP-//')
	#echo "$theDate"

	#directory is considered active only if it's less then 7 days old
	datediff 'now' "$theDate"
	if [ $(datediff 'now' "$theDate") -lt 7 ]
	then
		echo "Found active!" ### debug 

		inOldActive "$dirPath" "$theDate"
		#  the active backup dir exists
	        #+ if the scipt is written correctly, there should never be > 1 active dir 
		#+ -> finish	
		exit 0;
	fi

done
shopt -u nullglob

# this is accessible only if active dir was not found
newActive "$backupsPath/BACKUP-$(date -d 'now' +%Y-%m-%d)"

