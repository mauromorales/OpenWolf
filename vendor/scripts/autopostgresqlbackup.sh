#!/bin/bash
#
# PostgreSQL Backup Script
# Based on VER. 2.5 of http://sourceforge.net/projects/automysqlbackup/
# Copyright (c) 2002-2003 wipe_out@lycos.co.uk
# Copyright (c) 2007 roy_walker@hotmail.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#=====================================================================

# Username to access the PostgreSQL server e.g. dbuser
USERNAME=openwolf

# Host name (or IP address) of PostgreSQL server e.g. localhost
# This can also be a socket path e.g. /tmp/.s.PGSQL.5432
DBHOST=localhost

# List of DBNAMES for Daily/Weekly Backup e.g. "DB1 DB2 DB3" or "all"
# ** NOTE: "all" will put all databases in one large dump file **
DBNAMES="openwolf_development"

# Backup directory location e.g /backups
BACKUPDIR="~/backups"

# Mail setup
# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and sql files as attachments (see docs)
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
MAILCONTENT="stdout"

# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
MAXATTSIZE="4000"

# Email Address to send mail to? (user@domain.com)
MAILADDR="jalvarezsamayoa@gmail.com"


# ============================================================
# === ADVANCED OPTIONS ( Read the doc's below for details )===
#=============================================================

# Options to Vacuum before running the backup
# 0 : Do not perform any Vacuum functions
# 1 : Vacuum only (Default)
# 2 : Vacuum and Analyze
# 3 : Do a Full Vacuum and Analyze *Note* This can take a long time.
VACUUM=1

# List of DBBNAMES for Monthly Backups.  See notes below....
MDBNAMES="postgres $DBNAMES"

# Include CREATE DATABASE commands in backup?
CREATE_DATABASE=yes

# Include OIDS in the dump (if you don't what this is say no)
DUMP_OIDS=no

# Which day do you want weekly backups? (1 to 7 where 1 is Monday)
DOWEEKLY=6

# Choose Compression type. (gzip or bzip2)
COMP=gzip

# Additionally keep a copy of the most recent backup in a seperate directory.
LATEST=no

# Command to run before backups (uncomment to use)
#PREBACKUP="/etc/postgresql-backup-pre"

# Command run after backups (uncomment to use)
#POSTBACKUP="/etc/postgresql-backup-post"

#=====================================================================
# Options documantation
#=====================================================================
# Set USERNAME to a user that has at least SELECT permission
# to ALL databases.
#
# If you need to supply a password to connect to the database, you may set the
# .pgpass file in the home directory of the user that runs this script.  Please
# see http://www.postgresql.org/docs/8.2/interactive/libpq-pgpass.html.
#
# Set the DBHOST option to the server you wish to backup, leave the
# default to backup "this server".(to backup multiple servers make
# copies of this file and set the options for that server)
#
# Put in the list of DBNAMES(Databases)to be backed up. If you would like
# to backup ALL DBs on the server set DBNAMES="all".(if set to "all" then
# any new DBs will automatically be backed up without needing to modify
# this backup script when a new DB is created).
#
# If the DB you want to backup has a space in the name replace the space
# with a % e.g. "data base" will become "data%base"
# NOTE: Spaces in DB names may not work correctly when SEPDIR=no.
#
# You can change the backup storage location from /backups to anything
# you like by using the BACKUPDIR setting..
#
# The MAILCONTENT and MAILADDR options and pretty self explanitory, use
# these to have the backup log mailed to you at any email address or multiple
# email addresses in a space seperated list.
# (If you set mail content to "log" you will require access to the "mail" program
# on your server. If you set this to "files" you will have to have mutt installed
# on your server. If you set it to "stdout" it will log to the screen if run from 
# the console or to the cron job owner if run through cron. If you set it to "quiet"
# logs will only be mailed if there are errors reported. )
#
# MAXATTSIZE sets the largest allowed email attachments total (all backup files) you
# want the script to send. This is the size before it is encoded to be sent as an email
# so if your mail server will allow a maximum mail size of 5MB I would suggest setting
# MAXATTSIZE to be 25% smaller than that so a setting of 4000 would probably be fine.
#
# Finally copy autopostgresbackup.sh to anywhere on your server and make sure
# to set executable permission. You can also copy the script to
# /etc/cron.daily to have it execute automatically every night or simply
# place a symlink in /etc/cron.daily to the file if you wish to keep it 
# somwhere else.
# NOTE:On Debian copy the file with no extention for it to be run
# by cron e.g just name the file "autopostgresbackup"
#
# Thats it..
#
#
# === Advanced options doc's ===
#
# The list of MDBNAMES is the DB's to be backed up only monthly. You should
# always include "postgres" in this list to backup your user/password
# information along with any other DBs that you only feel need to
# be backed up monthly. (if using a hosted server then you should
# probably remove "postgres" as your provider will be backing this up)
# NOTE: If DBNAMES="all" then MDBNAMES has no effect as all DBs will be backed
# up anyway.
#
# If you set DBNAMES="all" you can configure the option DBEXCLUDE. Other
# wise this option will not be used.
# This option can be used if you want to backup all dbs, but you want 
# exclude some of them. (eg. a db is to big).
#
# Set CREATE_DATABASE to "yes" (the default) if you want your SQL-Dump to create
# a database with the same name as the original database when restoring.
# Saying "no" here will allow your to specify the database name you want to
# restore your dump into, making a copy of the database by using the dump
# created with autopostgresbackup.
#
# To set the day of the week that you would like the weekly backup to happen
# set the DOWEEKLY setting, this can be a value from 1 to 7 where 1 is Monday,
# The default is 6 which means that weekly backups are done on a Saturday.
#
# COMP is used to choose the copmression used, options are gzip or bzip2.
# bzip2 will produce slightly smaller files but is more processor intensive so
# may take longer to complete.
#
# LATEST is to store an additional copy of the latest backup to a standard
# location so it can be downloaded bt thrid party scripts.
#
# Use PREBACKUP and POSTBACKUP to specify Per and Post backup commands
# or scripts to perform tasks either before or after the backup process.
#
#=====================================================================
# Backup Rotation..
#=====================================================================
#
# Daily Backups are rotated weekly..
# Weekly Backups are run by default on Saturday Morning when
# cron.daily scripts are run...Can be changed with DOWEEKLY setting..
# Weekly Backups are rotated on a 5 week cycle..
# Monthly Backups are run on the 1st of the month..
# Monthly Backups are NOT rotated automatically...
# It may be a good idea to copy Monthly backups offline or to another
# server..
#
#=====================================================================
# Please Note!!
#=====================================================================
#
# I take no resposibility for any data loss or corruption when using
# this script..
# This script will not help in the event of a hard drive crash. If a 
# copy of the backup has not be stored offline or on another PC..
# You should copy your backups offline regularly for best protection.
#
# Happy backing up...
#
#=====================================================================
# Restoring
#=====================================================================
# Firstly you will need to uncompress the backup file.
# eg.
# gunzip file.gz (or bunzip2 file.bz2)
#
# Next you will need to use the postgresql client to restore the DB from the
# sql file.
# eg.
# psql --user=username --pass --host=dbserver database < /path/file.sql
# or
# psql --user=username --pass --host=dbserver -e "source /path/file.sql" database
#
# NOTE: Make sure you use "<" and not ">" in the above command because
# you are piping the file.sql to postgres and not the other way around.
#
# Lets hope you never have to use this.. :)
#
#=====================================================================
# Change Log
#=====================================================================
#
# VER 1.0 - (2007-07-10)
#		First release based automysqlbackup 2.5.
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/pgsql/bin 
DATE=`date +%Y-%m-%d_%Hh%Mm`				# Datestamp e.g 2002-09-21
DOW=`date +%A`							# Day of the week e.g. Monday
DNOW=`date +%u`						# Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`							# Date of the Month e.g. 27
M=`date +%B`							# Month e.g January
W=`date +%V`							# Week Number e.g 37
VER=2.5									# Version Number
LOGFILE=$BACKUPDIR/$DBHOST-`date +%N`.log		# Logfile Name
LOGERR=$BACKUPDIR/ERRORS_$DBHOST-`date +%N`.log		# Logfile Name
BACKUPFILES=""

# Create required directories
if [ ! -e "$BACKUPDIR" ]		# Check Backup Directory exists.
	then
	mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/daily" ]		# Check Daily Directory exists.
	then
	mkdir -p "$BACKUPDIR/daily"
fi

if [ ! -e "$BACKUPDIR/weekly" ]		# Check Weekly Directory exists.
	then
	mkdir -p "$BACKUPDIR/weekly"
fi

if [ ! -e "$BACKUPDIR/monthly" ]	# Check Monthly Directory exists.
	then
	mkdir -p "$BACKUPDIR/monthly"
fi

if [ "$LATEST" = "yes" ]
then
	if [ ! -e "$BACKUPDIR/latest" ]	# Check Latest Directory exists.
	then
		mkdir -p "$BACKUPDIR/latest"
	fi
eval rm -fv "$BACKUPDIR/latest/*"
fi

# IO redirection for logging.
touch $LOGFILE
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec > $LOGFILE     # stdout replaced with file $LOGFILE.
touch $LOGERR
exec 7>&2           # Link file descriptor #7 with stderr.
                    # Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.

if [ "$VACUUM" = "2" ]; then
VACUUM_OPT="--analyze"
elif [ "$VACUUM" = "3" ]; then
VACUUM_OPT="--analyze --full"
fi

if [ "$CREATE_DATABASE" = "yes" ]; then
	if [ "$DBNAMES" != "all" ]; then
		OPT="$OPT --create"
	fi
fi

if [ "$DUMP_OIDS" = "yes" ]; then
OPT="$OPT --oids"
fi

# Functions

# Database dump function
dbdump () {
if [ "$VACUUM" != "0" ]; then
vacuumdb --user=$USERNAME --host=$DBHOST --quiet $VACUUM_OPT $1
fi
pg_dump --user=$USERNAME --host=$DBHOST $OPT $1 > $2
return 0
}

# Database dump all function
dbdumpall () {
if [ "$VACUUM" != "0" ]; then
vacuumdb --user=$USERNAME --host=$DBHOST --quiet --all $VACUUM_OPT
fi
pg_dumpall --user=$USERNAME --host=$DBHOST $OPT > $1
return 0
}

# Compression function plus latest copy
SUFFIX=""
compression () {
if [ "$COMP" = "gzip" ]; then
	gzip -f "$1"
	echo
	echo Backup Information for "$1"
	gzip -l "$1.gz"
	SUFFIX=".gz"
elif [ "$COMP" = "bzip2" ]; then
	echo Compression information for "$1.bz2"
	bzip2 -f -v $1 2>&1
	SUFFIX=".bz2"
else
	echo "No compression option set, check advanced settings"
fi
if [ "$LATEST" = "yes" ]; then
	cp $1$SUFFIX "$BACKUPDIR/latest/"
fi	
return 0
}


# Run command before we begin
if [ "$PREBACKUP" ]
	then
	echo ======================================================================
	echo "Prebackup command output."
	echo
	eval $PREBACKUP
	echo
	echo ======================================================================
	echo
fi

# Hostname for LOG information
if [ "$DBHOST" = "localhost" ]; then
	HOST=`hostname`
else
	HOST=$DBHOST
fi

echo ======================================================================
echo AutoPostgresBackup VER $VER
echo http://sourceforge.net/projects/automysqlbackup/
echo 
echo Backup of Database Server - $HOST
echo ======================================================================

# Test if seperate DB backups are required
if [ "$DBNAMES" != "all" ]; then
echo Backup Start Time `date`
echo ======================================================================
	# Monthly Full Backup of all Databases
	if [ $DOM = "01" ]; then
		for MDB in $MDBNAMES
		do
 
			 # Prepare $DB for using
		        MDB="`echo $MDB | sed 's/%/ /g'`"

			if [ ! -e "$BACKUPDIR/monthly/$MDB" ]		# Check Monthly DB Directory exists.
			then
				mkdir -p "$BACKUPDIR/monthly/$MDB"
			fi
			echo Monthly Backup of $MDB...
				dbdump "$MDB" "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql"
				compression "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql"
				BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql$SUFFIX"
			echo ----------------------------------------------------------------------
		done
	fi

	for DB in $DBNAMES
	do
	# Prepare $DB for using
	DB="`echo $DB | sed 's/%/ /g'`"
	
	# Create Seperate directory for each DB
	if [ ! -e "$BACKUPDIR/daily/$DB" ]		# Check Daily DB Directory exists.
		then
		mkdir -p "$BACKUPDIR/daily/$DB"
	fi
	
	if [ ! -e "$BACKUPDIR/weekly/$DB" ]		# Check Weekly DB Directory exists.
		then
		mkdir -p "$BACKUPDIR/weekly/$DB"
	fi
	
	# Weekly Backup
	if [ $DNOW = $DOWEEKLY ]; then
		echo Weekly Backup of Database \( $DB \)
		echo Rotating 5 weeks Backups...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$BACKUPDIR/weekly/$DB_week.$REMW.*" 
		echo
			dbdump "$DB" "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql"
			compression "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	
	# Daily Backup
	else
		echo Daily Backup of Database \( $DB \)
		echo Rotating last weeks Backup...
		eval rm -fv "$BACKUPDIR/daily/$DB/*.$DOW.sql.*" 
		echo
			dbdump "$DB" "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql"
			compression "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi
	done
echo Backup End `date`
echo ======================================================================


else # One backup file for all DBs
echo Backup Start `date`
echo ======================================================================
	# Monthly Full Backup of all Databases
	if [ $DOM = "01" ]; then
		echo Monthly full Backup of all databases...
			dbdumpall "$BACKUPDIR/monthly/$DATE.$M.all-databases.sql"
			compression "$BACKUPDIR/monthly/$DATE.$M.all-databases.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$DATE.$M.all-databases.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi

	# Weekly Backup
	if [ $DNOW = $DOWEEKLY ]; then
		echo Weekly Backup of All Databases
		echo
		echo Rotating 5 weeks Backups...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$BACKUPDIR/weekly/week.$REMW.*" 
		echo
			dbdumpall "$BACKUPDIR/weekly/week.$W.$DATE.sql"
			compression "$BACKUPDIR/weekly/week.$W.$DATE.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/week.$W.$DATE.sql$SUFFIX"
		echo ----------------------------------------------------------------------
		
	# Daily Backup
	else
		echo Daily Backup of All Databases
		echo
		echo Rotating last weeks Backup...
		eval rm -fv "$BACKUPDIR/daily/*.$DOW.sql.*" 
		echo
			dbdumpall "$BACKUPDIR/daily/$DATE.$DOW.sql"
			compression "$BACKUPDIR/daily/$DATE.$DOW.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DATE.$DOW.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi
echo Backup End Time `date`
echo ======================================================================
fi
echo Total disk space used for backup storage..
echo Size - Location
echo `du -hs "$BACKUPDIR"`
echo
echo ======================================================================
echo If you find AutoPostgresBackup valuable please make a donation at
echo http://sourceforge.net/project/project_donations.php?group_id=101066
echo ======================================================================

# Run command when we're done
if [ "$POSTBACKUP" ]
	then
	echo ======================================================================
	echo "Postbackup command output."
	echo
	eval $POSTBACKUP
	echo
	echo ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "$MAILCONTENT" = "files" ]
then
	if [ -s "$LOGERR" ]
	then
		# Include error log if is larger than zero.
		BACKUPFILES="$BACKUPFILES $LOGERR"
		ERRORNOTE="WARNING: Error Reported - "
	fi
	#Get backup size
	ATTSIZE=`du -c $BACKUPFILES | grep "[[:digit:][:space:]]total$" |sed s/\s*total//`
	if [ $MAXATTSIZE -ge $ATTSIZE ]
	then
		BACKUPFILES=`echo "$BACKUPFILES" | sed -e "s# # -a #g"`	#enable multiple attachments
		mutt -s "$ERRORNOTE PostgreSQL Backup Log and SQL Files for $HOST - $DATE" $BACKUPFILES $MAILADDR < $LOGFILE		#send via mutt
	else
		cat "$LOGFILE" | mail -s "WARNING! - PostgreSQL Backup exceeds set maximum attachment size on $HOST - $DATE" $MAILADDR
	fi
elif [ "$MAILCONTENT" = "log" ]
then
	cat "$LOGFILE" | mail -s "PostgreSQL Backup Log for $HOST - $DATE" $MAILADDR
	if [ -s "$LOGERR" ]
		then
			cat "$LOGERR" | mail -s "ERRORS REPORTED: PostgreSQL Backup error Log for $HOST - $DATE" $MAILADDR
	fi	
elif [ "$MAILCONTENT" = "quiet" ]
then
	if [ -s "$LOGERR" ]
		then
			cat "$LOGERR" | mail -s "ERRORS REPORTED: PostgreSQL Backup error Log for $HOST - $DATE" $MAILADDR
			cat "$LOGFILE" | mail -s "PostgreSQL Backup Log for $HOST - $DATE" $MAILADDR
	fi
else
	if [ -s "$LOGERR" ]
		then
			cat "$LOGFILE"
			echo
			echo "###### WARNING ######"
			echo "Errors reported during AutoPostgreSQLBackup execution.. Backup failed"
			echo "Error log below.."
			cat "$LOGERR"
	else
		cat "$LOGFILE"
	fi	
fi

if [ -s "$LOGERR" ]
	then
		STATUS=1
	else
		STATUS=0
fi

# Clean up Logfile
eval rm -f "$LOGFILE"
eval rm -f "$LOGERR"

exit $STATUS