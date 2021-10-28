#!/bin/bash


# Time tracking app
# For my own sanity
# SQLite Table 
# CREATE TABLE tt(id INTEGER PRIMARY KEY AUTOINCREMENT, activity text, starttime datetime, endtime datetime, activity_detail varchar);

# MySQL alternative for datetime math
# create table tt(id int auto_increment primary key, activity text, starttime datetime, endtime datetime, activity_detail text);


export TTDIR=/Users/awsmatt/.timetracking
export TTDB=/Users/awsmatt/.timetracking/tt.db

export SQLITE=$(which sqlite3)
if [[ -f "$SQLITE" ]]; then
	echo "you have sqlite3"
else
	echo "You need sqlite3 installed to run program."
	echo "Exiting"
	exit 1
fi


# Enter start of work time
working()
{
	unset LASTID
	export LASTID=$(sqlite3 -noheader $TTDB 'select max(id) from tt')
	echo $LASTID
	unset WT
	echo 'work time'
	echo 'What type of work are you doing?'
	echo 'Examples: email, customer meeting, internal meeting, reporting'
	read worktype
	echo "Got it!  You're working on: "$worktype
	export WT=$worktype
	sqlite3 $TTDB "update tt set endtime=datetime('now','localtime') where id='$LASTID';insert into tt(activity,activity_detail,starttime) values ('work','$WT',datetime('now','localtime'));"
}

# Enter break time
breaking()
{
	unset LASTID
	export LASTID=$(sqlite3 -noheader $TTDB 'select max(id) from tt')
	echo $LASTID
	echo 'break time'
	sqlite3 $TTDB "update tt set endtime=datetime('now','localtime') where id='$LASTID';insert into tt(activity,starttime) values ('break',datetime('now','localtime'));"
}

report_work()
{
	echo "Reporting worktimes"
	sqlite3 $TTDB "select * from tt where activity='work';select * from today_work_hours;select * from today_work;"

}

report_breaks()
{
	echo "Reporting break times"
	sqlite3 $TTDB "select * from tt where activity='break';select * from today_break_hours;select * from today_break"


}

oppies()
{
	echo "Invalid entry... ¯\_(ツ)_/¯ "
}

startup()
{
	echo "What would you like to do?"
	echo "1 == Work entry"
	echo "2 == Break entry"
	echo "3 == Report work times"
	echo "4 == Report break times"
	echo "Please enter a choice:>"
	read whatwhat
}


enter_data()
{
startup
case $whatwhat in
	1) 
		working
		;;
	2)
		breaking
		;;
	3)
		report_work
		;;
	4)
		report_breaks
		;;
	*)
		oppies
		;;
esac

}

# Let's run it!  
enter_data

