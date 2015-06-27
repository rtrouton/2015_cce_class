#!/bin/bash
 
# If any instances of the salesinventory LaunchDaemon exist,
# unload the LaunchDaemon and remove the LaunchDaemon file
 
if [[ -f "/Library/LaunchDaemons/com.company.salesinventory.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchDaemons/com.company.salesinventory.plist"
   /bin/rm "/Library/LaunchDaemons/com.company.salesinventory.plist"
fi

exit 0