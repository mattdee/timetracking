#!/bin/bash


# Time tracking app
# For my own sanity
# SQLite Table 
# create table tt(id integer primary key autoincrement, activity text, intime datetime);

export TTDIR=$(pwd)
export TTDB=$(pwd)/tt.db

export SQLITE=$(which sqlite3)
if [[ -f "$SQLITE" ]]; then
	echo "you have sqlite3"
else
	echo "You need sqlite3 installed to run program."
	echo "Exiting"
	exit 1
fi
