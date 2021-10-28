#!/bin/bash

# Time tracking app
# For my own sanity

# MySQL alternative for datetime math
# create table tt(id int auto_increment primary key, activity text, starttime datetime, endtime datetime, activity_detail text);
# create view today_work as select *, timediff(starttime,endtime) as duration from tt.tt where activity='work' and date(starttime) = curdate();
# create view today_break as select *, timediff(starttime,endtime) as duration from tt.tt where activity='break' and date(starttime) = curdate();

# Set local password
# mysql_config_editor set --login-path=client --host=localhost --user=awsmatt --password

export myCommand=$1
echo $myCommand

echo "Name of the script: $0"
echo "Total number of arguments: $#"
echo "Values of all the arguments: $@"

export TTDIR=$(pwd)
export TTDB=tt

export MYSQL=$(which mysql)
if [[ -f "$MYSQL" ]]; then
	echo "You have MySQL"
else
	echo "You need MySQL installed to run program."
	echo "Exiting"
	exit 1
fi

# Enter start of work time
working()
{
	report
	unset LASTID
	export LASTID=$(mysql -BN -e "select id from tt.tt order by id desc limit 1" | grep -v mysql)
	echo $LASTID
	unset WT
	echo 'work time'
	echo 'What type of work are you doing?'
	echo 'Valid values are: email, DMA pricing,SOW, Poland Work, training, customer meeting, internal meeting, meeting prep, meeting follow up, prospecting, doc writing, deal quality review, GTM, reporting, SFDC, self development, interview, interview feedback'
	read worktype
	echo "Got it!  You're working on: "$worktype
	export WT=$worktype
	mysql -BN -e "update tt.tt set endtime=now() where id='$LASTID';insert into tt.tt(activity,activity_detail,starttime) values ('work','$WT',now());"
	report
}

# Enter break time
breaking()
{
	report
	unset LASTID
	export LASTID=$(mysql -BN -e "select id from tt.tt order by id desc limit 1" | grep -v mysql)
	echo $LASTID
	echo 'break time'
	mysql -e "update tt.tt set endtime=now() where id='$LASTID';insert into tt.tt(activity,activity_detail,starttime) values ('break','break time',now());"
	report
}

# End work
imdone()
{
	report
	unset LASTID
	export LASTID=$(mysql -BN -e "select id from tt.tt order by id desc limit 1" | grep -v mysql)
	echo $LASTID
	echo 'ending the day...'
	mysql -e "update tt.tt set endtime=now() where id='$LASTID';"
	mysql -e "insert into tt.daily_activity(activity_date,activity,activity_duration) select curdate(), activity, activity_duration from tt.activity;"
	report
}

report_work()
{
	echo "Reporting worktimes"
	mysql -e "select * from tt.today_work;"

}

report_breaks()
{
	echo "Reporting break times"
	mysql -e "select * from tt.today_break;"


}

report()
{
	echo "Reporting worktimes"
	mysql -e "select * from tt.today_work;"

	echo "Reporting break times"
	mysql -e "select * from tt.today_break;"

    echo "Reporting activity duration from today"
    mysql -e "select * from tt.activity"

    echo "What have you been up to?"
    mysql -e "select * from tt.this_week_activity"
    
}

quitThis()
{
	echo "Exiting"

}

oopsies()
{
	echo "Invalid entry... ¯\_(ツ)_/¯ "
}

dowhat()
{
	echo $huh
	case $huh in
		working*)
			working
			;;
		breaking*)
			breaking
			;;
		report*)
			report
			;;
		done*)
			imdone
			;;
		quitting*)
			quitThis
			;;
		*)
			startup
			;;
	esac
}

startup()
{
	echo "What would you like to do?"
	echo "1 == Work entry"
	echo "2 == Break entry"
	echo "3 == Report"
	echo "4 == End the day"
	echo "5 == Exit this program"
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
		report
		;;
	4)
		imdone
		;;
	5)
		quitThis
		;;
	*)
		oopsies
		;;
esac

}

# Let's run it!
enter_data

