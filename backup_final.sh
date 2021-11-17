#!/bin/sh

backup_tmp=/var/tmp		# temporaly directory for backup
backup_name=backup.`date +%F`	# name for backup
backup=/tmp/backup		# where to store backups
wtb=/etc			# what to backup
cr="-4"				# default compression ratio
keep="7"

	echo "Backup script"
	echo "-h for Help"

help()
{
	echo "Usage: backup.sh /what_to_backup"
	echo "Additional options:"
	echo "-d Directory which to backup. Default is" $wtb
	echo "-x Mask for eXclude eg. *.txt, *.jpg, etc"
	echo "-b where to store Backups. Default is" $backup
	echo "-v Verbose"
	echo "-c Compression ratio from -1 to -9 where -1 is worst and -9 is best. Default is" $cr
	echo "-k days to keep backups. Default is" $keep "for keeping" $keep "days"
	echo "-h for Help"
}

while getopts "d:x:b:vc:k:h" opt
do
	case $opt in
		d)
			if [ -z $opt ]
			then
				echo "Using default path to backup"
			else
				wtb=$OPTARG
				echo "Actual path to backup is:" $wtb
			fi						;;
		x)	
			if [ -z $opt ]
			then 
				echo "Dont Exclude files by mask"
			else
				mask=${OPTARG}
			fi						;;

		b)	if [ -z $opt ]
			then
				echo "Using default path for backups"
			else
				backup=$OPTARG
				echo "Actual path to store backup is:" $backup
			fi
									;;
		v)	
				set -o verbose
				echo "Verbose on"			;;
		c)	if [ -z $opt ]
			then
				echo "Using default compression" $cr
			else
				cr=$OPTARG				
				echo "User defined compression is" $cr
			fi						;;
		k)	if [ -z $opt ]
			then
				echo "Using default days to keep backups" $keep
			else
				keep=$OPTARG
				echo "User defined time to keep backups is" $keep
			fi;;
		h)
			help						
			exit 0						;;
	esac
done

# make temporaly directory for backup files
# check if exist
if ! [ -d $backup_tmp/$backup_name ] 
	then
		mkdir -p $backup_tmp/$backup_name
	else
		echo "Temporaly directory already exist"
fi

# list files to backup in loop and copy them to temporaly directory
for i in $wtb/*
	do 
		if [[ $i == ${mask} ]]
		then
			echo "User excluded this file" $i "from backup"
		else
			echo "I'll backup this file: " $i
			cp -pR $i $backup_tmp/$backup_name  
		fi
	done

# compress temporaly files to archive
tar -cf - $backup_tmp/$backup_name 2> /dev/null | gzip $cr > $backup/$backup_name.tar.gz
# delete temporaly files
rm -rf $backup_tmp/$backup_name

# delete old backups
find $backup/backup* -type f -mtime $keep -exec rm -rf {} \;

echo
echo "All done at:" `date`
