#!/bin/bash

# Script to prompt <user> to change user password after 15th of every month

# If no username is supplied
if [[ -z "$1" ]]; then
	echo "Usage: $0 <username>"
	exit 1
fi

# User for whom you want to prompt password change
USERNAME="madhur"

# Find the current day of month
CURRENT_DAY_OF_MONTH=$(date +%d)

# Calculate the number of days since last time the password
# was changed
PWD_CHG_DT_IN_SECONDS=$(chage -l "${USERNAME}" | grep -i "Last password change" | awk -F: '{print $2}' | xargs -I{} date -d {} +%s)
LAST_PWD_CHG_DAYS=$(( ( CURRENT_DAY_OF_MONTH - LAST_PWD_CHG_SECONDS ) / 86400 ))

# Check if the daty of month >= 15
if [[ "${LAST_PWD_CHG_DAYS}" -ge 15 ]]; then
	
	# Echo message that I need to change the password
	echo "Its been more than 15 days since you last changed your password. Please change your password"
	
	# Run the command to change the password
	passwd "${USERNAME}"
else
	echo "Password was changed less than 15 days ago, so not prompting for password change."
fi
