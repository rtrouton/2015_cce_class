#!/bin/bash

# For the jss_server_address variable, put the complete 
# fully qualified domain name address of your Casper server
 
jss_server_address="https://casper.demo.com:8443"

# Specify location where information from the script
# should be logged.

log_location="/var/log/casper_fv2_report.log"

# Specify JSS API user

jss_api_user="ladmin"

# Specify JSS API password

jss_api_password="jamf1234"

# Specify the JSS ID of the desired report. This ID
# will be that of an advanced computer search, available
# from an address similar to that shown below:
#
# https://casper.server.name.here:8443/advancedComputerSearches.html
#

report_id="1"

# Date to use with naming the report

report_date=`date +%Y%m%d%H%M%S`

# Relevant identifier to use with naming the report

report_name="filevault2-encryption-report"

# Directory to store the report

report_location="/tmp"

# Function to provide logging of the script's actions to
# the log file defined by the log_location variable

ScriptLogging(){

    DATE=`date +%Y-%m-%d\ %H:%M:%S`
    LOG="$log_location"
    
    echo "$DATE" " $1" >> $LOG
}

# Verifies that the JSS is responding to a communication query 
# by the Casper agent. If the communication check succeeds, download
# specified report from JSS.
#
# If the communication check returns a result
# of anything greater than zero, the communication check has failed.
# If the communication check fails, stop execution of the script
#
# If the communication check succeeds, use the JSS API to download
# the desired report in XML format and store it in the specified location.
# The log will record the location and filename of the downloaded report.
#  

jss_comm_chk=`/usr/sbin/jamf checkJSSConnection > /dev/null; echo $?`

if [[ "$jss_comm_chk" -eq 0 ]]; then
       ScriptLogging "Machine can connect to the JSS on $jss_server_address."
       curl --silent -k -u $jss_api_user:$jss_api_password $jss_server_address/JSSResource/advancedcomputersearches/id/$report_id > $report_location/$report_date-$report_name.xml
       ScriptLogging "Report available at the following location: $report_location/$report_date-$report_name.xml"
       ScriptLogging ""
elif [[ "$jss_comm_chk" -gt 0 ]]; then
       ScriptLogging "Machine cannot connect to the JSS on $jss_server_address."
       ScriptLogging "Script is exiting and will try again at next execution."
       ScriptLogging ""
       exit 0
fi