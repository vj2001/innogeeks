#!/bin/bash

touch /home/Documents/mygitproject/innogeeks/result.txt
PATH= /home/Documents/mygitproject/innogeeks/result.txt
echo "Enter any number"
read num

if [[ ( $num -eq 15 || $num  -eq 45 ) ]]
then
echo "You won the game">> $PATH
else
echo "You lost the game">> $PATH
fi

echo "GAME OVER">> $PATH

# added below commands in branch2
echo "1: memory details --">>$PATH
lsmem >> $PATH
echo "1: cpu details --">>$PATH
lscpu >> $PATH