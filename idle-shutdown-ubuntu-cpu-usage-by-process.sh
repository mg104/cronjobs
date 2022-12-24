#!/bin/bash

# Initial experiment with printing the rsession cpu usage 

# Process name (as displayed in top command) for which the CPU usage is to be monitored
# Note: I'm using this scirpt currently to monitor "RStudio" sessions (an IDE which I'm running on a GCP instance)
# , so th process name I'm using right now is the one which I had seen for rstudio using top command, which is "rsession".
# PROCESS_NAME="rsession"

# CPU Usage threshold for the concerned process name, less than which the CPU will be thought to be idle
CPU_PERCENTAGE_THRESHOLD=1.0

# Number of times the top command has returned the CPU Usage for rsession process to be less than
# threshold
COUNTER_LOW_CPU_USAGE=0

# Number of Counter ticks after which we want to shutdown the computer
SHUTDOWN_THRESHOLD=1200

# Running an endless loop with the following properties:
# Run top command with following options:
# 	-d 3 -n2 : This will run top command 2 times, with gap of 3 seconds (I think this is default gap in top command) 
#		   between the 2 runs
# 	-b : This is required otherwise the top command doesn't send its output to the location where we want (other than 
#	     the terminal
# grep : Select only the particular process name for which we want the script to monitor CPU Usage
# awk {print $9} this prints only the CPU usage column (9th column in top output)

while true
do
	RSESSION_CPU_USAGE=$(top -d 3 -b -n2 | grep rsession | tail -1 | awk '{ print($9) }')

	# Finding if the CPU Usage is below CPU usage threshold set by  us
	# Note: 1.) We are using '<' to compare the 2 variables' values becuase -lt is not working properly when comparing 2 
	# 	    variables
	# 	2.) We are using bc -l because the linux terminal isn't able to compare floating point values properly
	
	USAGE_CHECK=$(echo ${RSESSION_CPU_USAGE}'<'${CPU_PERCENTAGE_THRESHOLD} | bc -l)
	
	# If CPU Usage is indeed less than threshold, the comparison above will yield COUNTER_LOW_CPU_USAGE as 1 and therefore
	# greater than 0. We check this below and if true, we take the following steps:
	# 	1.) If the CPU counter is already greater than 0, meaning that this is not the 1st time that CPU usage is less than
	# 	    the threshold, then add to the CPU counter's existing value.
	#	2.) If the CPU counte is 0 then increment it to 1
	# If the condition above is false, meaning that the CPU Usage is greater than shutdown threshold, then reset the CPU counter to 0
	# We do this to ensure that the computer is shutdown only when the CPU Usage is low CONSECUTIVELY for say 1 hour
	if [[ $USAGE_CHECK -gt 0 ]];
	then
		if [[ ${COUNTER_LOW_CPU_USAGE} -gt 0 ]];
		then	
			(( COUNTER_LOW_CPU_USAGE+=1 ))
		else
			(( COUNTER_LOW_CPU_USAGE=1 ))
		fi
	else
		(( COUNTER_LOW_CPU_USAGE=0 ))
		
	fi
	
	echo ${COUNTER_LOW_CPU_USAGE}
	
	# Shut down the computer if the counter has reached overall shutdown threshold
	SHUTDOWN_REACHED=$(echo ${COUNTER_LOW_CPU_USAGE}'>'${SHUTDOWN_THRESHOLD} | bc -l)
	if [[ ${SHUTDOWN_REACHED} -eq 1 ]];
	then 
		sudo poweroff
	fi	

done

