#!/bin/sh

# Authors: Noam Zilberstein
# 		   Joe Schaffer

# USAGE
# 	./cis_send hwxx ta_pennkey

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

hwxx=$1
ta=$2
ta_email=$(ssh cis120@minus.seas.upenn.edu "cis get email $ta")
subject="[cis120] $hwxx - style"

send () {
	pennkey=$1

	cptl_name=$(ssh cis120@minus.seas.upenn.edu "cis get roster $pennkey | tr [a-z] [A-Z] | tail -1 | grep -ow '[A-Z]*' | head -2 | tail -1")
	fst_ltr=$(echo $cptl_name | head -c 1)
	rst_ltrs=$(echo $cptl_name | tail -c+2 | tr [A-Z] [a-z])

	student_name=$fst_ltr$rst_ltrs
	student_email=$(ssh cis120@minus.seas.upenn.edu "cis get email $pennkey")
	
	sp='\n\n'
	email_message=$sp$(cat $hwxx/$1/comments.txt)$sp
	email_message=$(cat preamble.txt)$email_message$(cat postamble.txt)
	email_message=$(printf "$email_message" | sed "s/HWXX/$hwxx/g" | sed "s/NAME/$student_name/g")

	if [ -n "$student_email" ] && [ $? = 0 ]
	then
		ssh $ta@eniac.seas.upenn.edu "printf \"$email_message\" | mail -s '$subject' -b $ta_email '$student_email'"
		echo "Successfully sent mail to $student_email"
	else
		echo "Message to $pennkey failed"
	fi
}

for pennkey in $(ls $hwxx)
do
	send $pennkey
done
