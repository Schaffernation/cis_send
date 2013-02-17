#!/bin/sh

# Authors: Noam Zilberstein
# 		   Joe Schaffer

# USAGE
# 	cis_send hwxx ta_pennkey

# 	hwxx is the name of a directory with a subdirectory titled student_pennkey
#   for each student you wish to send email to. Within each folder is a file 
#   called comments.txt, this is the file which will be sent via email. The TA
#   will be bcc'd on all emails.

# 	In the directory which contains hwxx there should be 2 files present: 
#   - preamble.txt, postamble.txt
# 		These files are prepended and appended to your style comments within
# 		the message.

# 	- Output = preamble.txt ^ comments.txt ^ postamble.txt
#	- Do not use any double quotes in your txt files
#	- Any instance of the follwing will be replaced accordingly:
# 		+ NAME -> will be replaced with the students first name
# 		+ HWXX -> will be replaced with the current hw (the input hwxx)

# EXAMPLE									# OUTPUT EMAIL
# 	./cis_send hw04 sweirich				# 	Hi Joe,
#											#
# SET-UP									#   here are your grades for hw04.
#	ls .									#
#	 	preamble.txt						#	No mistakes!
#    	postamble.txt						#   
#	 	hw04								#   best, 
#			jschaf							#   Stephanie
#				 dna.ml 					
#				 etc.ml 					
#				 comments.txt
#			noamz
#				 dna.ml
#				 etc.ml
#				 comments.txt

# 	cat preamble.txt
#		Hi NAME,
#		Here is your style score for HWXX.

#	cat postamble.txt
#		best,
#		Stephanie

#   cat hw04/jschaf/comments.txt
#		No mistakes!





HWxx=$1
TA=$2
TAEmail=$(ssh cis120@minus.seas.upenn.edu "cis get email $TA")
Subject="[cis120] $HWxx - style"

send () {
	pennkey=$1

	StudentEmail=$(ssh cis120@minus.seas.upenn.edu "cis get email $pennkey")
	CAPNAME=$(ssh cis120@minus.seas.upenn.edu "cis get roster $pennkey | tr [a-z] [A-Z] | tail -1 | grep -ow '[A-Z]*' | head -2 | tail -1")
	FLETTER=$(echo $CAPNAME | head -c 1)
	REST=$(echo $CAPNAME | tail -c+2 | tr [A-Z] [a-z])
	NAME=$FLETTER$REST

	sp='\n\n'

	EmailMessage=$(cat preamble.txt)$sp$(cat $HWxx/$1/comments.txt)$sp$(cat postamble.txt)

	EmailMessage=$(printf "$EmailMessage" | sed "s/HWXX/$HWxx/g" | sed "s/NAME/$NAME/g")

	if [ -n "$StudentEmail" ]
	then
		ssh $TA@eniac.seas.upenn.edu "printf \"$EmailMessage\" | mail -s '$Subject' -b $TAEmail 'theschafferexperience@gmail.com'"
		echo "Successfully sent mail to $StudentEmail"
	else
		echo "Message to $pennkey failed"
	fi
}

for pennkey in $(ls $HWxx)
do
	send $pennkey
done
