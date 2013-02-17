#!/bin/sh

# USAGE:
# cis_send hwxx ta_pennkey

# hwxx is the name of a directory with a subdirectory titled student_pennkey for each
# student you wish to send email to. Within each folder is a file caled comments.txt, 
# this is the file which will be sent via email. Do not use any double quotes in your
# comments.txt file.
 
# In the directory which contains hwxx there should be 2 files present: preamble.txt postamble.txt
# These files are prepended and appended accordingly to your style comments within the message.

# The student's name will be extracted from the database and prepended to the email with a 
# customized greeting. The TA will be bcc'd on each email, for their own records.

# Example:
#	ls . ->
#	 	pramble.txt - contains the introduction (here are your grades etc.)
#    	postamble.txt - conatins the conclusion and signature (best, Stephanie)
#	 	hw04
#			jschaf - contains the comments for jschaf's hw (No mistakes!)
#			noamz

# 	./cis_send hw04 sweirich

# Output Email:
# 	Hi Joe,
# 
# 	here are your grades etc.
#
# 	No mistakes!
#
# 	best, Stephanie


HWxx=$1
TA=$2
TAEmail=$(ssh cis120@minus.seas.upenn.edu "cis get email $TA")
Subject="[cis120] $HWxx - style"

send () {
	StudentEmail=$(ssh cis120@minus.seas.upenn.edu "cis get email $1")
	CAPNAME=$(ssh cis120@minus.seas.upenn.edu "cis get roster $1 | tr [a-z] [A-Z] | tail -1 | grep -ow '[A-Z]*' | head -2 | tail -1")
	FLETTER=$(echo $CAPNAME | head -c 1)
	REST=$(echo $CAPNAME | tail -c+2 | tr [A-Z] [a-z])
	NAME=$FLETTER$REST

	EmailMessage="$(cat preamble.txt)\n$(cat $2/$1/comments.txt)\n\n$(cat postamble.txt)"

	EmailMessage=$(printf "$EmailMessage" | sed "s/HWXX/$HWxx/g" | sed "s/NAME/$NAME/g")

	if [ -n "$StudentEmail" ]
	then
		ssh $TA@eniac.seas.upenn.edu "printf \"$EmailMessage\" | mail -s '$Subject' -b $TAEmail '$StudentEmail'"
		echo "Successfully sent mail to $StudentEmail"
	else
		echo "Message to $1 failed"
	fi
}

for pennkey in $(ls $HWxx)
do
	send $pennkey $HWxx
done
