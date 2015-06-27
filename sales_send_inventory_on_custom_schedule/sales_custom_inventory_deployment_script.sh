#!/bin/bash
 
# If any previous instances of the salesinventory LaunchDaemon exist,
# unload the LaunchDaemon and remove the LaunchDaemon file
 
if [[ -f "/Library/LaunchDaemons/com.company.salesinventory.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchDaemons/com.company.salesinventory.plist"
   /bin/rm "/Library/LaunchDaemons/com.company.salesinventory.plist"
fi
 
# Create the salesinventory LaunchDaemon by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchDaemon will run at load and every fifteen minutes thereafter.
 
/bin/cat > "/tmp/com.company.salesinventory.plist" << 'CASPER_SALES_INVENTORY_LAUNCHDAEMON'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.company.salesinventory</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/sbin/jamf</string>
		<string>policy</string>
		<string>-trigger</string>
		<string>salesinventory</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>900</integer>
</dict>
</plist>
CASPER_SALES_INVENTORY_LAUNCHDAEMON
 
# Once the LaunchDaemon file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchDaemon into 
# place in /Library/LaunchDaemons.
 
/usr/sbin/chown root:wheel "/tmp/com.company.salesinventory.plist"
/bin/chmod 755 "/tmp/com.company.salesinventory.plist"
/bin/chmod a-x "/tmp/com.company.salesinventory.plist"
/bin/mv "/tmp/com.company.salesinventory.plist" "/Library/LaunchDaemons/com.company.salesinventory.plist"
 
# After the LaunchDaemon is in place with proper permissions,
# load the LaunchDaemon to begin the policy execution.

if [[ -f "/Library/LaunchDaemons/com.company.salesinventory.plist" ]]; then 
   /bin/launchctl load -w "/Library/LaunchDaemons/com.company.salesinventory.plist" 
fi 

exit 0