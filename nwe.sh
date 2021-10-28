#!/bin/bash

export thisFile=$1

countStuff()
{
n1=$(wc -l < $thisFile)


echo $thisFile

echo "There are $n1 lines in $thisFile"
}

countStuff