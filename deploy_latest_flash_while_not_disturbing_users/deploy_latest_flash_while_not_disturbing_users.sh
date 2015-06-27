#!/bin/bash
  
# If any previous instances of the runjsspolicy LaunchDaemon and script exist,
# unload the LaunchDaemon and remove the LaunchDaemon and script files

if [[ -f "/Library/LaunchDaemons/com.company.runjsspolicy.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchDaemons/com.company.runjsspolicy.plist"
   /bin/rm "/Library/LaunchDaemons/com.company.runjsspolicy.plist"
fi

if [[ -f "/var/root/runjsspolicy.sh" ]]; then
   /bin/rm "/var/root/runjsspolicy.sh"
fi

# Create the runjsspolicy LaunchDaemon by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchDaemon will run at load and every five minutes thereafter.

/bin/cat > "/tmp/com.company.runjsspolicy.plist" << 'RUN_JSS_POLICY_LAUNCHDAEMON'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.company.runjsspolicy</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/var/root/runjsspolicy.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>300</integer>
</dict>
</plist>
RUN_JSS_POLICY_LAUNCHDAEMON

# Create the runjsspolicy script by using cat input redirection
# to write the shell script contained below to a new file.

/bin/cat > "/tmp/runjsspolicy.sh" << 'RUN_JSS_POLICY_SCRIPT'
#!/bin/bash

# Script checks for all users to be logged out of the console.
# (AKA logged into the GUI via the OS loginwindow.) Once all users
# are logged-out, script runs a Casper policy via a custom trigger

#
# User-editable variables
#

# Set custom trigger for Casper policy

trigger_name="installflash"

#
# The variables below this line should not need to be edited.
# Use caution if doing so. 
#

CheckJSS (){
 
# Verifies that the Mac can communicate with the Casper server.

jss_comm_chk=`/usr/sbin/jamf checkJSSConnection > /dev/null; echo $?`

if [[ "$jss_comm_chk" -gt 0 ]]; then
       /usr/bin/logger "Machine cannot connect to the JSS. Exiting."
       exit 0
elif [[ "$jss_comm_chk" -eq 0 ]]; then
       /usr/bin/logger "Machine can connect to the JSS. Proceeding"
fi

}

RunPolicy (){
 
# Verifies that the Mac can communicate with the Casper server.

/usr/sbin/jamf policy -trigger $trigger_name

}

CheckLogggedIn (){
 
# Checks to see if any user accounts are currently logged into the console (AKA logged into the GUI via the OS loginwindow)

logged_in_users=`who | grep console`

}

SelfDestruct (){
 
# Removes script and associated LaunchDaemon

if [[ -f "/Library/LaunchDaemons/com.company.runjsspolicy.plist" ]]; then
   /bin/rm "/Library/LaunchDaemons/com.company.runjsspolicy.plist"
fi
srm $0
}

CheckLogggedIn

if [[ "$logged_in_users" != "" ]]; then
    /usr/bin/logger "User is logged in. Exiting."
    exit 0
fi 

if [[ "$logged_in_users" == "" ]]; then
    /usr/bin/logger "Nobody logged in. Proceeding"
    CheckJSS
    RunPolicy
    SelfDestruct
fi

exit 0
RUN_JSS_POLICY_SCRIPT

# Once the LaunchDaemon file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchDaemon into 
# place in /Library/LaunchDaemons.

/usr/sbin/chown root:wheel "/tmp/com.company.runjsspolicy.plist"
/bin/chmod 755 "/tmp/com.company.runjsspolicy.plist"
/bin/chmod a-x "/tmp/com.company.runjsspolicy.plist"
/bin/mv "/tmp/com.company.runjsspolicy.plist" "/Library/LaunchDaemons/com.company.runjsspolicy.plist"

# Once the script file has been created, fix the permissions
# so that the file is owned by root:wheel and set to be executable
# After the permissions have been updated, move the script into the
# place that it will be executed from.

/usr/sbin/chown root:wheel "/tmp/runjsspolicy.sh"
/bin/chmod 755 "/tmp/runjsspolicy.sh"
/bin/chmod a+x "/tmp/runjsspolicy.sh"
/bin/mv "/tmp/runjsspolicy.sh" "/var/root/runjsspolicy.sh"

# After the LaunchDaemon and script are in place with proper permissions,
# load the LaunchDaemon to begin the script's execution.

/bin/launchctl load -w "/Library/LaunchDaemons/com.company.runjsspolicy.plist"

exit 0