#!/bin/bash

#Initializing the options to the script
SCRIPT_TO_ADD=""
CRON_SCHEDULE=""

# Error/Usage function
usage() {
	echo "Usage: ${0} -s <SCRIPT_TO_ADD> -c <CRON_SCHEDULE>"
	exit 1
}


# Parsing the options presnted to the command line
while getopts ":s:c:" opt; do
	case $opt in
		s)
			SCRIPT_TO_ADD="${OPTARG}"
			;;
		c)
			CRON_SCHEDULE="${OPTARG}"
			;;
		\?)
			echo "Invalid option -${OPTARG}" >&2
			usage
			;;
		:)
			echo "Option -${OPTARG} requires an argument" <&2
			usage
			;;
	esac
done

# Exiting if necessary options not provided
if [ -z "${SCRIPT_TO_ADD}" ] | [ -z "${CRON_SCHEDULE}" ]; then
	echo "Please provide necessary options" >&2
	usage
fi

# Modifying the SCRIPT_TO_ADD to take full path if provided by relative path
SCRIPT_TO_ADD=$(realpath "${SCRIPT_TO_ADD}")

echo "SCRIPT TO ADD = ${SCRIPT_TO_ADD}"
echo "CRON SCHEDULE = ${CRON_SCHEDULE}"

shift $((OPTIND-1))

# If there is a "--" then the options after that are considered to be the options for the SCRIPT_TO_ADD file
if [ "$1" = "--" ]; then
	shift
fi

# Cron job string
# ${@} is the remaining arguments that are specific to the SCRIPT_TO_ADD. They can be anything specific to the requirements of SCRIPT_TO_ADD
CRON_JOB_STRING="${CRON_SCHEDULE} ${SCRIPT_TO_ADD} ${@}"
echo "CRON JOB = ${CRON_JOB_STRING}"

# Adding the cron job to crontab

# Checking if the crontab already doesn't have the cron job we are about to add, by checking the exit status of the grep command ran on crontab file
if ! crontab -l | grep -Fq "${SCRIPT_TO_ADD}"; then

	echo "Cron job doesn't exist. Adding..."	

	#Copying the existing crontab file content to temporary file
	#echo $(crontab -l)
	crontab -l > mycron
	
	# Adding  the cron job to the temp file
	echo "${CRON_JOB_STRING}" >> mycron
	cat mycron	
	# Installing the temp file as new crontab
	crontab mycron
	
	# Removing the temp file
	rm mycron
else
	echo "Cron job alread exists" <&2
fi

