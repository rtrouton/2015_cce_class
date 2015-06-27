Have all clients submit inventory once a week on an every hour checkin, while devices in the Sales department should checkin once every fifteen minutes and submit daily inventory

Set all clients to checkin hourly:

1. Go to Management Settings: Computer Management and select Check-In
2. Set Check-In Frequency to the following:

Every 60 Minutes

3. Once Check-In Frequency has been set, click the Done button.

4. Go to Management Settings: Network Management and select Departments

5. Set up new department called Sales

6. Go to Smart Computer Groups and create a new smart group:

Display Name: All Sales Department Macs
Criteria: Department IS Sales

7. Set up a new policy for all clients to submit inventory:

Name: Update Inventory
Execution Frequency: Once every week
Trigger: Check-in
Scope: All Computers
Action: Update Inventory (in Maintenance section of the policy options.)

Once policy options are all set correctly, enable policy.

8. Set up a new policy for all Sales Macs to submit inventory:

Name: Update Inventory for Sales
Execution Frequency: Once every day
Trigger: Custom trigger - salesinventory
Scope: All Sales Department Macs
Action: Update Inventory (in Maintenance section of the policy options.)

Once policy options are all set correctly, enable policy.

10. Build a payload-free package named "Install Daily Sales Inventory LaunchDaemon" containing the following script to install a LaunchDaemon which calls the "Update Inventory for Sales" policy. The LaunchDaemon will run at load and every fifteen minutes thereafter.

https://gist.github.com/rtrouton/f5c5daa41cea39a1b494

11. Build a second payload-free package named "Uninstall Daily Sales Inventory LaunchDaemon" containing the following script to unload and uninstall the LaunchDaemon installed by "Install Daily Sales Inventory LaunchDaemon"

https://gist.github.com/rtrouton/ccdaa460e2edf2aa1a86

12. Upload both the "Install Daily Sales Inventory LaunchDaemon" and "Uninstall Daily Sales Inventory LaunchDaemon" payload-free packages to the Casper server.

13. Set up a new policy for all Sales Macs to install the "Install Daily Sales Inventory LaunchDaemon" payload-free package

Name: Install Sales Daily Inventory LaunchDaemon
Execution Frequency: Once per computer
Trigger: Check-in
Scope: All Sales Department Macs
Action: Install "Install Daily Sales Inventory LaunchDaemon.pkg"

14. Enable "Install Sales Daily Inventory LaunchDaemon" policy.

15. Verify that the "Install Sales Daily Inventory LaunchDaemon" policy is running normally by forcing installation on an affected Mac:

sudo jamf policy

16. Check the "Update Inventory for Sales" policy by viewing the logs and verifying the affected Mac checked in using the custom trigger.

17. Verify that the policy is only running once a day by unloading and reloading the launchdaemon:

/bin/launchctl unload "/Library/LaunchDaemons/com.company.salesinventory.plist"
/bin/launchctl load "/Library/LaunchDaemons/com.company.salesinventory.plist"

18. Once the LaunchDaemon has been reloaded, the inventory entry for the affected machine showed that it just checked in, but there was not a new log entry for the affected machine in the the "Update Inventory for Sales" policy's log.